import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/order.dart';
import '../../widgets/order_card.dart';

class AccountantScreen extends StatefulWidget {
  final ApiService apiService;

  const AccountantScreen({required this.apiService, super.key});

  @override
  _AccountantScreenState createState() => _AccountantScreenState();
}

class _AccountantScreenState extends State<AccountantScreen>
    with SingleTickerProviderStateMixin {
  String? _errorMessage;
  bool _isLoading = false;
  String? _selectedFilePath;
  String? _selectedFileName;
  late TabController _tabController;
  List<Order> _deliveredOrders = [];
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  String? _selectedCourierId;
  List<Map<String, dynamic>> _couriers = [];
  double _totalSum = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCouriers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCouriers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _couriers = await widget.apiService.getCouriers();
      setState(() {
        _couriers = _couriers;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка загрузки курьеров: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDeliveredOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dateFromStr = DateFormat('yyyy-MM-dd').format(_startDate);
      final dateToStr = DateFormat('yyyy-MM-dd')
          .format(_endDate.add(const Duration(days: 1)));

      _deliveredOrders = await widget.apiService.searchOrders(
        status: 'доставлен',
        courierId: _selectedCourierId,
        dateFrom: dateFromStr,
        dateTo: dateToStr,
      );

      // Рассчитываем общую сумму
      _totalSum =
          _deliveredOrders.fold(0, (sum, order) => sum + (order.price ?? 0));
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

  Future<void> _uploadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'csv'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFilePath = result.files.single.path!;
          _selectedFileName = result.files.single.name;
        });

        // Show confirmation dialog
        final shouldUpload = await _showConfirmationDialog();

        if (shouldUpload) {
          // Upload file
          await widget.apiService.uploadFile(
              '/orders/upload', _selectedFilePath!, onProgress: (progress) {
            // You could update a progress indicator here
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Заказы успешно загружены')),
          );
        }
      }
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

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Подтверждение'),
            content: Text(
                'Вы уверены, что хотите загрузить файл "$_selectedFileName"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Загрузить'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _downloadReport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Создаем query parameters для фильтрации отчета
      final dateFromStr = DateFormat('yyyy-MM-dd').format(_startDate);
      final dateToStr = DateFormat('yyyy-MM-dd').format(_endDate);

      final queryParams = {
        'dateFrom': dateFromStr,
        'dateTo': dateToStr,
        if (_selectedCourierId != null) 'courierId': _selectedCourierId!,
      };

      // Создаем endpoint с query parameters
      final endpoint = Uri.parse('/reports')
          .replace(queryParameters: queryParams)
          .toString();

      // Save location selection
      final String? outputDir = await FilePicker.platform.getDirectoryPath();

      if (outputDir == null) {
        throw Exception('Директория не выбрана');
      }

      // Create a filename with timestamp
      final String timestamp =
          DateTime.now().toIso8601String().replaceAll(':', '-');
      final String filename = 'report_$timestamp.xlsx';
      final String filePath = '$outputDir/$filename';

      // Download the report
      await widget.apiService.downloadFile(endpoint, filePath,
          onProgress: (progress) {
        // You could update a progress indicator here
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Отчет сохранен: $filePath')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка выгрузки отчета: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _startDate,
        end: _endDate,
      ),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            colorScheme: const ColorScheme.light(primary: Colors.blue),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadDeliveredOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = Provider.of<AuthProvider>(context).username;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Бухгалтер'),
            Text(
              username ?? '',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Загрузка заказов', icon: Icon(Icons.file_upload)),
            Tab(text: 'Доставленные заказы', icon: Icon(Icons.insights)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Первая вкладка: Загрузка заказов
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_selectedFileName != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.file_present),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Выбранный файл: $_selectedFileName',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _selectedFileName = null;
                                _selectedFilePath = null;
                              });
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 16),
                _isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                        children: [
                          const Text(
                            'Загрузите файл с новыми заказами',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Поддерживаемые форматы: Excel (.xlsx) и CSV (.csv)',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _uploadOrders,
                            icon: const Icon(Icons.file_upload),
                            label: const Text('Выбрать файл'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),

          // Вторая вкладка: Доставленные заказы
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Фильтры
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Фильтры',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _selectDateRange(context),
                                child: Text(
                                  '${DateFormat('dd.MM.yyyy').format(_startDate)} - ${DateFormat('dd.MM.yyyy').format(_endDate)}',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String?>(
                          decoration: const InputDecoration(
                            labelText: 'Курьер',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedCourierId,
                          onChanged: (value) {
                            setState(() {
                              _selectedCourierId = value;
                            });
                          },
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('Все курьеры'),
                            ),
                            ..._couriers.map((courier) {
                              return DropdownMenuItem<String?>(
                                value: courier['id'],
                                child:
                                    Text(courier['username'] ?? 'Неизвестный'),
                              );
                            }).toList(),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: _loadDeliveredOrders,
                              child: const Text('Применить'),
                            ),
                            ElevatedButton.icon(
                              onPressed: _downloadReport,
                              icon: const Icon(Icons.file_download),
                              label: const Text('Скачать отчет'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Заголовок и информация о сумме
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Доставленные заказы (${_deliveredOrders.length})',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Общая сумма: ${_totalSum.toStringAsFixed(2)} ₽',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Список заказов
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _deliveredOrders.isEmpty
                          ? const Center(
                              child: Text('Нет доставленных заказов'))
                          : ListView.builder(
                              itemCount: _deliveredOrders.length,
                              itemBuilder: (context, index) {
                                final order = _deliveredOrders[index];
                                return OrderCard(order: order);
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
