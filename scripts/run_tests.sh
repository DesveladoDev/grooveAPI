#!/bin/bash

# Script para ejecutar tests con Firebase Emulators
# Uso: ./scripts/run_tests.sh [unit|widget|integration|all]

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes con color
print_message() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que estamos en el directorio correcto
if [ ! -f "pubspec.yaml" ]; then
    print_error "Este script debe ejecutarse desde el directorio raíz del proyecto Flutter"
    exit 1
fi

# Verificar que Firebase CLI está instalado
if ! command -v firebase &> /dev/null; then
    print_error "Firebase CLI no está instalado. Instálalo con: npm install -g firebase-tools"
    exit 1
fi

# Función para verificar si los emulators están ejecutándose
check_emulators() {
    print_message "Verificando estado de Firebase Emulators..."
    
    # Verificar si el puerto de Firestore está en uso
    if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null 2>&1; then
        print_success "Firebase Emulators están ejecutándose"
        return 0
    else
        print_warning "Firebase Emulators no están ejecutándose"
        return 1
    fi
}

# Función para iniciar emulators
start_emulators() {
    print_message "Iniciando Firebase Emulators..."
    
    # Crear directorio para logs si no existe
    mkdir -p logs
    
    # Iniciar emulators en background
    firebase emulators:start --only auth,firestore,storage > logs/emulators.log 2>&1 &
    EMULATOR_PID=$!
    
    # Esperar a que los emulators estén listos
    print_message "Esperando a que los emulators estén listos..."
    sleep 10
    
    # Verificar que los emulators están ejecutándose
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if check_emulators; then
            print_success "Firebase Emulators iniciados correctamente"
            return 0
        fi
        
        print_message "Intento $attempt/$max_attempts - Esperando emulators..."
        sleep 2
        ((attempt++))
    done
    
    print_error "No se pudieron iniciar los Firebase Emulators"
    return 1
}

# Función para detener emulators
stop_emulators() {
    print_message "Deteniendo Firebase Emulators..."
    
    # Buscar y matar procesos de emulators
    pkill -f "firebase emulators" || true
    pkill -f "java.*firestore" || true
    
    # Esperar un momento para que se detengan
    sleep 3
    
    print_success "Firebase Emulators detenidos"
}

# Función para ejecutar tests unitarios
run_unit_tests() {
    print_message "Ejecutando tests unitarios..."
    flutter test test/unit/ --coverage
    print_success "Tests unitarios completados"
}

# Función para ejecutar tests de widgets
run_widget_tests() {
    print_message "Ejecutando tests de widgets..."
    flutter test test/widget/ --coverage
    print_success "Tests de widgets completados"
}

# Función para ejecutar tests de integración
run_integration_tests() {
    print_message "Ejecutando tests de integración..."
    
    # Verificar que los emulators están ejecutándose
    if ! check_emulators; then
        print_message "Iniciando emulators para tests de integración..."
        start_emulators
        STARTED_EMULATORS=true
    fi
    
    flutter test test/integration/ --coverage
    print_success "Tests de integración completados"
    
    # Detener emulators si los iniciamos nosotros
    if [ "$STARTED_EMULATORS" = true ]; then
        stop_emulators
    fi
}

# Función para ejecutar todos los tests
run_all_tests() {
    print_message "Ejecutando todos los tests..."
    
    # Iniciar emulators
    start_emulators
    
    # Ejecutar todos los tipos de tests
    run_unit_tests
    run_widget_tests
    run_integration_tests
    
    # Detener emulators
    stop_emulators
    
    print_success "Todos los tests completados"
}

# Función para generar reporte de cobertura
generate_coverage_report() {
    print_message "Generando reporte de cobertura..."
    
    # Verificar que lcov está instalado
    if ! command -v lcov &> /dev/null; then
        print_warning "lcov no está instalado. Instálalo para generar reportes HTML de cobertura"
        print_warning "macOS: brew install lcov"
        print_warning "Ubuntu: sudo apt-get install lcov"
        return 1
    fi
    
    # Crear directorio para reportes
    mkdir -p coverage/html
    
    # Generar reporte HTML
    genhtml coverage/lcov.info -o coverage/html
    
    print_success "Reporte de cobertura generado en coverage/html/index.html"
    
    # Abrir reporte en el navegador (opcional)
    if command -v open &> /dev/null; then
        open coverage/html/index.html
    fi
}

# Función para limpiar archivos de cobertura
clean_coverage() {
    print_message "Limpiando archivos de cobertura..."
    rm -rf coverage/
    print_success "Archivos de cobertura eliminados"
}

# Función para mostrar ayuda
show_help() {
    echo "Uso: $0 [COMANDO] [OPCIONES]"
    echo ""
    echo "COMANDOS:"
    echo "  unit         Ejecutar solo tests unitarios"
    echo "  widget       Ejecutar solo tests de widgets"
    echo "  integration  Ejecutar solo tests de integración"
    echo "  all          Ejecutar todos los tests (default)"
    echo "  coverage     Generar reporte de cobertura HTML"
    echo "  clean        Limpiar archivos de cobertura"
    echo "  start-emulators    Iniciar Firebase Emulators"
    echo "  stop-emulators     Detener Firebase Emulators"
    echo "  help         Mostrar esta ayuda"
    echo ""
    echo "OPCIONES:"
    echo "  --no-coverage      No generar cobertura"
    echo "  --open-coverage    Abrir reporte de cobertura al finalizar"
    echo ""
    echo "EJEMPLOS:"
    echo "  $0                 # Ejecutar todos los tests"
    echo "  $0 unit            # Ejecutar solo tests unitarios"
    echo "  $0 all --open-coverage  # Ejecutar todos y abrir reporte"
}

# Función principal
main() {
    local command="${1:-all}"
    local open_coverage=false
    
    # Procesar argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            --open-coverage)
                open_coverage=true
                shift
                ;;
            --no-coverage)
                # Esta opción se puede implementar si es necesario
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    
    # Ejecutar comando
    case $command in
        unit)
            run_unit_tests
            ;;
        widget)
            run_widget_tests
            ;;
        integration)
            run_integration_tests
            ;;
        all)
            run_all_tests
            ;;
        coverage)
            generate_coverage_report
            ;;
        clean)
            clean_coverage
            ;;
        start-emulators)
            start_emulators
            ;;
        stop-emulators)
            stop_emulators
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Comando desconocido: $command"
            show_help
            exit 1
            ;;
    esac
    
    # Generar reporte de cobertura si se solicitó
    if [ "$open_coverage" = true ] && [ -f "coverage/lcov.info" ]; then
        generate_coverage_report
    fi
}

# Manejar señales para limpiar emulators al salir
trap 'stop_emulators; exit 130' INT
trap 'stop_emulators; exit 143' TERM

# Ejecutar función principal con todos los argumentos
main "$@"