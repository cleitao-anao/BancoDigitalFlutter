import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider_package;
import 'package:flutter_application_1/theme/app_theme.dart';
import 'package:flutter_application_1/config/app_routes.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/supabase_service.dart';
import 'package:flutter_application_1/services/bank_service.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Inicializa o tema
    await AppTheme.init();
    
    // Inicializa o Supabase
    await SupabaseService().initialize();
    
    // Initialize shared preferences and check login status
    final authService = AuthService();
    
    runApp(
      provider_package.MultiProvider(
        providers: [
          provider_package.Provider<AuthService>(
            create: (_) => authService,
          ),
          provider_package.Provider<http.Client>(
            create: (_) => http.Client(),
            dispose: (_, client) => client.close(),
          ),
          // Adiciona o SupabaseService como um provider
          provider_package.Provider<SupabaseService>(
            create: (_) => SupabaseService(),
          ),
          provider_package.ChangeNotifierProvider<BankService>(
            create: (_) => BankService(),
          ),
        ],
        child: MyApp(),
      ),
    );
  } catch (e) {
    print('Erro ao inicializar o aplicativo: $e');
    // Pode adicionar um tratamento de erro mais robusto aqui
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicializa o tema
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeNotifier,
      builder: (_, themeMode, __) {
        return MaterialApp(
          title: 'Banco Digital',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          initialRoute: loginRoute,
          routes: appRoutes,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

// This widget is kept for reference but not used in the app
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
