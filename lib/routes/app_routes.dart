import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/screens/quotation_screen.dart';
import 'package:flutter_application_1/screens/transfer_screen.dart';
import 'package:flutter_application_1/screens/settings_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String quotation = '/quotation';
  static const String transfer = '/transfer';
  static const String settings = '/settings';
  
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    final routeName = routeSettings.name;
    switch (routeName) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case quotation:
        return MaterialPageRoute(builder: (_) => const QuotationScreen());
      case transfer:
        return MaterialPageRoute(builder: (_) => const TransferScreen());
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for $routeName'),
            ),
          ),
        );
    }
  }
}
