import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/order.dart'; // Добавьте импорт модели Order

class DirectorScreen extends StatefulWidget {
  final ApiService apiService;

  const DirectorScreen({required this.apiService, super.key});

  @override
  _DirectorScreenState createState() => _DirectorScreenState();
}

class _DirectorScreenState extends State<DirectorScreen> {
  List<Order> _orders = []; // Изменено с List<dynamic> на List<Order>
  List<dynamic> _couriers = [];
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Используем searchOrders, который возвращает List<Order>
      final orders = await widget.apiService.searchOrders();
      final couriers = await widget.apiService.getCouriers();

      setState(() {
        _orders = orders;
        _couriers = couriers;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка загрузки данных: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _fetchStatistics() async {
    try {
      final stats = await widget.apiService.get('/statistics');
      // TODO: Обработать и отобразить данные статистики
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Статистика успешно загружена')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка загрузки статистики: ${e.toString()}';
      });
    }
  }

  void _assignCourier(String orderId, String courierId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Используем правильный эндпоинт и данные для назначения курьера
      await widget.apiService.patch('/orders/$orderId/assign', {
        'courierId': courierId,
      });

      // Обновляем UI после успешного назначения
      _fetchData(); // Перезагружаем данные, чтобы отобразить изменения

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Курьер успешно назначен')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Ошибка при назначении курьера: ${e.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${e.toString()}')),
      );
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
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Меню директора',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
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
                Navigator.pushNamed(context, '/assign-courier');
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
                // Реализация выхода из системы
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
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text('Заказ №${order.id}'), // Используем свойство вместо индекса
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Статус: ${order.status ?? "Неизвестно"}'), // Используем свойство
                            Text('Курьер: ${order.courierName ?? "Не назначен"}'), // Используем свойство
                            Text('Адрес: ${order.address ?? ""}'), // Используем свойство
                          ],
                        ),
                        isThreeLine: true,
                        trailing: DropdownButton<String>(
                          hint: const Text('Назначить'),
                          value: order.courierId, // Используем свойство
                          onChanged: (value) {
                            if (value != null) {
                              _assignCourier(order.id, value); // Используем свойство
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
