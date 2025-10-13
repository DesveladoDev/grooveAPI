import 'package:flutter/material.dart';
import 'package:salas_beats/models/chat_model.dart';
import 'package:salas_beats/screens/admin/admin_dashboard_screen.dart';
import 'package:salas_beats/screens/auth/forgot_password_screen.dart';
import 'package:salas_beats/screens/auth/login_screen.dart';
import 'package:salas_beats/screens/auth/register_screen.dart';
import 'package:salas_beats/screens/booking/booking_confirmation_screen.dart';
// import '../screens/listing/listing_detail_screen.dart';
import 'package:salas_beats/screens/booking/booking_screen.dart';
import 'package:salas_beats/screens/booking/my_bookings_screen.dart';
import 'package:salas_beats/screens/chat_list_screen.dart';
import 'package:salas_beats/screens/chat_room_screen.dart';
import 'package:salas_beats/screens/create_listing_screen.dart';
import 'package:salas_beats/screens/edit_listing_screen.dart';
import 'package:salas_beats/screens/explore/explore_screen.dart';
import 'package:salas_beats/screens/help_center_screen.dart';
import 'package:salas_beats/screens/home_screen.dart';
import 'package:salas_beats/screens/host/host_dashboard_screen.dart';
import 'package:salas_beats/screens/host_calendar_screen.dart';
import 'package:salas_beats/screens/listing_detail_screen.dart';
import 'package:salas_beats/screens/notifications_screen.dart';
import 'package:salas_beats/screens/onboarding/onboarding_screen.dart';
import 'package:salas_beats/screens/profile/edit_profile_screen.dart';
import 'package:salas_beats/screens/profile_screen.dart';
import 'package:salas_beats/screens/review_create_screen.dart';
import 'package:salas_beats/screens/review_list_screen.dart';
import 'package:salas_beats/screens/settings/settings_screen.dart';
import 'package:salas_beats/screens/splash_screen.dart';

class AppRoutes {
  // Rutas principales
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String explore = '/explore';
  
  // Rutas de listings
  static const String listingDetail = '/listing-detail';
  
  // Rutas de reservas
  static const String booking = '/booking';
  static const String bookingConfirmation = '/booking-confirmation';
  static const String myBookings = '/my-bookings';
  
  // Rutas de anfitrión
  static const String hostDashboard = '/host-dashboard';
  static const String createListing = '/create-listing';
  static const String editListing = '/edit-listing';
  static const String hostCalendar = '/host-calendar';
  
  // Rutas de chat
  static const String chat = '/chat';
  static const String chatList = '/chat-list';
  static const String chatRoom = '/chat-room';
  
  // Rutas de perfil
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  
  // Rutas adicionales
  static const String bookings = '/bookings';
  static const String bookingDetail = '/booking-detail';
  static const String notifications = '/notifications';
  static const String favorites = '/favorites';
  static const String paymentMethods = '/payment-methods';
  static const String support = '/support';
  static const String privacyPolicy = '/privacy-policy';
  static const String termsOfService = '/terms-of-service';
  static const String hostListings = '/host-listings';
  static const String hostEarnings = '/host-earnings';
  static const String settings = '/settings';

  
  // Rutas de administración
  static const String adminDashboard = '/admin-dashboard';
  
  // Rutas de configuración
  static const String helpCenter = '/help-center';
  
  // Rutas de reseñas
  static const String reviewCreate = '/review-create';
  static const String reviewList = '/review-list';
  
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
        
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
        
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
        
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
        
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
        
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
        
      case explore:
        return MaterialPageRoute(builder: (_) => const ExploreScreen());
        
      case listingDetail:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        final listingId = args?['listingId'] as String?;
        if (listingId == null) {
          return _errorRoute('Listing ID requerido');
        }
        return MaterialPageRoute(
          builder: (_) => ListingDetailScreen(listingId: listingId),
        );
        
      case booking:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        if (args == null || !args.containsKey('listingId')) {
          return _errorRoute('Listing ID is required for booking');
        }
        return MaterialPageRoute(
          builder: (context) => BookingScreen(listingId: args['listingId'] as String),
        );
        
      case bookingConfirmation:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        if (args == null) {
          return _errorRoute('Datos de reserva requeridos');
        }
        return MaterialPageRoute(
          builder: (_) => BookingConfirmationScreen(data: args),
        );
        
      case myBookings:
        return MaterialPageRoute(builder: (_) => const MyBookingsScreen());
        
      case hostDashboard:
        return MaterialPageRoute(builder: (_) => const HostDashboardScreen());
        
      case createListing:
        return MaterialPageRoute(builder: (_) => const CreateListingScreen());
        
      case editListing:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        final listingId = args?['listingId'] as String?;
        if (listingId == null) {
          return _errorRoute('Listing ID requerido');
        }
        return MaterialPageRoute(
          builder: (_) => EditListingScreen(listingId: listingId),
        );
        
      case hostCalendar:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        final listingId = args?['listingId'] as String?;
        return MaterialPageRoute(
          builder: (_) => HostCalendarScreen(listingId: listingId),
        );
        
      case chat:
        return MaterialPageRoute(builder: (_) => const ChatListScreen());
        
      case chatList:
        return MaterialPageRoute(builder: (_) => const ChatListScreen());
        
      case chatRoom:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        final chatRoomData = args?['chatRoom'];
        if (chatRoomData == null) {
          return _errorRoute('Chat room requerido');
        }
        final chatRoom = ChatRoom.fromMap(chatRoomData as Map<String, dynamic>, (chatRoomData['id'] as String?) ?? '');
        return MaterialPageRoute(
          builder: (_) => ChatRoomScreen(chatRoom: chatRoom),
        );
        
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
        
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
        
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
        
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
        
      case helpCenter:
        return MaterialPageRoute(builder: (_) => const HelpCenterScreen());
        
      case reviewCreate:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        final bookingId = args?['bookingId'] as String?;
        if (bookingId == null) {
          return _errorRoute('Booking ID requerido');
        }
        return MaterialPageRoute(
          builder: (_) => ReviewCreateScreen(
            bookingId: bookingId,
            listingId: args?['listingId'] as String? ?? '',
            toUserId: args?['toUserId'] as String? ?? '',
            toUserName: args?['toUserName'] as String?,
            listingTitle: args?['listingTitle'] as String?,
          ),
        );
        
      case reviewList:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        final userId = args?['userId'] as String?;
        final listingId = args?['listingId'] as String?;
        return MaterialPageRoute(
          builder: (_) => ReviewListScreen(
            userId: userId,
            listingId: listingId,
            title: args?['title'] as String? ?? 'Reseñas',
          ),
        );
        
      case notifications:
        return MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
        );
        
      default:
        return _errorRoute('Ruta no encontrada: ${routeSettings.name}');
    }
  }
  
  static Route<dynamic> _errorRoute(String message) => MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(_).pushNamedAndRemoveUntil(
                  home,
                  (route) => false,
                ),
                child: const Text('Ir al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
}