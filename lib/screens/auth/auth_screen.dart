import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class AuthScreen extends StatefulWidget {
  final ApiService apiService;

  const AuthScreen({required this.apiService, super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    // Если поля не заполнены, не пытаемся авторизоваться
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Введите логин и пароль';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Попытка авторизации с логином: ${_usernameController.text}');
      
      // Используем метод login в AuthProvider для авторизации
      final success = await Provider.of<AuthProvider>(context, listen: false)
          .login(widget.apiService, _usernameController.text, _passwordController.text);
      
      if (success) {
        // Получаем роль из AuthProvider
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final role = authProvider.role;
        
        print('Успешная авторизация с ролью: $role');
        
        // Перенаправляем пользователя в соответствии с ролью
        if (role == 'courier') {
          Navigator.pushReplacementNamed(context, '/courier');
        } else if (role == 'accountant') {
          Navigator.pushReplacementNamed(context, '/accountant');
        } else if (role == 'director') {
          Navigator.pushReplacementNamed(context, '/director');
        } else {
          setState(() {
            _errorMessage = 'Неизвестная роль пользователя: $role';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Неверный логин или пароль';
        });
      }
    } catch (e) {
      print('Ошибка при авторизации: $e');
      setState(() {
        _errorMessage = 'Ошибка авторизации: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Авторизация'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Система доставки',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Логин',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Пароль',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _login(),
                ),
                const SizedBox(height: 16),
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.red[50],
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Войти',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // Отображаем подсказку с тестовыми учетными данными
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Тестовые учетные данные'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('Директор:\nЛогин: sidorov\nПароль: 1234'),
                            SizedBox(height: 8),
                            Text('Бухгалтер:\nЛогин: petrova\nПароль: 1234'),
                            SizedBox(height: 8),
                            Text('Курьер:\nЛогин: ivanov\nПароль: 1234'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Подсказка (тестовые данные)'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
