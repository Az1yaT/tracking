import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import 'mock_data_service.dart';

class ApiService {
  final String baseUrl;
  final bool useMockData; // Флаг для переключения между реальным API и моковыми данными
  final Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  ApiService({
    required this.baseUrl,
    this.useMockData = true, // По умолчанию используем тестовые данные
  });

  // Метод для обновления заголовка авторизации
  void updateAuthHeader(String token) {
    headers['Authorization'] = 'Bearer $token';
  }

  // Универсальный метод для выполнения GET запросов
  Future<dynamic> get(String endpoint) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1)); // Имитация задержки сети
      
      // Возвращаем соответствующие тестовые данные в зависимости от запрашиваемого endpoint
      if (endpoint == '/orders') {
        return MockDataService.getMockOrders().map((e) => Order.fromJson(e)).toList();
      } else if (endpoint == '/users?role=courier') {
        return MockDataService.getMockCouriers();
      } else if (endpoint == '/statistics') {
        return MockDataService.getMockStatistics();
      }
      
      throw Exception('Неизвестный endpoint для моковых данных: $endpoint');
    } else {
      final response = await http.get(Uri.parse('$baseUrl$endpoint'), headers: headers);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Ошибка GET запроса к $endpoint: ${response.body}');
      }
    }
  }

  // Метод для выполнения POST запросов
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1)); // Имитация задержки сети
      
      if (endpoint == '/auth/login') {
        final user = MockDataService.authenticateUser(data['username'], data['password']);
        if (user != null) {
          return user;
        }
        throw Exception('Неверный логин или пароль');
      }
      
      // Обработка других POST запросов...
      throw Exception('Неизвестный endpoint для моковых данных: $endpoint');
    } else {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Ошибка POST запроса к $endpoint: ${response.body}');
      }
    }
  }

  // Метод для выполнения PATCH запросов
  Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1)); // Имитация задержки сети
      
      // Имитация успешного ответа для обновления статуса заказа или назначения курьера
      if (endpoint.contains('/orders/') && endpoint.contains('/status')) {
        return {'success': true, 'message': 'Статус заказа обновлен'};
      } else if (endpoint.contains('/orders/') && endpoint.contains('/assign')) {
        return {'success': true, 'message': 'Курьер назначен'};
      }
      
      throw Exception('Неизвестный endpoint для моковых данных: $endpoint');
    } else {
      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Ошибка PATCH запроса к $endpoint: ${response.body}');
      }
    }
  }

  // Метод для выполнения PUT запросов
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1)); // Имитация задержки сети
      
      // Имитация успешного ответа для различных эндпоинтов
      if (endpoint.contains('/users/')) {
        return {'success': true, 'message': 'Данные пользователя обновлены'};
      }
      
      throw Exception('Неизвестный endpoint для моковых данных: $endpoint');
    } else {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Ошибка PUT запроса к $endpoint: ${response.body}');
      }
    }
  }

  // Метод для поиска заказов с фильтрацией
  Future<List<Order>> searchOrders({
    String? orderId,
    String? courierId,
    String? status,
    String? dateFrom,
    String? dateTo,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1)); // Имитация задержки сети
      
      List<Map<String, dynamic>> orders = MockDataService.getMockOrders();
      
      // Применяем фильтры
      if (orderId != null) {
        orders = orders.where((order) => order['id'] == orderId).toList();
      }
      
      if (status != null) {
        orders = orders.where((order) => order['status'] == status).toList();
      }
      
      if (courierId != null) {
        orders = orders.where((order) => order['courier_id'] == courierId).toList();
      }
      
      // Фильтрация по датам
      if (dateFrom != null) {
        final fromDate = DateTime.parse(dateFrom);
        orders = orders.where((order) {
          final createdAt = DateTime.parse(order['created_at']);
          return createdAt.isAfter(fromDate) || createdAt.isAtSameMomentAs(fromDate);
        }).toList();
      }
      
      if (dateTo != null) {
        final toDate = DateTime.parse(dateTo);
        orders = orders.where((order) {
          final createdAt = DateTime.parse(order['created_at']);
          return createdAt.isBefore(toDate) || createdAt.isAtSameMomentAs(toDate);
        }).toList();
      }
      
      return orders.map((item) => Order.fromJson(item)).toList();
    } else {
      // Используем реальный API запрос
      final queryParams = <String, String>{};
      if (orderId != null) queryParams['orderId'] = orderId;
      if (courierId != null) queryParams['courierId'] = courierId;
      if (status != null) queryParams['status'] = status;
      if (dateFrom != null) queryParams['dateFrom'] = dateFrom;
      if (dateTo != null) queryParams['dateTo'] = dateTo;

      final uri = Uri.parse('$baseUrl/orders/search').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Order.fromJson(item)).toList();
      } else {
        throw Exception('Ошибка поиска заказов: ${response.body}');
      }
    }
  }

  // Метод для получения списка курьеров
  Future<List<Map<String, dynamic>>> getCouriers() async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1)); // Имитация задержки сети
      return MockDataService.getMockCouriers();
    } else {
      final response = await http.get(
        Uri.parse('$baseUrl/users/couriers'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Ошибка получения списка курьеров: ${response.body}');
      }
    }
  }

  // Метод для получения статистики
  Future<Map<String, dynamic>> getStatistics() async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1)); // Имитация задержки сети
      return MockDataService.getMockStatistics();
    } else {
      final response = await http.get(
        Uri.parse('$baseUrl/statistics'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Ошибка получения статистики: ${response.body}');
      }
    }
  }

  // Метод для авторизации
  Future<Map<String, dynamic>> login(String username, String password) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1)); // Имитация задержки сети
      print('Попытка входа с моковыми данными: $username, пароль скрыт');
      
      // Тестовые пользователи для разных ролей
      if (username == 'ivanov' && password == '1234') {
        print('Успешный вход kuriera');
        return {
          'token': 'mock_token_courier',
          'role': 'courier',
          'userId': 'courier_id_1'
        };
      } else if (username == 'petrova' && password == '1234') {
        print('Успешный вход бухгалтера');
        return {
          'token': 'mock_token_accountant',
          'role': 'accountant',
          'userId': 'accountant_id_1'
        };
      } else if (username == 'sidorov' && password == '1234') {
        print('Успешный вход директора');
        return {
          'token': 'mock_token_director',
          'role': 'director',
          'userId': 'director_id_1'
        };
      } else {
        print('Неудачный вход: неверные учетные данные');
        throw Exception('Неверный логин или пароль');
      }
    } else {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': username,
            'password': password,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          headers['Authorization'] = 'Bearer ${data['token']}';
          return data;
        } else {
          throw Exception('Ошибка авторизации: ${response.body}');
        }
      } catch (e) {
        print('Ошибка HTTP при входе: $e');
        rethrow;
      }
    }
  }

  // Метод для назначения курьера
  Future<void> assignCourier(String orderId, String courierId) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1)); // Имитация задержки сети
      return;
    } else {
      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$orderId/assign'),
        headers: headers,
        body: jsonEncode({'courierId': courierId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка при назначении курьера: ${response.body}');
      }
    }
  }

  // Метод для загрузки файла
  Future<void> uploadFile(String endpoint, String filePath, {Function(int)? onProgress}) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 2)); // Имитация задержки сети
      return; // В тестовом режиме просто имитируем успешную загрузку
    } else {
      // Реальная загрузка файла...
      throw UnimplementedError('Загрузка файла в реальном API не реализована');
    }
  }

  // Метод для скачивания файла
  Future<void> downloadFile(String endpoint, String savePath, {Function(int)? onProgress}) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 2)); // Имитация задержки сети
      return; // В тестовом режиме просто имитируем успешное скачивание
    } else {
      // Реальное скачивание файла...
      throw UnimplementedError('Скачивание файла в реальном API не реализовано');
    }
  }
}