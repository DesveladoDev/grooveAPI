# Salas and Beats 🎵

Una aplicación móvil que conecta músicos con propietarios de salas de ensayo, facilitando el alquiler de espacios musicales por horas.

## 📱 Características Principales

### Para Músicos (Huéspedes)
- 🔍 **Explorar salas** - Busca y filtra salas de ensayo cercanas
- 📅 **Reservas fáciles** - Sistema de reservas con calendario integrado
- 💳 **Pagos seguros** - Procesamiento de pagos con Stripe
- ⭐ **Reseñas** - Sistema de calificaciones y comentarios
- 💬 **Chat integrado** - Comunicación directa con anfitriones
- 🔔 **Notificaciones** - Alertas sobre reservas y mensajes

### Para Anfitriones
- 🏠 **Gestión de espacios** - Administra tus salas de ensayo
- 📊 **Panel de control** - Estadísticas y reportes de ingresos
- 💰 **Pagos automáticos** - Recibe pagos directamente con Stripe Connect
- 📋 **Gestión de reservas** - Calendario y administración de bookings
- 🛡️ **Verificación** - Sistema de verificación de identidad

### Para Administradores
- 📈 **Dashboard completo** - KPIs y métricas de la plataforma
- 👥 **Gestión de usuarios** - Administración de cuentas y verificaciones
- 💼 **Reportes financieros** - Análisis de comisiones y transacciones
- 🔧 **Configuración** - Ajustes globales de la aplicación

## 🏗️ Arquitectura Técnica

### Frontend (Flutter)
```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── models/                   # Modelos de datos
│   ├── user_model.dart
│   ├── listing_model.dart
│   ├── booking_model.dart
│   ├── chat_model.dart
│   ├── review_model.dart
│   └── notification_model.dart
├── providers/                # Gestión de estado con Provider
│   ├── auth_provider.dart
│   ├── booking_provider.dart
│   ├── chat_provider.dart
│   ├── review_provider.dart
│   └── notification_provider.dart
├── screens/                  # Pantallas de la aplicación
│   ├── auth/
│   ├── booking/
│   ├── admin/
│   └── host/
├── services/                 # Servicios de backend
│   ├── auth_service.dart
│   ├── booking_service.dart
│   ├── stripe_service.dart
│   ├── chat_service.dart
│   ├── review_service.dart
│   └── notification_service.dart
├── widgets/                  # Componentes reutilizables
│   ├── booking/
│   ├── chat/
│   ├── review/
│   └── notification/
└── utils/                    # Utilidades y configuración
    ├── app_routes.dart
    └── app_theme.dart
```

### Backend (Firebase)
- **Authentication:** Firebase Auth con múltiples proveedores
- **Database:** Cloud Firestore con reglas de seguridad
- **Storage:** Firebase Storage para imágenes y documentos
- **Functions:** Cloud Functions para lógica de negocio
- **Messaging:** Firebase Cloud Messaging para notificaciones

### Servicios Externos
- **Stripe Connect Express:** Procesamiento de pagos y onboarding
- **Google Maps:** Geolocalización y mapas
- **SendGrid:** Emails transaccionales

## 🚀 Instalación y Configuración

### Prerrequisitos
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / Xcode
- Node.js (para Cloud Functions)
- Cuenta de Firebase
- Cuenta de Stripe

### Configuración del Proyecto

1. **Clonar el repositorio**
```bash
git clone https://github.com/tu-usuario/salas-and-beats.git
cd salas-and-beats
```

2. **Instalar dependencias de Flutter**
```bash
flutter pub get
```

3. **Configurar Firebase**
```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Inicializar Firebase
firebase login
firebase init
```

4. **Configurar Cloud Functions**
```bash
cd functions
npm install
```

5. **Variables de entorno**
Crea un archivo `.env` en la raíz del proyecto:
```env
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
SENDGRID_API_KEY=SG...
GOOGLE_MAPS_API_KEY=AIza...
```

6. **Ejecutar la aplicación**
```bash
flutter run
```

## 🔧 Configuración de Firebase

### Firestore Database
```javascript
// Estructura de colecciones principales
users/
  {userId}/
    - email, displayName, isHost, createdAt
    private/
      - stripeCustomerId, fcmTokens
    stats/
      - totalBookings, totalEarnings

listings/
  {listingId}/
    - title, description, price, hostId
    availability/
      - date, timeSlots, isAvailable
    stats/
      - totalBookings, averageRating

bookings/
  {bookingId}/
    - guestId, hostId, listingId, status
    payments/
      - stripePaymentIntentId, amount, status

chats/
  {chatId}/
    - participants, lastMessage, updatedAt
    messages/
      - senderId, content, timestamp, type

reviews/
  {reviewId}/
    - reviewerId, reviewedId, rating, comment

notifications/
  {notificationId}/
    - userId, title, body, type, isRead
```

### Security Rules
Las reglas de seguridad están definidas en `firestore.rules` y `storage.rules`.

### Cloud Functions
```javascript
// Funciones principales
functions/src/
├── index.ts              # Exportación de funciones
├── payments.ts           # Procesamiento de pagos
├── bookings.ts           # Lógica de reservas
├── notifications.ts      # Envío de notificaciones
├── webhooks.ts           # Webhooks de Stripe
├── hosts.ts              # Onboarding de anfitriones
├── commissions.ts        # Cálculo de comisiones
└── admin.ts              # Funciones administrativas
```

## 💳 Integración con Stripe

### Configuración de Stripe Connect
1. **Crear cuenta de Stripe**
2. **Configurar Stripe Connect Express**
3. **Configurar webhooks**
4. **Implementar onboarding de anfitriones**

### Flujo de Pagos
1. Huésped selecciona sala y horario
2. Se crea PaymentIntent en Stripe
3. Huésped completa el pago
4. Webhook confirma el pago
5. Se confirma la reserva
6. Se transfiere el pago al anfitrión (menos comisiones)

## 📱 Funcionalidades por Pantalla

### Autenticación
- Login/Registro con email
- Autenticación con Google/Apple
- Recuperación de contraseña
- Verificación de email

### Explorar
- Lista de salas disponibles
- Filtros por ubicación, precio, características
- Mapa interactivo
- Búsqueda por texto

### Detalle de Sala
- Galería de imágenes
- Descripción y características
- Calendario de disponibilidad
- Reseñas y calificaciones
- Proceso de reserva

### Reservas
- Lista de reservas activas
- Historial de reservas
- Detalles de cada reserva
- Cancelaciones y modificaciones

### Chat
- Lista de conversaciones
- Chat en tiempo real
- Envío de imágenes
- Notificaciones push

### Perfil
- Información personal
- Configuración de cuenta
- Historial de actividad
- Configuración de notificaciones

## 🔔 Sistema de Notificaciones

### Tipos de Notificaciones
- **Reservas:** Confirmaciones, recordatorios, cancelaciones
- **Pagos:** Confirmaciones de pago, transferencias
- **Chat:** Nuevos mensajes
- **Reseñas:** Nuevas reseñas recibidas
- **Sistema:** Actualizaciones importantes

### Canales de Notificación
- Push notifications (FCM)
- Notificaciones in-app
- Emails (SendGrid)
- SMS (opcional)

## 📊 Analytics y Métricas

### KPIs Principales
- Usuarios activos (DAU/MAU)
- Tasa de conversión de reservas
- Ingresos por comisiones
- Tiempo promedio de respuesta
- Calificación promedio de la plataforma

### Reportes Disponibles
- Reporte financiero mensual
- Análisis de comportamiento de usuarios
- Métricas de satisfacción
- Reporte de incidencias

## 🛡️ Seguridad

### Medidas Implementadas
- Autenticación multifactor (opcional)
- Encriptación de datos sensibles
- Validación de entrada en frontend y backend
- Rate limiting en APIs
- Monitoreo de actividad sospechosa

### Cumplimiento
- GDPR (Unión Europea)
- CCPA (California)
- PCI DSS (para pagos)
- Políticas de privacidad y términos de servicio

## 🧪 Testing

### Tipos de Tests
```bash
# Tests unitarios
flutter test

# Tests de integración
flutter test integration_test/

# Tests de widgets
flutter test test/widget_test.dart

# Tests de Cloud Functions
cd functions && npm test
```

### Cobertura de Tests
- Modelos de datos
- Servicios principales
- Widgets críticos
- Flujos de usuario principales

## 🚀 Deployment

### Ambientes
- **Development:** Firebase proyecto de desarrollo
- **Staging:** Firebase proyecto de staging
- **Production:** Firebase proyecto de producción

### CI/CD Pipeline
```yaml
# GitHub Actions workflow
name: Build and Deploy
on:
  push:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter test
  
  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Firebase
        run: firebase deploy
```

### Distribución
- **Android:** Google Play Store
- **iOS:** Apple App Store
- **Web:** Firebase Hosting (opcional)

## 📚 Documentación Adicional

- [Guía de Contribución](CONTRIBUTING.md)
- [Política de Privacidad](PRIVACY_POLICY.md)
- [Términos de Servicio](TERMS_OF_SERVICE.md)
- [Changelog](CHANGELOG.md)
- [API Documentation](docs/api.md)

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

## 👥 Equipo

- **Desarrollo:** [Tu Nombre]
- **Diseño UX/UI:** [Diseñador]
- **Product Manager:** [PM]
- **QA:** [Tester]

## 📞 Soporte

- **Email:** support@salasandbeats.com
- **Discord:** [Servidor de Discord]
- **Documentación:** [docs.salasandbeats.com]

---

**¡Gracias por contribuir a la comunidad musical! 🎵**