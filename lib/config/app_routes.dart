import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/signup_screen.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/screens/settings_screen.dart';
import 'package:flutter_application_1/screens/quotation_screen.dart';
import 'package:flutter_application_1/screens/pix/pix_home_screen.dart';
import 'package:flutter_application_1/screens/pix/pix_transfer_screen.dart';
import 'package:flutter_application_1/screens/pix/pix_keys_screen.dart';
import 'package:flutter_application_1/screens/pix/add_pix_key_screen.dart';
import 'package:flutter_application_1/screens/pix/pix_history_screen.dart';
import 'package:flutter_application_1/screens/investment_screen.dart';

// Rotas principais
const String loginRoute = '/login';
const String signupRoute = '/signup';
const String homeRoute = '/home';
const String settingsRoute = '/settings';
const String quotationRoute = '/quotation';
const String investmentRoute = '/investment';

// Rotas do PIX
const String pixHomeRoute = '/pix/home';
const String pixTransferRoute = '/pix/transfer';
const String pixKeysRoute = '/pix/keys';
const String addPixKeyRoute = '/pix/keys/add';
const String pixHistoryRoute = '/pix/history';

final Map<String, WidgetBuilder> appRoutes = {
  // Rotas principais
  loginRoute: (context) => const LoginScreen(),
  signupRoute: (context) => const SignUpScreen(),
  homeRoute: (context) => const HomeScreen(),
  settingsRoute: (context) => const SettingsScreen(),
  quotationRoute: (context) => const QuotationScreen(),
  investmentRoute: (context) => const InvestmentScreen(),
  
  // Rotas do PIX
  pixHomeRoute: (context) => const PixHomeScreen(),
  pixTransferRoute: (context) => const PixTransferScreen(),
  pixKeysRoute: (context) => const PixKeysScreen(),
  addPixKeyRoute: (context) => const AddPixKeyScreen(),
  pixHistoryRoute: (context) => const PixHistoryScreen(),
};
