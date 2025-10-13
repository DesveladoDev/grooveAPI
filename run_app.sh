#!/bin/bash

# Script para ejecutar la aplicación Salas and Beats

echo "🚀 Iniciando aplicación Salas and Beats..."

# Limpiar proyecto
echo "🧹 Limpiando proyecto..."
flutter clean

# Obtener dependencias
echo "📦 Obteniendo dependencias..."
flutter pub get

# Verificar estado de Flutter
echo "🔍 Verificando Flutter..."
flutter doctor

# Intentar ejecutar en Chrome
echo "🌐 Ejecutando en Chrome..."
flutter run -d chrome --web-renderer html

echo "✅ Script completado"