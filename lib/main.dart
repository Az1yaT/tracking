import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracking_application/providers/auth_provider.dart';
import 'package:tracking_application/screens/accountant/accountant_screen.dart';
import 'package:tracking_application/screens/assign_courier/assign_courier_screen.dart';
import 'package:tracking_application/screens/director/director_screen.dart';
import 'package:tracking_application/screens/auth/auth_screen.dart' as auth;
import 'package:tracking_application/screens/courier/courier_screen.dart';
import 'package:tracking_application/screens/search_orders/search_orders_screen.dart';
import 'package:tracking_application/screens/statistics/statistics_screen.dart';
import 'package:tracking_application/services/api_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Используем моковые данные для тестирования UI
  final ApiService apiService = ApiService(
    baseUrl: 'http://10.0.2.2:8080',
    useMockData: true, // Включаем режим моковых данных
  );

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Система доставки',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.light,
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.dark,
              useMaterial3: true,
            ),
            themeMode: themeProvider.themeMode,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ru', 'RU'),
              Locale('en', 'US'),
            ],
            locale: const Locale('ru', 'RU'),
            initialRoute: '/',
            routes: {
              '/': (context) => auth.AuthScreen(apiService: apiService),
              '/courier': (context) => _checkAccess(
                  context, 'courier', CourierScreen(apiService: apiService)),
              '/accountant': (context) => _checkAccess(
                  context, 'accountant', AccountantScreen(apiService: apiService)),
              '/director': (context) => _checkAccess(
                  context, 'director', DirectorScreen(apiService: apiService)),
              '/search-orders': (context) => _checkAccess(
                  context, 'director', SearchOrdersScreen(apiService: apiService)),
              '/assign-courier': (context) => _checkAccess(
                  context, 'director', AssignCourierScreen(apiService: apiService)),
              '/statistics': (context) => _checkAccess(
                  context, 'director', StatisticsScreen(apiService: apiService, statistics: {})),
            },
          );
        },
      ),
    );
  }

  Widget _checkAccess(BuildContext context, String requiredRole, Widget destination) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.role == requiredRole || 
        (requiredRole == 'any' && authProvider.isLoggedIn)) {
      return destination;
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text('Доступ запрещен')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'У вас нет прав для просмотра этой страницы.',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
                child: const Text('Вернуться на главную'),
              ),
            ],
          ),
        ),
      );
    }
  }
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}