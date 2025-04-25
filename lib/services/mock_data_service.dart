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
        'phone': '+7 (999) 123-45-67',
        'fullName': 'Иван Иванов'
      },
      {
        'id': 'courier2',
        'username': 'petrov',
        'password': '1234', 
        'role': 'courier',
        'firstName': 'Петр',
        'lastName': 'Петров',
        'phone': '+7 (999) 987-65-43',
        'fullName': 'Петр Петров'
      },
      {
        'id': 'courier3',
        'username': 'smirnov',
        'password': '1234', 
        'role': 'courier',
        'firstName': 'Алексей',
        'lastName': 'Смирнов',
        'phone': '+7 (999) 555-77-33',
        'fullName': 'Алексей Смирнов'
      },
      {
        'id': 'courier4',
        'username': 'kuznetsov',
        'password': '1234', 
        'role': 'courier',
        'firstName': 'Дмитрий',
        'lastName': 'Кузнецов',
        'phone': '+7 (999) 444-22-11',
        'fullName': 'Дмитрий Кузнецов'
      },
      {
        'id': 'courier5',
        'username': 'sokolov',
        'password': '1234', 
        'role': 'courier',
        'firstName': 'Артем',
        'lastName': 'Соколов',
        'phone': '+7 (999) 888-33-22',
        'fullName': 'Артем Соколов'
      },
      {
        'id': 'accountant1',
        'username': 'petrova',
        'password': '1234',
        'role': 'accountant',
        'firstName': 'Мария',
        'lastName': 'Петрова',
        'phone': '+7 (999) 765-43-21',
        'fullName': 'Мария Петрова'
      },
      {
        'id': 'director1',
        'username': 'sidorov',
        'password': '1234',
        'role': 'director',
        'firstName': 'Сергей',
        'lastName': 'Сидоров',
        'phone': '+7 (999) 555-55-55',
        'fullName': 'Сергей Сидоров'
      },
    ];
  }

  // Метод для получения списка тестовых курьеров
  static List<Map<String, dynamic>> getMockCouriers() {
    return getMockUsers()
        .where((user) => user['role'] == 'courier')
        .map((user) {
          // Создаем копию объекта без пароля для безопасности
          final courierInfo = Map<String, dynamic>.from(user);
          courierInfo.remove('password');
          return courierInfo;
        })
        .toList();
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
        'courier_name': 'Иван Иванов',
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
        'courier_name': 'Иван Иванов',
        'price': 3500,
        'created_at': now.subtract(const Duration(days: 3)).toIso8601String(),
        'updated_at': now.subtract(const Duration(hours: 5)).toIso8601String()
      },
      {
        'id': 'order4',
        'sender_name': 'ООО "Цветочный рай"',
        'sender_phone': '+7 (495) 222-33-44',
        'receiver_name': 'Васильева А.П.',
        'receiver_phone': '+7 (999) 222-33-44',
        'address': 'г. Москва, ул. Арбат, д. 15, кв. 7',
        'status': 'новый',
        'courier_id': null,
        'courier_name': null,
        'price': 1200,
        'created_at': now.subtract(const Duration(hours: 5)).toIso8601String(),
        'updated_at': now.subtract(const Duration(hours: 5)).toIso8601String()
      },
      {
        'id': 'order5',
        'sender_name': 'ИП Кузнецов',
        'sender_phone': '+7 (495) 987-65-43',
        'receiver_name': 'Соколова Е.В.',
        'receiver_phone': '+7 (999) 333-22-11',
        'address': 'г. Москва, пр. Мира, д. 78, кв. 42',
        'status': 'в пути',
        'courier_id': 'courier2',
        'courier_name': 'Петр Петров',
        'price': 1800,
        'created_at': now.subtract(const Duration(days: 1)).toIso8601String(),
        'updated_at': now.subtract(const Duration(hours: 8)).toIso8601String()
      },
      {
        'id': 'order6',
        'sender_name': 'ООО "Электроника"',
        'sender_phone': '+7 (495) 777-88-99',
        'receiver_name': 'Козлов Д.А.',
        'receiver_phone': '+7 (999) 777-88-99',
        'address': 'г. Москва, ул. Тверская, д. 25, кв. 17',
        'status': 'новый',
        'courier_id': null,
        'courier_name': null,
        'price': 4500,
        'created_at': now.subtract(const Duration(hours: 10)).toIso8601String(),
        'updated_at': now.subtract(const Duration(hours: 10)).toIso8601String()
      },
    ];
  }

  // Метод для получения тестовой статистики
  static Map<String, dynamic> getMockStatistics() {
    return {
      'total_orders': 150,
      'completed_orders': 95,
      'in_progress_orders': 35,
      'cancelled_orders': 20,
      'total_revenue': 285000,
      'average_delivery_time': 28,
      'courier_performance': [
        {
          'courier_id': 'courier1',
          'courier_name': 'Иван Иванов',
          'delivered_count': 45,
          'average_time': 22,
          'total_revenue': 85000
        },
        {
          'courier_id': 'courier2',
          'courier_name': 'Петр Петров',
          'delivered_count': 30,
          'average_time': 29,
          'total_revenue': 90000
        },
        {
          'courier_id': 'courier3',
          'courier_name': 'Алексей Смирнов',
          'delivered_count': 25,
          'average_time': 31,
          'total_revenue': 75000
        },
        {
          'courier_id': 'courier4',
          'courier_name': 'Дмитрий Кузнецов',
          'delivered_count': 15,
          'average_time': 35,
          'total_revenue': 45000
        },
        {
          'courier_id': 'courier5',
          'courier_name': 'Артем Соколов',
          'delivered_count': 10,
          'average_time': 27,
          'total_revenue': 30000
        }
      ],
      'daily_orders': [
        {'date': '2023-06-01', 'count': 12, 'revenue': 24000},
        {'date': '2023-06-02', 'count': 15, 'revenue': 30000},
        {'date': '2023-06-03', 'count': 10, 'revenue': 20000},
        {'date': '2023-06-04', 'count': 18, 'revenue': 36000},
        {'date': '2023-06-05', 'count': 14, 'revenue': 28000},
        {'date': '2023-06-06', 'count': 16, 'revenue': 32000},
        {'date': '2023-06-07', 'count': 20, 'revenue': 40000}
      ]
    };
  }
}