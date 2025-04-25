import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
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
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCourierOrders();
  }

  Future<void> _fetchCourierOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Получаем ID текущего курьера из AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final courierId = authProvider.userId;
      
      print('Запрашиваем заказы для курьера с ID: $courierId');
      
      // Используем специальный метод для получения заказов курьера
      final orders = await widget.apiService.getCourierOrders(courierId);
      
      setState(() {
        _orders = orders;
        print('Загружено заказов курьера: ${orders.length}');
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка загрузки заказов: ${e.toString()}';
        print('Ошибка: $_errorMessage');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateOrderStatus(Order order, String newStatus) async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Обновляем статус заказа через API
      await widget.apiService.patch(
        '/orders/${order.id}/status',
        {'status': newStatus},
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Статус заказа №${order.id} обновлен на "$newStatus"')),
      );
      
      // Обновляем список заказов
      _fetchCourierOrders();
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка обновления статуса: ${e.toString()}';
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final username = authProvider.username;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Курьер: $username'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchCourierOrders,
            tooltip: 'Обновить',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Курьер',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    username,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Обновить заказы'),
              onTap: () {
                Navigator.pop(context);
                _fetchCourierOrders();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Выйти'),
              onTap: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchCourierOrders,
                        child: const Text('Попробовать снова'),
                      ),
                    ],
                  ),
                )
              : _orders.isEmpty
                  ? const Center(child: Text('У вас нет назначенных заказов'))
                  : ListView.builder(
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ExpansionTile(
                            title: Text('Заказ №${order.id}'),
                            subtitle: Text('Статус: ${order.status ?? "Неизвестно"}'),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Адрес доставки: ${order.address ?? ""}'),
                                    const SizedBox(height: 8),
                                    Text('Получатель: ${order.receiverName ?? ""}'),
                                    Text('Телефон: ${order.receiverPhone ?? ""}'),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        if (order.status == 'новый')
                                          ElevatedButton(
                                            onPressed: () => _updateOrderStatus(order, 'в пути'),
                                            child: const Text('В пути'),
                                          ),
                                        if (order.status == 'в пути')
                                          ElevatedButton(
                                            onPressed: () => _updateOrderStatus(order, 'доставлен'),
                                            child: const Text('Доставлен'),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
