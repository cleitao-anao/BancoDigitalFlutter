import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/signup_screen.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/screens/settings_screen.dart';
import 'package:flutter_application_1/screens/quotation_screen.dart';

const String loginRoute = '/login';
const String signupRoute = '/signup';
const String homeRoute = '/home';
const String settingsRoute = '/settings';
const String quotationRoute = '/quotation';

final Map<String, WidgetBuilder> appRoutes = {
  loginRoute: (context) => const LoginScreen(),
  signupRoute: (context) => const SignUpScreen(),
  homeRoute: (context) => const HomeScreen(),
  settingsRoute: (context) => const SettingsScreen(),
  quotationRoute: (context) => const QuotationScreen(),
};
