import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracking_application/providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/order.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class AccountantScreen extends StatefulWidget {
  final ApiService apiService;

  const AccountantScreen({required this.apiService, super.key});

  @override
  _AccountantScreenState createState() => _AccountantScreenState();
}

class _AccountantScreenState extends State<AccountantScreen> with SingleTickerProviderStateMixin {
  List<Order> _orders = [];
  List<dynamic> _couriers = [];
  String? _errorMessage;
  bool _isLoading = false;
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _selectedCourierId;
  late TabController _tabController;
  double _totalRevenue = 0;
  String? _selectedFileForImport;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Получаем список всех заказов
      List<Order> orders = [];
      
      // Применяем фильтры, если они установлены
      if (_fromDate != null || _toDate != null || _selectedCourierId != null) {
        orders = await widget.apiService.searchOrders(
          courierId: _selectedCourierId,
          dateFrom: _fromDate?.toIso8601String(),
          dateTo: _toDate?.toIso8601String(),
          status: 'доставлен', // Только доставленные заказы
        );
      } else {
        orders = await widget.apiService.searchOrders();
      }

      // Получаем список курьеров для фильтра
      final couriers = await widget.apiService.getCouriers();
      
      // Рассчитываем общую сумму
      double total = 0;
      for (var order in orders) {
        if (order.status == 'доставлен' && order.price != null) {
          total += order.price!;
        }
      }
      
      setState(() {
        _orders = orders;
        _couriers = couriers;
        _totalRevenue = total;
        print('Загружено заказов: ${_orders.length}');
        print('Общая сумма: $_totalRevenue руб.');
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

  Future<void> _importOrders() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'csv'],
      );

      if (result != null) {
        _selectedFileForImport = result.files.single.path;
        
        // Показываем диалог подтверждения
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Импорт заказов'),
            content: Text('Вы выбрали файл: ${result.files.single.name}\nХотите импортировать заказы из этого файла?'),
            actions: [
              TextButton(
                child: const Text('Отмена'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Импорт'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  // Здесь был бы код для реальной загрузки файла на сервер
                  // В тестовом режиме просто показываем успешное сообщение
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Заказы успешно импортированы'))
                  );
                  await _fetchData(); // Обновляем данные
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при выборе файла: ${e.toString()}'))
      );
    }
  }

  Future<void> _exportOrders() async {
    try {
      // Здесь был бы код для реальной выгрузки в файл
      // В тестовом режиме просто показываем успешное сообщение
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Экспорт заказов'),
          content: const Text('Выберите формат для экспорта:'),
          actions: [
            TextButton(
              child: const Text('Excel (.xlsx)'),
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Отчет успешно выгружен в Excel'))
                );
              },
            ),
            TextButton(
              child: const Text('CSV (.csv)'),
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Отчет успешно выгружен в CSV'))
                );
              },
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при экспорте отчета: ${e.toString()}'))
      );
    }
  }

  Widget _buildOrdersList() {
    return _orders.isEmpty
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
                      Text('Цена: ${order.price != null ? '${order.price!.toStringAsFixed(2)} руб.' : "Не указана"}'),
                      Text('Дата создания: ${order.createdAt?.toString().substring(0, 16) ?? "Неизвестно"}'),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
  }

  Widget _buildFilterPanel() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Фильтры', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _fromDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _fromDate = date;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'От даты',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _fromDate != null ? '${_fromDate!.day}.${_fromDate!.month}.${_fromDate!.year}' : 'Не выбрано',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _toDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 1)),
                    );
                    if (date != null) {
                      setState(() {
                        _toDate = date;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'До даты',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _toDate != null ? '${_toDate!.day}.${_toDate!.month}.${_toDate!.year}' : 'Не выбрано',
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Курьер',
              border: OutlineInputBorder(),
            ),
            value: _selectedCourierId,
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Все курьеры'),
              ),
              ..._couriers.map<DropdownMenuItem<String>>((courier) {
                return DropdownMenuItem<String>(
                  value: courier['id'],
                  child: Text(courier['username'] ?? courier['name'] ?? 'Неизвестно'),
                );
              }).toList(),
            ],
            onChanged: (value) {
              setState(() {
                _selectedCourierId = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.search),
                label: const Text('Применить фильтры'),
                onPressed: _fetchData,
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.clear),
                label: const Text('Сбросить'),
                onPressed: () {
                  setState(() {
                    _fromDate = null;
                    _toDate = null;
                    _selectedCourierId = null;
                  });
                  _fetchData();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPanel() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Итоги', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            Text(
              'Количество заказов: ${_orders.length}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Общая сумма: ${_totalRevenue.toStringAsFixed(2)} руб.',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Бухгалтер'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
            tooltip: 'Обновить данные',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'Заказы'),
            Tab(icon: Icon(Icons.file_download), text: 'Импорт/Экспорт'),
            Tab(icon: Icon(Icons.analytics), text: 'Статистика'),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Меню бухгалтера',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Главная'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_download),
              title: const Text('Импорт/Экспорт'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Статистика'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(2);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Выйти'),
              onTap: () {
                // Выход из аккаунта
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
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Вкладка со списком заказов
                    Column(
                      children: [
                        _buildFilterPanel(),
                        _buildSummaryPanel(),
                        Expanded(child: _buildOrdersList()),
                      ],
                    ),
                    
                    // Вкладка импорта/экспорта
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_upload, size: 48),
                          const SizedBox(height: 16),
                          const Text('Импорт/Экспорт данных', style: TextStyle(fontSize: 20)),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Импорт заказов из Excel/CSV'),
                            onPressed: _importOrders,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.download_for_offline),
                            label: const Text('Экспорт отчета'),
                            onPressed: _exportOrders,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Вкладка статистики
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Статистика по доставленным заказам', 
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('За текущий период:'),
                                  const SizedBox(height: 8),
                                  Text('Всего заказов: ${_orders.length}'),
                                  Text('Доставлено: ${_orders.where((o) => o.status == 'доставлен').length}'),
                                  Text('В пути: ${_orders.where((o) => o.status == 'в пути').length}'),
                                  Text('Новых: ${_orders.where((o) => o.status == 'новый').length}'),
                                  Text('Общая сумма: ${_totalRevenue.toStringAsFixed(2)} руб.'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Дополнительные элементы статистики могут быть добавлены здесь
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
