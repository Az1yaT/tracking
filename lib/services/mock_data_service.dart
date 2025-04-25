import '../models/order.dart';

class MockDataService {
  // Метод для проверки авторизации пользователей
  static Map<String, dynamic>? authenticateUser(String username, String password) {
    final users = getMockUsers();
    
    for (var user in users) {
      if (user['username'] == username && password == '1234') {
        // Возвращаем копию пользователя без пароля для безопасности
        final authenticatedUser = Map<String, dynamic>.from(user);
        authenticatedUser.remove('password');
        authenticatedUser['token'] = 'mock-jwt-token-${DateTime.now().millisecondsSinceEpoch}';
        return authenticatedUser;
      }
    }
    
    return null; // Пользователь не найден или неверный пароль
  }

  // Метод для получения списка тестовых пользователей
  static List<Map<String, dynamic>> getMockUsers() {
    return [
      {
        'id': 'courier1',
        'username': 'ivanov',
        'password': '1234', // В реальном приложении пароли должны быть хешированы
        'role': 'courier',
        'firstName': 'Иван',
        'lastName': 'Иванов',
        'phone': '+7 (999) 123-45-67'
      },
      {
        'id': 'accountant1',
        'username': 'petrova',
        'password': '1234',
        'role': 'accountant',
        'firstName': 'Мария',
        'lastName': 'Петрова',
        'phone': '+7 (999) 765-43-21'
      },
      {
        'id': 'director1',
        'username': 'sidorov',
        'password': '1234',
        'role': 'director',
        'firstName': 'Алексей',
        'lastName': 'Сидоров',
        'phone': '+7 (999) 555-55-55'
      },
    ];
  }

  // Метод для получения тестовых заказов
  static List<Map<String, dynamic>> getMockOrders() {
    final now = DateTime.now();
    return [
      {
        'id': 'order1',
        'sender_name': 'ООО "Рога и копыта"',
        'sender_phone': '+7 (495) 123-45-67',
        'receiver_name': 'Иванов И.И.',
        'receiver_phone': '+7 (999) 123-45-67',
        'address': 'г. Москва, ул. Ленина, д. 1',
        'status': 'новый',
        'courier_id': null,
        'courier_name': null,
        'price': 1500,
        'created_at': now.subtract(const Duration(days: 2)).toIso8601String(),
        'updated_at': now.subtract(const Duration(days: 2)).toIso8601String()
      },
      {
        'id': 'order2',
        'sender_name': 'ИП Сидоров',
        'sender_phone': '+7 (495) 765-43-21',
        'receiver_name': 'Петров П.П.',
        'receiver_phone': '+7 (999) 765-43-21',
        'address': 'г. Москва, ул. Пушкина, д. 10',
        'status': 'в пути',
        'courier_id': 'courier1',
        'courier_name': 'Иванов И.И.',
        'price': 2500,
        'created_at': now.subtract(const Duration(days: 1)).toIso8601String(),
        'updated_at': now.toIso8601String()
      },
      {
        'id': 'order3',
        'sender_name': 'ЗАО "Технологии"',
        'sender_phone': '+7 (495) 555-55-55',
        'receiver_name': 'Сидоров С.С.',
        'receiver_phone': '+7 (999) 555-55-55',
        'address': 'г. Москва, ул. Гагарина, д. 5',
        'status': 'доставлен',
        'courier_id': 'courier1',
        'courier_name': 'Иванов И.И.',
        'price': 3500,
        'created_at': now.subtract(const Duration(days: 3)).toIso8601String(),
        'updated_at': now.subtract(const Duration(hours: 5)).toIso8601String()
      },
    ];
  }
  
  // Метод для получения тестовых курьеров
  static List<Map<String, dynamic>> getMockCouriers() {
    return getMockUsers()
        .where((user) => user['role'] == 'courier')
        .map((user) {
          final courier = Map<String, dynamic>.from(user);
          courier.remove('password'); // Убираем пароль из данных
          return courier;
        })
        .toList();
  }

  // Метод для получения тестовых статистических данных
  static Map<String, dynamic> getMockStatistics() {
    return {
      'total_orders': 100,
      'completed_orders': 75,
      'in_progress_orders': 20,
      'cancelled_orders': 5,
      'total_revenue': 175000,
      'average_delivery_time': 25,
      'courier_performance': [
        {
          'courier_id': 'courier1',
          'courier_name': 'Иванов И.И.',
          'delivered_count': 45,
          'average_time': 22,
          'total_revenue': 85000
        },
        {
          'courier_id': 'courier2',
          'courier_name': 'Кузнецов К.К.',
          'delivered_count': 30,
          'average_time': 29,
          'total_revenue': 90000
        }
      ],
      'daily_orders': [
        {'date': '2023-06-01', 'count': 8, 'revenue': 16000},
        {'date': '2023-06-02', 'count': 10, 'revenue': 20000},
        {'date': '2023-06-03', 'count': 7, 'revenue': 14000},
        {'date': '2023-06-04', 'count': 12, 'revenue': 24000},
        {'date': '2023-06-05', 'count': 9, 'revenue': 18000},
        {'date': '2023-06-06', 'count': 11, 'revenue': 22000},
        {'date': '2023-06-07', 'count': 13, 'revenue': 26000}
      ]
    };
  }
}