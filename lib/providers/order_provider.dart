import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/order_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService;
  List<Order> _orders = [];
  bool _isLoading = false;

  OrderProvider(this._orderService);

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _orders = await _orderService.fetchOrders();
    } catch (e) {
      print('Ошибка: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}