import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tracking_application/services/api_service.dart';

class StatisticsScreen extends StatefulWidget {
  final ApiService apiService;
  final Map<String, dynamic> statistics;

  const StatisticsScreen({
    Key? key,
    required this.apiService,
    required this.statistics,
  }) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late Future<Map<String, dynamic>> _statisticsFuture;
  String _period = 'week';

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  void _loadStatistics() {
    _statisticsFuture = widget.apiService.getStatistics();
  }

  void _changePeriod(String period) {
    setState(() {
      _period = period;
      _loadStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _loadStatistics();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _statisticsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Ошибка: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Нет данных для отображения'),
            );
          }

          final stats = snapshot.data!;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPeriodSelector(),
                const SizedBox(height: 24),
                
                _buildSummaryCards(stats),
                const SizedBox(height: 24),
                
                _buildDeliveryChart(stats),
                const SizedBox(height: 24),
                
                _buildCourierPerformance(stats),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _periodButton('День', 'day'),
            _periodButton('Неделя', 'week'),
            _periodButton('Месяц', 'month'),
          ],
        ),
      ),
    );
  }

  Widget _periodButton(String label, String period) {
    return TextButton(
      onPressed: () => _changePeriod(period),
      style: TextButton.styleFrom(
        backgroundColor: _period == period ? Colors.blue.shade100 : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(label),
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildStatCard('Всего заказов', '${stats['totalOrders'] ?? 0}', Icons.shopping_bag),
        _buildStatCard('Доставлено', '${stats['deliveredOrders'] ?? 0}', Icons.check_circle),
        _buildStatCard('Сумма дохода', '${stats['totalAmount'] ?? 0} ₽', Icons.monetization_on),
        _buildStatCard('Активные курьеры', '${stats['activeCouriers'] ?? 0}', Icons.person),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryChart(Map<String, dynamic> stats) {
    // Здесь была бы реальная обработка данных из API
    // Для примера используем заглушку
    final List<FlSpot> deliverySpots = [
      FlSpot(0, 3),
      FlSpot(1, 5),
      FlSpot(2, 4),
      FlSpot(3, 7),
      FlSpot(4, 6),
      FlSpot(5, 8),
      FlSpot(6, 5),
    ];

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Динамика доставок',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
                          if (value >= 0 && value < days.length) {
                            return Text(days[value.toInt()]);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: deliverySpots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourierPerformance(Map<String, dynamic> stats) {
    // Тут должны быть данные от API
    final List<Map<String, dynamic>> courierData = [
      {'name': 'Иванов И.И.', 'deliveries': 12, 'rating': 4.8},
      {'name': 'Петров П.П.', 'deliveries': 8, 'rating': 4.6},
      {'name': 'Сидоров С.С.', 'deliveries': 15, 'rating': 4.9},
    ];

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Эффективность курьеров',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: courierData.length,
              itemBuilder: (context, index) {
                final courier = courierData[index];
                return ListTile(
                  title: Text(courier['name']),
                  subtitle: Text('Доставок: ${courier['deliveries']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.amber),
                      Text('${courier['rating']}'),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
