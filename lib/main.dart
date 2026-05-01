import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/slots_provider.dart';
import 'services/notification_service.dart';
import 'services/fcm_service.dart';

// Global navigator key — required for notification tap navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Share navigator key with notification service
  globalNavigatorKey = navigatorKey;

  // Push/local notifications are mobile-only in this app setup.
  if (!kIsWeb) {
    await NotificationService.init();
    await FcmService.init();
  }

  runApp(const AppointmentApp());
}


class AppointmentApp extends StatelessWidget {
  const AppointmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => AuthProvider()..checkSession()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => SlotsProvider()),
      ],
      child: MaterialApp(
        title: 'Appointment App',
        navigatorKey: navigatorKey,
        theme: AppTheme.theme,
        routes: AppRoutes.routes,
        initialRoute: AppRoutes.splash,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
