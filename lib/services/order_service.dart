import 'api_service.dart';
import '../models/order.dart';

class OrderService {
  final ApiService apiService;

  OrderService(this.apiService);

  Future<List<Order>> fetchOrders() async {
    final response = await apiService.get('/orders');
    return (response as List).map((json) => Order.fromJson(json)).toList();
  }
}