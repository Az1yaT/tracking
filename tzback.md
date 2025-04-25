# Техническое задание для backend на Java

## **Технологический стек**
- **Язык программирования**: Java 17+
- **Фреймворк**: Spring Boot 3.x
- **База данных**: PostgreSQL 15+
- **ORM**: Hibernate/Spring Data JPA
- **API**: RESTful API с использованием Spring Web
- **Аутентификация**: JWT (Spring Security)
- **Документация API**: Swagger/OpenAPI 3.0
- **Миграции БД**: Flyway/Liquibase
- **Управление зависимостями**: Maven/Gradle
- **Тестирование**: JUnit 5, Mockito, TestContainers
- **Логирование**: SLF4J, Logback
- **Валидация**: Hibernate Validator
- **Работа с Excel/CSV**: Apache POI, OpenCSV

## **Цели**
Создать backend-сервис для управления курьерскими заказами, который будет предоставлять REST API для взаимодействия с Flutter-приложением. Сервис должен поддерживать авторизацию пользователей, управление заказами, генерацию отчетов и предоставление статистики. Все данные пользователей должны храниться в базе данных PostgreSQL.

---

## **Основные функции**

### **1. Авторизация и управление пользователями**
- **Авторизация**:
  - Endpoint: `POST /auth/login`
  - Принимает JSON с полями `username` и `password`
  - Возвращает JWT токен, роль пользователя и ID пользователя в формате: 
    ```json
    {
      "token": "jwt_token_string",
      "role": "courier|accountant|director",
      "userId": "user_id_string"
    }
    ```

- **Управление пользователями**:
  - CRUD-операции для пользователей (создание, чтение, обновление, удаление)
  - Endpoint для получения списка курьеров: `GET /users/couriers`
  - Endpoint для обновления данных пользователя: `PUT /users/{id}`

---

### **2. Управление заказами**
- **Получение списка заказов**:
  - Endpoint: `GET /orders`
  - Возвращает список всех заказов
  
- **Фильтрация и поиск заказов**:
  - Endpoint: `GET /orders/search`
  - Параметры запроса (query parameters):
    - `orderId` - поиск по номеру заказа
    - `courierId` - фильтрация по курьеру
    - `status` - фильтрация по статусу
    - `dateFrom` - фильтрация по дате (от)
    - `dateTo` - фильтрация по дате (до)

- **Получение заказов курьера**:
  - Endpoint: `GET /orders/courier/{courierId}`
  - Возвращает список заказов, назначенных на указанного курьера

- **Обновление статуса заказа**:
  - Endpoint: `PATCH /orders/{orderId}/status`
  - Принимает JSON с полем `status` (возможные значения: `новый`, `в пути`, `доставлен`)

- **Назначение курьера для заказа**:
  - Endpoint: `PATCH /orders/{orderId}/assign`
  - Принимает JSON с полем `courierId`

- **Импорт и экспорт заказов**:
  - Endpoint для загрузки заказов из файла: `POST /orders/import`
  - Endpoint для выгрузки отчета в Excel/CSV: `GET /orders/export`

---

### **3. Статистика и отчеты**
- **Получение статистики**:
  - Endpoint: `GET /statistics`
  - Возвращает данные для директора:
    ```json
    {
      "total_orders": 100,
      "completed_orders": 75,
      "in_progress_orders": 20,
      "cancelled_orders": 5,
      "total_revenue": 175000,
      "average_delivery_time": 25,
      "courier_performance": [
        {
          "courier_id": "courier_id_1",
          "courier_name": "Иванов И.И.",
          "delivered_count": 45,
          "average_time": 22,
          "total_revenue": 85000
        }
      ],
      "daily_orders": [
        {"date": "2023-06-01", "count": 8, "revenue": 16000}
      ]
    }
    ```

---

## **Технические требования**

### **1. Технологии**
- **Язык**: Java 17+.
- **Фреймворк**: Spring Boot.
- **База данных**: PostgreSQL.
- **ORM**: Hibernate/Spring Data JPA.
- **API**: RESTful API с использованием Spring Web.
- **Документация API**: Swagger/OpenAPI.
- **Аутентификация**: JWT с использованием Spring Security.

---

### **2. Архитектура**
- **Модуль "Пользователи"**:
  - Таблица `users`:
    - Поля:
      - `id` (UUID, Primary Key)
      - `username` (String, уникальный)
      - `password` (String, хэшированный)
      - `role` (String, ENUM: "courier", "accountant", "director")
      - `created_at` (Timestamp)
      - `updated_at` (Timestamp)
      - `first_name` (String)
      - `last_name` (String)
      - `phone` (String)
- **Модуль "Заказы"**:
  - Таблица `orders`:
    - Поля:
      - `id` (UUID, Primary Key)
      - `sender_name` (String)
      - `sender_phone` (String)
      - `receiver_name` (String)
      - `receiver_phone` (String)
      - `address` (String)
      - `status` (String, ENUM: "новый", "в пути", "доставлен")
      - `courier_id` (UUID, Foreign Key на `users.id`)
      - `price` (Decimal)
      - `created_at` (Timestamp)
      - `updated_at` (Timestamp)
- **Модуль "Отчеты"**:
  - Генерация отчетов на основе данных из таблицы `orders`.
- **Многослойная архитектура**:
  - Controllers (API endpoints)
  - Services (бизнес-логика)
  - Repositories (доступ к данным)
  - Entities/DTOs (модели данных)

---

### **3. Безопасность**
- Использование JWT для аутентификации.
- Роли и права доступа:
  - Курьер: доступ только к своим заказам.
  - Бухгалтер: доступ к загрузке и просмотру заказов.
  - Директор: доступ к статистике и управлению заказами.
- Хеширование паролей с использованием BCrypt.
- Защита от CSRF, XSS и SQL-инъекций.

---

### **4. Эндпоинты API**

#### **1. Авторизация**
- `POST /auth/login`: Авторизация пользователя.
- `POST /auth/register`: Регистрация нового пользователя.

#### **2. Управление заказами**
- `GET /orders`: Получение списка заказов (с фильтрацией).
- `GET /orders/search`: Фильтрация и поиск заказов.
- `GET /orders/courier/{courierId}`: Получение заказов курьера.
- `POST /orders`: Создание нового заказа.
- `PATCH /orders/{orderId}/status`: Обновление статуса заказа.
- `PATCH /orders/{orderId}/assign`: Назначение курьера для заказа.
- `POST /orders/import`: Загрузка заказов из файла.
- `GET /orders/export`: Выгрузка отчета в Excel/CSV.
- `DELETE /orders/{id}`: Удаление заказа.

#### **3. Отчеты**
- `GET /reports`: Генерация отчета (с фильтрацией по дате, курьеру).

#### **4. Пользователи**
- `GET /users`: Получение списка пользователей.
- `GET /users/couriers`: Получение списка курьеров.
- `POST /users`: Создание нового пользователя.
- `PUT /users/{id}`: Обновление данных пользователя.
- `DELETE /users/{id}`: Удаление пользователя.

#### **5. Статистика**
- `GET /statistics`: Получение статистики.

---

## **Структура данных**

### **1. Пользователи (users)**
```json
{
  "id": "string",
  "username": "string",
  "password": "string (hashed)",
  "role": "courier|accountant|director",
  "firstName": "string",
  "lastName": "string",
  "phone": "string"
}
```

### **2. Заказы (orders)**
```json
{
  "id": "string",
  "sender_name": "string",
  "sender_phone": "string",
  "receiver_name": "string",
  "receiver_phone": "string",
  "address": "string",
  "status": "новый|в пути|доставлен",
  "courier_id": "string|null",
  "courier_name": "string|null",
  "price": "number",
  "created_at": "datetime string",
  "updated_at": "datetime string"
}
```