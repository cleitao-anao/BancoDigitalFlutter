import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Classe responsável por gerenciar os temas da aplicação
///
/// Fornece temas claro e escuro, além de gerenciar a preferência
/// do usuário entre os modos de tema.
class AppTheme {
  // Constantes para valores reutilizáveis
  static const double _defaultBorderRadius = 12.0;
  static const double _cardBorderRadius = 16.0;
  static const double _buttonBorderRadius = 12.0;
  static const double _cardElevation = 2.0;
  static const double _fabElevation = 4.0;
  static const double _dividerThickness = 1.0;
  
  // Padding padrão
  static const EdgeInsets _defaultPadding = EdgeInsets.symmetric(vertical: 16, horizontal: 24);
  static const EdgeInsets _compactPadding = EdgeInsets.symmetric(vertical: 12, horizontal: 16);
  static const EdgeInsets _inputPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  static const EdgeInsets _cardMargin = EdgeInsets.symmetric(vertical: 8, horizontal: 16);
  
  // Tamanhos de fonte
  static const double _displayLargeSize = 32.0;
  static const double _displayMediumSize = 28.0;
  static const double _displaySmallSize = 24.0;
  static const double _headlineMediumSize = 22.0;
  static const double _headlineSmallSize = 20.0;
  static const double _titleLargeSize = 18.0;
  static const double _bodyLargeSize = 16.0;
  static const double _bodyMediumSize = 14.0;
  static const double _labelLargeSize = 16.0;
  
  // Pesos de fonte
  static const FontWeight _boldWeight = FontWeight.bold;
  static const FontWeight _semiBoldWeight = FontWeight.w600;
  static const FontWeight _mediumWeight = FontWeight.w500;

  // Cores principais
  static const Color kPrimaryColor = Color(0xFF7B1FA2); // Roxo mais escuro
  static const Color kPrimaryLightColor = Color(0xFFAE52D4); // Roxo mais claro
  static const Color kSecondaryColor = Color(0xFF9C27B0); // Roxo secundário
  static const Color kAccentColor = Color(0xFFE040FB); // Roxo de destaque
  
  // Cores de suporte
  static const Color kSuccessColor = Color(0xFF4CAF50);
  static const Color kWarningColor = Color(0xFFFF9800);
  static const Color kErrorColor = Color(0xFFF44336);
  static const Color kInfoColor = Color(0xFF2196F3);
  
  // Cores de texto e fundo
  static const Color kWhite = Colors.white;
  static const Color kBlack = Colors.black;
  static const Color kGrey = Color(0xFF9E9E9E);
  static const Color kLightGrey = Color(0xFFEEEEEE);
  static const Color kDarkGrey = Color(0xFF424242);
  
  // Cores específicas para o tema escuro
  static const Color kDarkSurface = Color(0xFF1E1E1E);
  static const Color kDarkBackground = Color(0xFF121212);
  static const Color kDarkError = Color(0xFFCF6679);
  static const Color kDarkTextPrimary = Colors.white;
  static const Color kDarkTextSecondary = Color(0xFFE0E0E0);
  static const Color kDarkTextHint = Color(0xFFA0A0A0);
  static const Color kDarkDivider = Color(0xFF333333);
  
  // Cores específicas para o tema claro
  static const Color kLightSurface = Colors.white;
  static const Color kLightBackground = Color(0xFFF5F5F5);
  static const Color kLightTextPrimary = Color(0xFF1A1A1A);
  static const Color kLightTextSecondary = Color(0xFF333333);
  static const Color kLightTextHint = Color(0xFF666666);
  static const Color kLightDivider = Color(0xFFE0E0E0);
  
  // Chave para armazenar a preferência de tema
  static const String _kThemeKey = 'isDarkMode';
  
  /// Gerenciador de tema que notifica os ouvintes quando o tema é alterado
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);
  
  /// Inicializa o tema com base nas preferências salvas
  /// 
  /// Deve ser chamado antes de usar o [themeNotifier]
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_kThemeKey) ?? false;
      themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
    } catch (e) {
      debugPrint('Erro ao carregar preferência de tema: $e');
      // Usa o tema do sistema em caso de erro
      themeNotifier.value = ThemeMode.system;
    }
  }
  
  /// Alterna entre os temas claro e escuro
  /// 
  /// Salva a preferência do usuário e notifica os ouvintes
  static Future<void> toggleTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = themeNotifier.value == ThemeMode.dark;
      themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
      await prefs.setBool(_kThemeKey, !isDark);
    } catch (e) {
      debugPrint('Erro ao alternar tema: $e');
      // Em caso de erro, alterna para o tema do sistema
      themeNotifier.value = themeNotifier.value == ThemeMode.dark 
          ? ThemeMode.light 
          : ThemeMode.dark;
    }
  }

  // Métodos auxiliares para criar estilos comuns
  
  static BorderRadius get _defaultBorderRadiusValue => 
      BorderRadius.circular(_defaultBorderRadius);
      
  static BorderRadius get _cardBorderRadiusValue => 
      BorderRadius.circular(_cardBorderRadius);
      
  static BorderRadius get _buttonBorderRadiusValue => 
      BorderRadius.circular(_buttonBorderRadius);
      
  static InputBorder _inputBorder({Color? color}) => OutlineInputBorder(
        borderRadius: _defaultBorderRadiusValue,
        borderSide: BorderSide(color: color ?? Colors.transparent, width: 1.5),
      );
      
  static ButtonStyle _elevatedButtonStyle(Color backgroundColor, Color foregroundColor) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: _defaultPadding,
      shape: RoundedRectangleBorder(
        borderRadius: _buttonBorderRadiusValue,
      ),
      elevation: _cardElevation,
      textStyle: TextStyle(
        fontSize: _bodyLargeSize,
        fontWeight: _semiBoldWeight,
      ),
    );
  }
  
  static ButtonStyle _outlinedButtonStyle(Color color) {
    return OutlinedButton.styleFrom(
      foregroundColor: color,
      side: BorderSide(color: color, width: 1.5),
      padding: _defaultPadding,
      shape: RoundedRectangleBorder(
        borderRadius: _buttonBorderRadiusValue,
      ),
      textStyle: TextStyle(
        fontSize: _bodyLargeSize,
        fontWeight: _semiBoldWeight,
      ),
    );
  }
  
  static ButtonStyle _textButtonStyle(Color color) {
    return TextButton.styleFrom(
      foregroundColor: color,
      padding: _compactPadding,
      textStyle: TextStyle(
        fontSize: _bodyMediumSize,
        fontWeight: _mediumWeight,
      ),
    );
  }
  
  // Método removido - implementação inline nos temas
  
  static InputDecorationTheme _inputDecorationTheme({
    required Color fillColor,
    required Color borderColor,
    required Color labelColor,
    required Color hintColor,
    required Color errorColor,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      border: _inputBorder(),
      enabledBorder: _inputBorder(),
      focusedBorder: _inputBorder(color: borderColor),
      errorBorder: _inputBorder(color: errorColor),
      focusedErrorBorder: _inputBorder(color: errorColor),
      contentPadding: _inputPadding,
      labelStyle: TextStyle(color: labelColor),
      hintStyle: TextStyle(color: hintColor),
    );
  }
  
  /// Tema claro
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: kPrimaryColor,
      colorScheme: ColorScheme.light(
        primary: kPrimaryColor,
        primaryContainer: kPrimaryLightColor,
        secondary: kSecondaryColor,
        secondaryContainer: kPrimaryLightColor.withOpacity(0.2),
        surface: kLightSurface,
        background: kLightBackground,
        error: kErrorColor,
        onPrimary: kWhite,
        onSecondary: kWhite,
        onSurface: kLightTextPrimary,
        onBackground: kLightTextPrimary,
        onError: kWhite,
      ),
      scaffoldBackgroundColor: kLightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: kWhite,
          fontSize: _headlineSmallSize,
          fontWeight: _boldWeight,
        ),
        iconTheme: const IconThemeData(color: kWhite),
        actionsIconTheme: const IconThemeData(color: kWhite),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: _displayLargeSize,
          fontWeight: _boldWeight,
          color: kLightTextPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: _displayMediumSize,
          fontWeight: _boldWeight,
          color: kLightTextPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: _displaySmallSize,
          fontWeight: _boldWeight,
          color: kLightTextPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: _headlineMediumSize,
          fontWeight: _boldWeight,
          color: kLightTextPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: _headlineSmallSize,
          fontWeight: _semiBoldWeight,
          color: kLightTextPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: _titleLargeSize,
          fontWeight: _semiBoldWeight,
          color: kLightTextPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: _bodyLargeSize,
          color: kLightTextSecondary,
        ),
        bodyMedium: TextStyle(
          fontSize: _bodyMediumSize,
          color: kLightTextHint,
        ),
        labelLarge: TextStyle(
          fontSize: _labelLargeSize,
          fontWeight: _mediumWeight,
          color: kWhite,
        ),
      ),
      inputDecorationTheme: _inputDecorationTheme(
        fillColor: kWhite,
        borderColor: kPrimaryColor,
        labelColor: kLightTextHint,
        hintColor: kGrey,
        errorColor: kErrorColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _elevatedButtonStyle(kPrimaryColor, kWhite),
      ),
      textButtonTheme: TextButtonThemeData(
        style: _textButtonStyle(kPrimaryColor),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _outlinedButtonStyle(kPrimaryColor),
      ),
      cardTheme: ThemeData.light().cardTheme.copyWith(
        elevation: _cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: _cardBorderRadiusValue,
        ),
        margin: _cardMargin,
        color: kLightSurface,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: kPrimaryColor,
        foregroundColor: kWhite,
        elevation: _fabElevation,
      ),
      dividerTheme: const DividerThemeData(
        color: kLightDivider,
        thickness: _dividerThickness,
        space: 1,
      ),
    );
  }
  
  /// Tema escuro
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: kPrimaryLightColor,
      colorScheme: ColorScheme.dark(
        primary: kPrimaryLightColor,
        primaryContainer: kPrimaryColor,
        secondary: kAccentColor,
        secondaryContainer: kPrimaryColor.withOpacity(0.2),
        surface: kDarkSurface,
        background: kDarkBackground,
        error: kDarkError,
        onPrimary: kBlack,
        onSecondary: kBlack,
        onSurface: kDarkTextPrimary,
        onBackground: kDarkTextPrimary,
        onError: kBlack,
      ),
      scaffoldBackgroundColor: kDarkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: kDarkSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: kDarkTextPrimary,
          fontSize: _headlineSmallSize,
          fontWeight: _boldWeight,
        ),
        iconTheme: const IconThemeData(color: kDarkTextPrimary),
        actionsIconTheme: const IconThemeData(color: kDarkTextPrimary),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: _displayLargeSize,
          fontWeight: _boldWeight,
          color: kDarkTextPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: _displayMediumSize,
          fontWeight: _boldWeight,
          color: kDarkTextPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: _displaySmallSize,
          fontWeight: _boldWeight,
          color: kDarkTextPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: _headlineMediumSize,
          fontWeight: _boldWeight,
          color: kDarkTextPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: _headlineSmallSize,
          fontWeight: _semiBoldWeight,
          color: kDarkTextPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: _titleLargeSize,
          fontWeight: _semiBoldWeight,
          color: kDarkTextPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: _bodyLargeSize,
          color: kDarkTextSecondary,
        ),
        bodyMedium: TextStyle(
          fontSize: _bodyMediumSize,
          color: kDarkTextHint,
        ),
        labelLarge: TextStyle(
          fontSize: _labelLargeSize,
          fontWeight: _mediumWeight,
          color: kBlack,
        ),
      ),
      inputDecorationTheme: _inputDecorationTheme(
        fillColor: kDarkSurface,
        borderColor: kPrimaryLightColor,
        labelColor: kDarkTextHint,
        hintColor: kGrey,
        errorColor: kDarkError,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _elevatedButtonStyle(kPrimaryLightColor, kBlack),
      ),
      textButtonTheme: TextButtonThemeData(
        style: _textButtonStyle(kPrimaryLightColor),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _outlinedButtonStyle(kPrimaryLightColor),
      ),
      cardTheme: ThemeData.dark().cardTheme.copyWith(
        elevation: _cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: _cardBorderRadiusValue,
        ),
        margin: _cardMargin,
        color: kDarkSurface,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: kPrimaryLightColor,
        foregroundColor: kBlack,
        elevation: _fabElevation,
      ),
      dividerTheme: const DividerThemeData(
        color: kDarkDivider,
        thickness: _dividerThickness,
        space: 1,
      ),
    );
  }
}
