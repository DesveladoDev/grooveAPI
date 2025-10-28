import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:salas_beats/providers/auth_provider.dart';
import 'package:salas_beats/services/auth_service.dart';
import 'package:salas_beats/screens/admin/admin_dashboard_screen.dart';
import 'package:salas_beats/screens/admin/admin_listings_screen.dart';
import 'package:salas_beats/screens/admin/admin_users_screen.dart';
import 'package:salas_beats/screens/auth/forgot_password_screen.dart';
import 'package:salas_beats/screens/auth/login_screen.dart';
import 'package:salas_beats/screens/auth/register_screen.dart';
import 'package:salas_beats/screens/booking/booking_confirmation_screen.dart';
// import '../screens/home/home_screen.dart';
// import '../screens/search/search_screen.dart';
// import '../screens/search/search_results_screen.dart';
// import '../screens/listing/listing_detail_screen.dart';
// import '../screens/listing/create_listing_screen.dart';
// import '../screens/listing/create_listing_screen.dart';
// import '../screens/listing/edit_listing_screen.dart';
import 'package:salas_beats/screens/booking/booking_screen.dart';
import 'package:salas_beats/screens/home_screen.dart';
// import '../screens/booking/booking_history_screen.dart';
// import '../screens/profile/profile_screen.dart';
// import '../screens/profile/edit_profile_screen.dart';
import 'package:salas_beats/screens/host/host_dashboard_screen.dart';
// import '../screens/host/host_earnings_screen.dart';
// import '../screens/host/host_listings_screen.dart';
// import '../screens/host/host_bookings_screen.dart';
// import '../screens/host/become_host_screen.dart';
// import '../screens/messages/messages_screen.dart';
import 'package:salas_beats/screens/messages/chat_screen.dart';
import 'package:salas_beats/screens/notifications/notifications_screen.dart';
import 'package:salas_beats/screens/onboarding/onboarding_screen.dart';
import 'package:salas_beats/screens/onboarding/role_selection_screen.dart';
import 'package:salas_beats/screens/settings/notification_settings_screen.dart';
import 'package:salas_beats/screens/settings/privacy_settings_screen.dart';
// import '../screens/admin/admin_bookings_screen.dart';
// import '../screens/admin/admin_reports_screen.dart';
import 'package:salas_beats/screens/settings/settings_screen.dart';
import 'package:salas_beats/screens/splash/splash_screen.dart';
import 'package:salas_beats/screens/explore_screen.dart';
import 'package:salas_beats/screens/bookings_screen.dart';
import 'package:salas_beats/screens/chat_list_screen.dart';
import 'package:salas_beats/screens/profile_screen.dart';

// Adaptador local para refrescar GoRouter con cambios en un Stream
// Evita depender de GoRouterRefreshStream si no está disponible en la versión instalada
class StreamListenable<T> extends ChangeNotifier {
  late final StreamSubscription<T> _subscription;

  StreamListenable(Stream<T> stream) {
    _subscription = stream.listen(
      (_) => notifyListeners(),
      onError: (_) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String roleSelection = '/role-selection';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerification = '/email-verification';
  static const String profileCompletion = '/profile-completion';
  static const String home = '/home';
  static const String explore = '/explore';
  static const String search = '/search';
  static const String searchResults = '/search/results';
  static const String listingDetail = '/listing/:id';
  static const String createListing = '/listing/create';
  static const String editListing = '/listing/:id/edit';
  static const String booking = '/booking/:listingId';
  static const String payment = '/payment';
  static const String bookingDetail = '/booking/detail/:bookingId';
  static const String bookingConfirmation = '/booking/confirmation/:bookingId';
  static const String bookingHistory = '/bookings';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String hostDashboard = '/host/dashboard';
  static const String hostEarnings = '/host/earnings';
  static const String hostListings = '/host/listings';
  static const String hostBookings = '/host/bookings';
  static const String hostOnboarding = '/host/onboarding';
  static const String becomeHost = '/become-host';
  static const String messages = '/messages';
  static const String chatList = '/chat-list';
  static const String chat = '/messages/:chatId';
  static const String chatRoom = '/chat/:chatRoomId';
  static const String notifications = '/notifications';
  static const String reviewList = '/reviews';
  static const String favorites = '/favorites';
  static const String paymentMethods = '/payment-methods';
  static const String privacyPolicy = '/privacy-policy';
  static const String termsOfService = '/terms-of-service';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminListings = '/admin/listings';
  static const String adminBookings = '/admin/bookings';
  static const String adminReports = '/admin/reports';
  static const String settings = '/settings';
  static const String privacySettings = '/settings/privacy';
  static const String notificationSettings = '/settings/notifications';
  static const String support = '/support';

  static GoRouter createRouter() => GoRouter(
      initialLocation: splash,
      // Forzar que GoRouter re-evalúe "redirect" cuando cambie el estado de autenticación
      // para evitar que la app quede en la pantalla de login hasta recompilar.
      refreshListenable: StreamListenable(AuthService().authStateChanges),
      redirect: (context, state) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final isLoggedIn = authProvider.isAuthenticated;
        final isOnboardingComplete = authProvider.user?.isOnboardingComplete ?? false;
        final isGuestUser = authProvider.isGuestUser;
        
        // Handle splash screen
        if (state.matchedLocation == splash) {
          return null; // Allow splash screen
        }
        
        // If already logged in and currently on any auth-related screen, redirect appropriately
        if (isLoggedIn) {
          final isAuthRoute =
              state.matchedLocation == login ||
              state.matchedLocation == register ||
              state.matchedLocation == forgotPassword;
          if (isAuthRoute) {
            if (isGuestUser) {
              return roleSelection; // Redirect guest users to role selection
            }
            return isOnboardingComplete ? home : onboarding;
          }
        }
        
        // Handle authentication redirects
        if (!isLoggedIn) {
          if (state.matchedLocation.startsWith('/auth') || 
              state.matchedLocation == login || 
              state.matchedLocation == register || 
              state.matchedLocation == forgotPassword ||
              state.matchedLocation == onboarding ||
              state.matchedLocation == roleSelection) {
            return null; // Allow auth screens
          }
          return login; // Redirect to login
        }
        
        // Handle role selection for guest users
        if (isLoggedIn && isGuestUser && state.matchedLocation != roleSelection) {
          return roleSelection;
        }
        
        // Handle onboarding
        if (isLoggedIn && !isOnboardingComplete && !isGuestUser && state.matchedLocation != onboarding) {
          return onboarding;
        }
        
        // Handle admin routes
        if (state.matchedLocation.startsWith('/admin')) {
          final isAdmin = authProvider.user?.role == 'admin';
          if (!isAdmin) {
            return home; // Redirect non-admins to home
          }
        }
        
        // Handle host routes
        if (state.matchedLocation.startsWith('/host')) {
          final isHost = authProvider.user?.role == 'host' || authProvider.user?.role == 'admin';
          if (!isHost && state.matchedLocation != becomeHost) {
            return becomeHost; // Redirect to become host
          }
        }
        
        return null; // No redirect needed
      },
      routes: [
        // Splash and Onboarding
        GoRoute(
          path: splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: roleSelection,
          builder: (context, state) => const RoleSelectionScreen(),
        ),
        
        // Authentication routes
        GoRoute(
          path: login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: register,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: forgotPassword,
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        
        // Main app routes
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.explore,
          builder: (context, state) => const ExploreScreen(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: AppRoutes.chatList,
          builder: (context, state) => const ChatListScreen(),
        ),
        // GoRoute(
        //   path: search,
        //   builder: (context, state) => const SearchScreen(),
        // ),
        // GoRoute(
        //   path: searchResults,
        //   builder: (context, state) {
        //     final query = state.uri.queryParameters['q'] ?? '';
        //     final location = state.uri.queryParameters['location'] ?? '';
        //     final category = state.uri.queryParameters['category'] ?? '';
        //     return SearchResultsScreen(
        //       query: query,
        //       location: location,
        //       category: category,
        //     );
        //   },
        // ),
        
        // Listing routes
        // GoRoute(
        //   path: listingDetail,
        //   builder: (context, state) {
        //     final listingId = state.pathParameters['id']!;
        //     return ListingDetailScreen(listingId: listingId);
        //   },
        // ),
        // GoRoute(
        //   path: createListing,
        //   builder: (context, state) => const CreateListingScreen(),
        // ),
        // GoRoute(
        //   path: editListing,
        //   builder: (context, state) {
        //     final listingId = state.pathParameters['id']!;
        //     return EditListingScreen(listingId: listingId);
        //   },
        // ),
        
        // Booking routes
        GoRoute(
          path: booking,
          builder: (context, state) {
            final listingId = state.pathParameters['listingId']!;
            return BookingScreen(listingId: listingId);
          },
        ),
        // GoRoute(
        //   path: payment,
        //   builder: (context, state) {
        //     final bookingData = state.extra as Map<String, dynamic>;
        //     return PaymentScreen(bookingData: bookingData);
        //   },
        // ),
        GoRoute(
          path: bookingConfirmation,
          builder: (context, state) {
            final bookingId = state.pathParameters['bookingId']!;
            return BookingConfirmationScreen(data: {'bookingId': bookingId});
          },
        ),
        GoRoute(
          path: bookingHistory,
          builder: (context, state) => const BookingsScreen(),
        ),
        
        // Profile routes
        // GoRoute(
        //   path: profile,
        //   builder: (context, state) => const ProfileScreen(),
        // ),
        // GoRoute(
        //   path: editProfile,
        //   builder: (context, state) => const EditProfileScreen(),
        // ),
        
        // Host routes
        GoRoute(
          path: hostDashboard,
          builder: (context, state) => const HostDashboardScreen(),
        ),
        // GoRoute(
        //   path: hostEarnings,
        //   builder: (context, state) => const HostEarningsScreen(),
        // ),
        // GoRoute(
        //   path: hostListings,
        //   builder: (context, state) => const HostListingsScreen(),
        // ),
        // GoRoute(
        //   path: hostBookings,
        //   builder: (context, state) => const HostBookingsScreen(),
        // ),
        // GoRoute(
        //   path: becomeHost,
        //   builder: (context, state) => const BecomeHostScreen(),
        // ),
        
        // Messages routes
        // GoRoute(
        //   path: messages,
        //   builder: (context, state) => const MessagesScreen(),
        // ),
        GoRoute(
          path: chat,
          builder: (context, state) {
            final chatId = state.pathParameters['chatId']!;
            final otherUserId = state.uri.queryParameters['otherUserId'] ?? '';
            final otherUserName = state.uri.queryParameters['otherUserName'] ?? 'Usuario';
            final otherUserAvatar = state.uri.queryParameters['otherUserAvatar'];
            return ChatScreen(
              chatId: chatId,
              otherUserId: otherUserId,
              otherUserName: otherUserName,
              otherUserAvatar: otherUserAvatar,
            );
          },
        ),
        
        // Notifications
        GoRoute(
          path: notifications,
          builder: (context, state) => const NotificationsScreen(),
        ),
        
        // Admin routes
        GoRoute(
          path: adminDashboard,
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: adminUsers,
          builder: (context, state) => const AdminUsersScreen(),
        ),
        GoRoute(
          path: adminListings,
          builder: (context, state) => const AdminListingsScreen(),
        ),
        // GoRoute(
        //   path: adminBookings,
        //   builder: (context, state) => const AdminBookingsScreen(),
        // ),
        // GoRoute(
        //   path: adminReports,
        //   builder: (context, state) => const AdminReportsScreen(),
        // ),
        
        // Settings routes
        GoRoute(
          path: settings,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: privacySettings,
          builder: (context, state) => const PrivacySettingsScreen(),
        ),
        GoRoute(
          path: notificationSettings,
          builder: (context, state) => const NotificationSettingsScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
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
                'Página no encontrada',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'La página que buscas no existe.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(home),
                child: const Text('Ir al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
}

// Extension for easier navigation
extension GoRouterExtension on GoRouter {
  void pushAndClearStack(String location) {
    while (canPop()) {
      pop();
    }
    pushReplacement(location);
  }
}

// Navigation helper class
class NavigationHelper {
  static void goToListing(BuildContext context, String listingId) {
    context.go('/listing/$listingId');
  }
  
  static void goToBooking(BuildContext context, String listingId) {
    context.go('/booking/$listingId');
  }
  
  static void goToChat(BuildContext context, String chatId) {
    context.go('/messages/$chatId');
  }
  
  static void goToEditListing(BuildContext context, String listingId) {
    context.go('/listing/$listingId/edit');
  }
  
  static void goToBookingConfirmation(BuildContext context, String bookingId) {
    context.go('/booking/confirmation/$bookingId');
  }
  
  static void goToSearchResults(BuildContext context, {
    String? query,
    String? location,
    String? category,
  }) {
    final params = <String, String>{};
    if (query != null && query.isNotEmpty) params['q'] = query;
    if (location != null && location.isNotEmpty) params['location'] = location;
    if (category != null && category.isNotEmpty) params['category'] = category;
    
    final uri = Uri(path: '/search/results', queryParameters: params.isNotEmpty ? params : null);
    context.go(uri.toString());
  }
}