import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/appointments_list_screen.dart';
import '../screens/booking/add_appointment_screen.dart';
import '../screens/booking/slot_booking_screen.dart';
import '../screens/booking/booking_confirm_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/api/api_posts_screen.dart';
import '../screens/analytics/analytics_dashboard_screen.dart';
import '../screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String appointments = '/appointments';
  static const String addAppt = '/appointments/add';
  static const String editAppt = '/appointments/edit';
  static const String profile = '/profile';
  static const String booking = '/booking';
  static const String confirm = '/booking/confirm';
  static const String apiPosts = '/api-posts';
  static const String analytics = '/analytics';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),
        home: (_) => const HomeScreen(),
        appointments: (_) => const AppointmentsListScreen(),
        addAppt: (_) => const AddAppointmentScreen(),
        profile: (_) => const ProfileScreen(),
        booking: (_) => const SlotBookingScreen(),
        confirm: (_) => const BookingConfirmScreen(),
        apiPosts: (_) => const ApiPostsScreen(),
        analytics: (_) => const AnalyticsDashboardScreen(),
      };
}
