import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/screens/quotation_screen.dart';
import 'package:flutter_application_1/screens/transfer_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String quotation = '/quotation';
  static const String transfer = '/transfer';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case quotation:
        return MaterialPageRoute(builder: (_) => const QuotationScreen());
      case transfer:
        return MaterialPageRoute(builder: (_) => const TransferScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
