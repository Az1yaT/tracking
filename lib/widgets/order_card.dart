import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  
  const OrderCard({
    Key? key,
    required this.order,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Заказ №${order.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${order.price?.toStringAsFixed(2)} ₽',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Отправитель:'),
                      Text(order.senderName ?? 'Не указан'),
                      Text('Тел: ${order.senderPhone ?? 'Не указан'}'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Получатель:'),
                      Text(order.receiverName ?? 'Не указан'),
                      Text('Тел: ${order.receiverPhone ?? 'Не указан'}'),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Курьер: ${order.courierName ?? "Не назначен"}'),
                Text(
                  order.updatedAt != null 
                    ? 'Доставлен: ${DateFormat('dd.MM.yyyy HH:mm').format(order.updatedAt!)}'
                    : 'Дата доставки неизвестна',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}