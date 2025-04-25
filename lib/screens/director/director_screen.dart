import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracking_application/providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/order.dart';

class DirectorScreen extends StatefulWidget {
  final ApiService apiService;

  const DirectorScreen({required this.apiService, super.key});

  @override
  _DirectorScreenState createState() => _DirectorScreenState();
}

class _DirectorScreenState extends State<DirectorScreen> {
  List<Order> _orders = []; // Используем объекты Order вместо Map
  List<Map<String, dynamic>> _couriers = [];
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Используем searchOrders вместо get('/orders')
      final orders = await widget.apiService.searchOrders();
      final couriers = await widget.apiService.getCouriers();
      
      setState(() {
        _orders = orders;
        _couriers = couriers;
        print('Загружено заказов: ${_orders.length}');
        print('Загружено курьеров: ${_couriers.length}');
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка загрузки данных: ${e.toString()}';
        print('Ошибка загрузки: $e');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _assignCourier(String orderId, String courierId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Начинаем назначение курьера: $courierId для заказа: $orderId');
      
      // Вызываем метод assignCourier из apiService
      await widget.apiService.assignCourier(orderId, courierId);
      
      // Находим курьера для отображения информации
      final courier = _couriers.firstWhere(
        (c) => c['id'] == courierId,
        orElse: () => {'fullName': 'Неизвестно', 'username': 'Неизвестно'}
      );
      
      final courierName = courier['fullName'] ?? courier['username'] ?? 'Неизвестно';
      
      // Показываем уведомление
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Курьер ${courierName} успешно назначен на заказ №$orderId')),
      );
      
      // Перезагружаем данные для отображения актуальной информации
      _fetchData();
      
    } catch (e) {
      print('Ошибка при назначении курьера: $e');
      setState(() {
        _errorMessage = 'Ошибка при назначении курьера: ${e.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${e.toString()}')),
      );
    } finally {
      // Убираем индикатор загрузки
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Директор - Назначение курьеров'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
            tooltip: 'Обновить данные',
          ),
          IconButton(
            icon: const Icon(Icons.insert_chart),
            onPressed: () {
              Navigator.pushNamed(context, '/statistics');
            },
            tooltip: 'Показать статистику',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, '/search-orders');
            },
            tooltip: 'Поиск заказов',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Меню директора',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Главная'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Поиск заказов'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/search-orders');
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('Назначение курьеров'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_chart),
              title: const Text('Статистика'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/statistics');
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
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : _orders.isEmpty
                  ? const Center(child: Text('Нет доступных заказов'))
                  : ListView.builder(
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text('Заказ №${order.id}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Статус: ${order.status ?? "Неизвестно"}'),
                                Text('Курьер: ${order.courierName ?? "Не назначен"}'),
                                Text('Адрес: ${order.address ?? ""}'),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: DropdownButton<String>(
                              hint: Text(order.courierId == null ? 'Назначить' : 'Изменить'),
                              value: order.courierId,
                              onChanged: (value) {
                                if (value != null) {
                                  _assignCourier(order.id, value);
                                }
                              },
                              items: _couriers.map<DropdownMenuItem<String>>((courier) {
                                return DropdownMenuItem<String>(
                                  value: courier['id'],
                                  child: Text(courier['username'] ?? courier['name'] ?? 'Неизвестно'),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/search-orders');
        },
        child: const Icon(Icons.search),
        tooltip: 'Поиск заказов',
      ),
    );
  }
}
