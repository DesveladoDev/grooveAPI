#!/bin/bash

# Script de configuración para Salas & Beats
# Este script automatiza la instalación y configuración del entorno de desarrollo

set -e  # Salir si cualquier comando falla

echo "🎵 Configurando Salas & Beats - Entorno de Desarrollo 🎵"
echo "================================================="

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes con colores
print_status() {
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

# Verificar si estamos en macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "Este script está diseñado para macOS"
    exit 1
fi

# Verificar si Homebrew está instalado
if ! command -v brew &> /dev/null; then
    print_status "Instalando Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    print_success "Homebrew instalado"
else
    print_success "Homebrew ya está instalado"
fi

# Actualizar Homebrew
print_status "Actualizando Homebrew..."
brew update

# Instalar Flutter usando Homebrew
if ! command -v flutter &> /dev/null; then
    print_status "Instalando Flutter..."
    brew install --cask flutter
    print_success "Flutter instalado"
else
    print_success "Flutter ya está instalado"
fi

# Verificar instalación de Flutter
print_status "Verificando instalación de Flutter..."
flutter doctor

# Instalar Node.js para Cloud Functions
if ! command -v node &> /dev/null; then
    print_status "Instalando Node.js..."
    brew install node
    print_success "Node.js instalado"
else
    print_success "Node.js ya está instalado"
fi

# Instalar Firebase CLI
if ! command -v firebase &> /dev/null; then
    print_status "Instalando Firebase CLI..."
    npm install -g firebase-tools
    print_success "Firebase CLI instalado"
else
    print_success "Firebase CLI ya está instalado"
fi

# Instalar dependencias de Flutter
print_status "Instalando dependencias de Flutter..."
flutter pub get
print_success "Dependencias de Flutter instaladas"

# Instalar dependencias de Cloud Functions
if [ -d "functions" ]; then
    print_status "Instalando dependencias de Cloud Functions..."
    cd functions
    npm install
    cd ..
    print_success "Dependencias de Cloud Functions instaladas"
fi

# Configurar Git hooks (opcional)
if [ -d ".git" ]; then
    print_status "Configurando Git hooks..."
    
    # Pre-commit hook para ejecutar análisis estático
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
echo "Ejecutando análisis estático..."
flutter analyze
if [ $? -ne 0 ]; then
    echo "❌ El análisis estático falló. Corrige los errores antes de hacer commit."
    exit 1
fi

echo "Ejecutando tests..."
flutter test
if [ $? -ne 0 ]; then
    echo "❌ Los tests fallaron. Corrige los errores antes de hacer commit."
    exit 1
fi

echo "✅ Pre-commit checks pasaron"
EOF
    
    chmod +x .git/hooks/pre-commit
    print_success "Git hooks configurados"
fi

# Crear archivo de configuración de entorno de ejemplo
if [ ! -f ".env.example" ]; then
    print_status "Creando archivo de configuración de ejemplo..."
    cat > .env.example << 'EOF'
# Configuración de Stripe
STRIPE_PUBLISHABLE_KEY=pk_test_your_publishable_key_here
STRIPE_SECRET_KEY=sk_test_your_secret_key_here
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here

# Configuración de SendGrid
SENDGRID_API_KEY=SG.your_sendgrid_api_key_here

# Configuración de Google Maps
GOOGLE_MAPS_API_KEY=AIza_your_google_maps_api_key_here

# Configuración de Firebase (opcional, se puede usar firebase-config)
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_API_KEY=your_firebase_api_key

# Configuración de desarrollo
DEBUG_MODE=true
LOG_LEVEL=debug
EOF
    print_success "Archivo .env.example creado"
fi

# Verificar configuración final
print_status "Verificando configuración final..."
echo ""
echo "📱 Flutter version:"
flutter --version
echo ""
echo "🔥 Firebase CLI version:"
firebase --version
echo ""
echo "📦 Node.js version:"
node --version
echo ""
echo "📦 npm version:"
npm --version

echo ""
print_success "¡Configuración completada! 🎉"
echo ""
echo "📋 Próximos pasos:"
echo "1. Copia .env.example a .env y configura tus API keys"
echo "2. Configura Firebase: firebase login && firebase use --add"
echo "3. Ejecuta la aplicación: flutter run"
echo "4. Para Cloud Functions: cd functions && npm run serve"
echo ""
echo "📚 Comandos útiles:"
echo "• flutter doctor          - Verificar configuración de Flutter"
echo "• flutter analyze         - Análisis estático del código"
echo "• flutter test            - Ejecutar tests"
echo "• firebase emulators:start - Iniciar emuladores de Firebase"
echo ""
print_success "¡Feliz desarrollo! 🚀"