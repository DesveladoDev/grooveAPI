                                                                                                                                                                                                                                                                                                 # Salas and Beats - Flutter Application

## 📱 Overview

Salas and Beats is a Flutter application for booking music studios and rehearsal spaces. The app connects musicians with studio owners, providing a seamless booking experience with integrated payments and reviews.

## 🏗️ Architecture

### Project Structure

```
lib/
├── models/           # Data models and entities
├── services/         # Business logic and API calls
├── providers/        # State management (Provider pattern)
├── screens/          # UI screens and pages
├── widgets/          # Reusable UI components
├── utils/            # Utilities and constants
└── main.dart         # Application entry point
```

### Key Components

#### Models
- **ListingModel**: Represents studio/space listings
- **BookingModel**: Handles booking information
- **UserModel**: User profile and authentication data
- **ReviewModel**: User reviews and ratings
- **NotificationModel**: In-app notifications

#### Services
- **AuthService**: Authentication and user management
- **BookingService**: Booking operations and validation
- **StripeService**: Payment processing
- **AdminService**: Administrative operations
- **ReviewService**: Review and rating management

#### Providers
- **AuthProvider**: Authentication state management
- **BookingProvider**: Booking flow state
- **ListingProvider**: Listing data management
- **NotificationProvider**: Notification handling

## 🎯 Best Practices Implemented

### Code Organization

1. **Constants Management**
   - All hardcoded values moved to `utils/constants.dart`
   - Centralized configuration for UI dimensions, colors, and business rules
   - Easy maintenance and consistency across the app

2. **Documentation Standards**
   - Comprehensive dartdoc comments for all public APIs
   - Method parameters and return values documented
   - Usage examples provided for complex widgets

3. **Error Handling**
   - Specific exception types for different error scenarios
   - Input validation with meaningful error messages
   - Graceful degradation for network and service failures

### UI/UX Guidelines

1. **Consistent Theming**
   - Material Design 3 principles
   - Consistent spacing using `AppConstants`
   - Responsive design for different screen sizes

2. **Accessibility**
   - Semantic labels for screen readers
   - Sufficient color contrast ratios
   - Touch target sizes meet accessibility guidelines

3. **Performance**
   - Efficient widget rebuilds
   - Image optimization and caching
   - Lazy loading for large lists

### Security

1. **Data Validation**
   - Input sanitization and validation
   - Email format validation
   - Password strength requirements

2. **Authentication**
   - Firebase Authentication integration
   - Secure token handling
   - Role-based access control

## 🔧 Development Guidelines

### Adding New Features

1. **Create Models First**
   ```dart
   class NewFeatureModel {
     /// Brief description of the model
     final String id;
     final String name;

     const NewFeatureModel({
       required this.id,
       required this.name,
     });
   }
   ```

2. **Implement Service Layer**
   ```dart
   /// Service for handling [NewFeature] operations
   class NewFeatureService {
     /// Creates a new feature with validation
     Future<NewFeatureModel> createFeature({
       required String name,
     }) async {
       // Implementation with error handling
     }
   }
   ```

3. **Add Provider for State Management**
   ```dart
   /// Provider for managing [NewFeature] state
   class NewFeatureProvider extends ChangeNotifier {
     // State management implementation
   }
   ```

4. **Create UI Components**
   ```dart
   /// Widget for displaying [NewFeature] information
   class NewFeatureWidget extends StatelessWidget {
     /// Creates a new feature widget
     const NewFeatureWidget({Key? key}) : super(key: key);
   }
   ```

### Code Style

1. **Naming Conventions**
   - Use descriptive names for variables and methods
   - Follow Dart naming conventions (camelCase for variables, PascalCase for classes)
   - Prefix private members with underscore

2. **File Organization**
   - One class per file
   - Group related functionality in directories
   - Use barrel exports for clean imports

3. **Comments and Documentation**
   - Document all public APIs
   - Use `///` for dartdoc comments
   - Include usage examples for complex components

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Firebase project setup
- Stripe account for payments

### Installation

1. Clone the repository
2. Install dependencies: `flutter pub get`
3. Configure Firebase (follow Firebase setup guide)
4. Set up Stripe keys in environment variables
5. Run the app: `flutter run`

### Environment Setup

Create a `.env` file with:
```
STRIPE_PUBLISHABLE_KEY=your_stripe_key
FIREBASE_PROJECT_ID=your_project_id
```

## 📚 Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase for Flutter](https://firebase.flutter.dev/)
- [Stripe Flutter SDK](https://stripe.com/docs/payments/accept-a-payment?platform=flutter)
- [Material Design 3](https://m3.material.io/)

## 🤝 Contributing

1. Follow the established code style and patterns
2. Add tests for new functionality
3. Update documentation for API changes
4. Ensure all validations and error handling are in place
5. Test on multiple devices and screen sizes

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
