import 'package:flutter/material.dart';
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

  void _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await widget.apiService.post('/auth/login', {
        'username': _usernameController.text,
        'password': _passwordController.text,
      });

      if (response['role'] == 'courier') {
        Navigator.pushNamed(context, '/courier');
      } else if (response['role'] == 'accountant') {
        Navigator.pushNamed(context, '/accountant');
      } else if (response['role'] == 'director') {
        Navigator.pushNamed(context, '/director');
      } else {
        setState(() {
          _errorMessage = 'Неизвестная роль пользователя';
        });
      }
    } catch (e) {
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Логин',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Пароль',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text('Войти'),
                  ),
          ],
        ),
      ),
    );
  }
}

class CourierScreen extends StatefulWidget {
  final ApiService apiService;

  const CourierScreen({required this.apiService, super.key});

  @override
  _CourierScreenState createState() => _CourierScreenState();
}

class _CourierScreenState extends State<CourierScreen> {
  List<dynamic> _orders = [];
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  void _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final orders = await widget.apiService.get('/orders/courier');
      setState(() {
        _orders = orders;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка загрузки заказов: ${e.toString()}';
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
        title: const Text('Курьер - Мои заказы'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return ListTile(
                      title: Text('Заказ №${order['id']}'),
                      subtitle: Text('Статус: ${order['status']}'),
                    );
                  },
                ),
    );
  }
}
