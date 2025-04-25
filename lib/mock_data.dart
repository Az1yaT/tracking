class MockUser {
  final String username;
  final String password;
  final String role;

  MockUser({required this.username, required this.password, required this.role});
}

// Список пользователей с ролями
final List<MockUser> mockUsers = [
  MockUser(username: 'courier1', password: '1234', role: 'courier'),
  MockUser(username: 'accountant1', password: '1234', role: 'accountant'),
  MockUser(username: 'director1', password: '1234', role: 'director'),
];