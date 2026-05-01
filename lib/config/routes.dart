import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/appointments_list_screen.dart';
import '../screens/booking/add_appointment_screen.dart';
import '../screens/booking/slot_booking_screen.dart';
import '../screens/booking/booking_confirm_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/analytics/analytics_dashboard_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/dev/debug_seeder_screen.dart';
import '../screens/providers/providers_list_screen.dart';
import '../screens/providers/provider_edit_screen.dart';
import '../screens/providers/provider_application_screen.dart';
import '../screens/providers/my_application_status_screen.dart';
import '../screens/providers/provider_dashboard_screen.dart';
import '../screens/providers/provider_slots_management_screen.dart';
import '../screens/providers/provider_bookings_screen.dart';
import '../screens/admin/admin_applications_screen.dart';

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
  static const String analytics = '/analytics';
  static const String providerApply = '/provider/apply';
  static const String myApplicationStatus = '/provider/my-application-status';
  static const String providerDashboard = '/provider/dashboard';
  static const String providerSlotsManagement = '/provider/slots-management';
  static const String providerBookings = '/provider/bookings';
  static const String adminApplications = '/admin/applications';

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
        analytics: (_) => const AnalyticsDashboardScreen(),
        '/dev/seeder': (_) => const DebugSeederScreen(),
        '/providers': (_) => const ProvidersListScreen(),
        '/providers/edit': (_) => const ProviderEditScreen(),
        providerApply: (_) => const ProviderApplicationScreen(),
        myApplicationStatus: (_) => const MyApplicationStatusScreen(),
        providerDashboard: (_) => const ProviderDashboardScreen(),
        providerSlotsManagement: (_) => const ProviderSlotsManagementScreen(),
        providerBookings: (_) => const ProviderBookingsScreen(),
        adminApplications: (_) => const AdminApplicationsScreen(),
      };
}
