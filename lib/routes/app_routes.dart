import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/screens/quotation_screen.dart';
import 'package:flutter_application_1/screens/settings_screen.dart';
import 'package:flutter_application_1/screens/pix/pix_home_screen.dart';
import 'package:flutter_application_1/screens/pix/pix_transfer_screen.dart';
import 'package:flutter_application_1/screens/pix/pix_keys_screen.dart';
import 'package:flutter_application_1/screens/pix/add_pix_key_screen.dart';
import 'package:flutter_application_1/screens/pix/pix_history_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String quotation = '/quotation';
  static const String settings = '/settings';
  static const String pixHome = '/pix/home';
  static const String pixTransfer = '/pix/transfer';
  static const String pixKeys = '/pix/keys';
  static const String addPixKey = '/pix/keys/add';
  static const String pixHistory = '/pix/history';
  
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    final routeName = routeSettings.name;
    switch (routeName) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case quotation:
        return MaterialPageRoute(builder: (_) => const QuotationScreen());
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case pixHome:
        return MaterialPageRoute(builder: (_) => const PixHomeScreen());
      case pixTransfer:
        return MaterialPageRoute(builder: (_) => const PixTransferScreen());
      case pixKeys:
        return MaterialPageRoute(builder: (_) => const PixKeysScreen());
      case addPixKey:
        return MaterialPageRoute(builder: (_) => const AddPixKeyScreen());
      case pixHistory:
        return MaterialPageRoute(builder: (_) => const PixHistoryScreen());
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
