#!/bin/bash

# 🔍 Script para validar CI/CD localmente
# Este script ejecuta las mismas validaciones que el pipeline de GitHub Actions

set -e  # Salir en caso de error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes con colores
print_step() {
    echo -e "${BLUE}🔍 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Verificar dependencias
check_dependencies() {
    print_step "Verificando dependencias..."
    
    if ! command_exists flutter; then
        print_error "Flutter no está instalado o no está en el PATH"
        exit 1
    fi
    
    if ! command_exists dart; then
        print_error "Dart no está instalado o no está en el PATH"
        exit 1
    fi
    
    if ! command_exists firebase; then
        print_warning "Firebase CLI no está instalado. Los tests de integración pueden fallar."
    fi
    
    print_success "Dependencias verificadas"
}

# Verificar formato del código
check_formatting() {
    print_step "Verificando formato del código..."
    
    if ! dart format --output=none --set-exit-if-changed .; then
        print_error "El código no está formateado correctamente"
        print_warning "Ejecuta: dart format ."
        return 1
    fi
    
    print_success "Formato del código correcto"
}

# Análisis estático
analyze_code() {
    print_step "Ejecutando análisis estático..."
    
    if ! flutter analyze --fatal-infos; then
        print_error "Análisis estático falló"
        return 1
    fi
    
    print_success "Análisis estático completado"
}

# Verificar dependencias
check_pub_deps() {
    print_step "Verificando dependencias de pub..."
    
    flutter pub get
    flutter pub deps
    
    print_success "Dependencias verificadas"
}

# Generar mocks
generate_mocks() {
    print_step "Generando mocks..."
    
    if ! dart run build_runner build --delete-conflicting-outputs; then
        print_error "Generación de mocks falló"
        return 1
    fi
    
    print_success "Mocks generados"
}

# Ejecutar tests unitarios
run_unit_tests() {
    print_step "Ejecutando tests unitarios..."
    
    if ! flutter test test/unit/ --coverage --reporter=expanded; then
        print_error "Tests unitarios fallaron"
        return 1
    fi
    
    print_success "Tests unitarios completados"
}

# Ejecutar tests de widgets
run_widget_tests() {
    print_step "Ejecutando tests de widgets..."
    
    if ! flutter test test/widget/ --coverage --reporter=expanded; then
        print_error "Tests de widgets fallaron"
        return 1
    fi
    
    print_success "Tests de widgets completados"
}

# Ejecutar tests de integración
run_integration_tests() {
    print_step "Ejecutando tests de integración..."
    
    if ! command_exists firebase; then
        print_warning "Firebase CLI no disponible. Saltando tests de integración."
        return 0
    fi
    
    # Verificar si los emulators están corriendo
    if ! firebase emulators:exec --only auth,firestore,storage --project demo-project "echo 'Emulators running'" 2>/dev/null; then
        print_warning "Firebase Emulators no están corriendo. Iniciando..."
        
        # Iniciar emulators en background
        firebase emulators:start --only auth,firestore,storage --project demo-project &
        EMULATOR_PID=$!
        
        # Esperar a que los emulators estén listos
        sleep 30
        
        # Ejecutar tests
        if flutter test test/integration/ --coverage --reporter=expanded; then
            print_success "Tests de integración completados"
            INTEGRATION_SUCCESS=true
        else
            print_error "Tests de integración fallaron"
            INTEGRATION_SUCCESS=false
        fi
        
        # Detener emulators
        kill $EMULATOR_PID 2>/dev/null || true
        
        if [ "$INTEGRATION_SUCCESS" = false ]; then
            return 1
        fi
    else
        if ! flutter test test/integration/ --coverage --reporter=expanded; then
            print_error "Tests de integración fallaron"
            return 1
        fi
        print_success "Tests de integración completados"
    fi
}

# Verificar builds
check_builds() {
    print_step "Verificando builds..."
    
    # Build Android Debug
    if ! flutter build apk --debug; then
        print_error "Build Android Debug falló"
        return 1
    fi
    print_success "Build Android Debug completado"
    
    # Build Web
    if ! flutter build web --debug; then
        print_error "Build Web falló"
        return 1
    fi
    print_success "Build Web completado"
}

# Verificar seguridad
check_security() {
    print_step "Verificando seguridad..."
    
    # Audit de dependencias
    if ! flutter pub audit; then
        print_warning "Audit de dependencias encontró problemas"
    fi
    
    # Buscar secretos hardcodeados
    if grep -r -i "api[_-]key\|secret\|password\|token" lib/ --include="*.dart" | grep -v "// TODO\|// FIXME" | grep -v "test" > /dev/null; then
        print_error "Posibles secretos hardcodeados encontrados!"
        grep -r -i "api[_-]key\|secret\|password\|token" lib/ --include="*.dart" | grep -v "// TODO\|// FIXME" | grep -v "test"
        return 1
    fi
    
    print_success "Verificación de seguridad completada"
}

# Generar reporte de cobertura
generate_coverage_report() {
    print_step "Generando reporte de cobertura..."
    
    if command_exists genhtml; then
        genhtml coverage/lcov.info -o coverage/html
        print_success "Reporte de cobertura generado en coverage/html/index.html"
    else
        print_warning "genhtml no está instalado. Instala lcov para generar reportes HTML."
    fi
}

# Función principal
main() {
    echo -e "${BLUE}🚀 Validación de CI/CD Local${NC}"
    echo "=================================="
    
    # Verificar si estamos en el directorio correcto
    if [ ! -f "pubspec.yaml" ]; then
        print_error "No se encontró pubspec.yaml. Ejecuta este script desde la raíz del proyecto."
        exit 1
    fi
    
    # Contador de errores
    ERRORS=0
    
    # Ejecutar validaciones
    check_dependencies || ((ERRORS++))
    check_formatting || ((ERRORS++))
    analyze_code || ((ERRORS++))
    check_pub_deps || ((ERRORS++))
    generate_mocks || ((ERRORS++))
    run_unit_tests || ((ERRORS++))
    run_widget_tests || ((ERRORS++))
    run_integration_tests || ((ERRORS++))
    check_builds || ((ERRORS++))
    check_security || ((ERRORS++))
    generate_coverage_report
    
    echo "=================================="
    
    if [ $ERRORS -eq 0 ]; then
        print_success "🎉 Todas las validaciones pasaron! El código está listo para CI/CD."
        exit 0
    else
        print_error "❌ $ERRORS validación(es) fallaron. Revisa los errores antes de hacer push."
        exit 1
    fi
}

# Manejar argumentos de línea de comandos
case "${1:-}" in
    --format-only)
        check_formatting
        ;;
    --analyze-only)
        analyze_code
        ;;
    --test-only)
        generate_mocks
        run_unit_tests
        run_widget_tests
        ;;
    --build-only)
        check_builds
        ;;
    --security-only)
        check_security
        ;;
    --help|-h)
        echo "Uso: $0 [opción]"
        echo ""
        echo "Opciones:"
        echo "  --format-only    Solo verificar formato"
        echo "  --analyze-only   Solo análisis estático"
        echo "  --test-only      Solo ejecutar tests"
        echo "  --build-only     Solo verificar builds"
        echo "  --security-only  Solo verificar seguridad"
        echo "  --help, -h       Mostrar esta ayuda"
        echo ""
        echo "Sin argumentos: Ejecutar todas las validaciones"
        ;;
    *)
        main
        ;;
esac