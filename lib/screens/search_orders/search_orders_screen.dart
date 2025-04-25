import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class SearchOrdersScreen extends StatefulWidget {
  final ApiService apiService;

  const SearchOrdersScreen({required this.apiService, super.key});

  @override
  _SearchOrdersScreenState createState() => _SearchOrdersScreenState();
}

class _SearchOrdersScreenState extends State<SearchOrdersScreen> {
  List<dynamic> _orders = [];
  String? _errorMessage;
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'Все';

  void _searchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final query = _searchController.text.isNotEmpty
          ? '?search=${_searchController.text}'
          : '';
      final statusFilter = _selectedStatus != 'Все'
          ? '&status=${_selectedStatus.toLowerCase()}'
          : '';
      final orders = await widget.apiService.get('/orders$query$statusFilter');
      setState(() {
        _orders = orders;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка поиска заказов: ${e.toString()}';
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
        title: const Text('Поиск заказов'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Поиск по номеру заказа',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchOrders,
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: _selectedStatus,
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                  _searchOrders();
                });
              },
              items: ['Все', 'ожидание', 'взято', 'доставлено']
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : _errorMessage != null
                    ? Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _orders.length,
                          itemBuilder: (context, index) {
                            final order = _orders[index];
                            return ListTile(
                              title: Text('Заказ №${order['id']}'),
                              subtitle: Text('Статус: ${order['status']}'),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}