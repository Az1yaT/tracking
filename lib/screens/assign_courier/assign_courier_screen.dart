import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AssignCourierScreen extends StatelessWidget {
  final ApiService apiService;

  const AssignCourierScreen({required this.apiService, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Назначение курьера'),
      ),
      body: const Center(
        child: Text('Экран назначения курьера'),
      ),
    );
  }
}