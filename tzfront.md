# Техническое задание для Flutter-приложения

## Целевая аудитория
1. **Курьер**: Управление своими заказами.
2. **Бухгалтер**: Загрузка и управление заказами.
3. **Директор**: Анализ и управление процессами.

---

## Основные экраны и функционал

### 1. Авторизация (общий экран для всех ролей)
- Поля: Логин, Пароль.
- Кнопка: "Войти".
- Редирект на соответствующий экран в зависимости от роли пользователя.

---

### 2. Курьер
- **Список заказов на день**:
  - Отображение заказов со статусом "ожидание".
  - Кнопка "Взять заказ".
- **Мои заказы**:
  - Список текущих заказов.
  - Возможность изменить статус заказа на "доставлен".
- **История доставок**:
  - Архив всех доставленных заказов.

---

### 3. Бухгалтер
- **Загрузка заказов**:
  - Возможность загрузки заказов вручную или через файл (Excel/CSV).
- **Просмотр доставленных заказов**:
  - Фильтрация по дате, курьеру.
- **Выгрузка отчётов**:
  - Генерация отчётов в формате Excel/CSV.
- **Расчёт суммы**:
  - Автоматический расчёт суммы за день/неделю.

---

### 4. Директор
- **Поиск и фильтрация заказов**:
  - Поиск по номеру заказа, курьеру, статусу.
- **Назначение курьера вручную**:
  - Возможность переназначить курьера для заказа.
- **Статистика**:
  - Графики и таблицы: количество доставленных заказов, суммы, активность курьеров.

---

## Технические детали
1. **Flutter**:
   - Использование Material Design для UI.
   - Поддержка Android (в дальнейшем можно добавить iOS).
2. **Навигация**:
   - Использование `Navigator` или `go_router` для маршрутизации.
3. **Управление состоянием**:
   - Провайдер (`Provider`) или `Riverpod` для управления состоянием.
4. **Моковые данные**:
   - Для тестирования фронтенда до интеграции с backend.
5. **Роли пользователей**:
   - Реализация через условный рендеринг интерфейса на основе роли.

---

## Структура проекта
- `lib/`
  - `screens/` — экраны приложения.
    - `auth/` — экран авторизации.
    - `courier/` — экраны для курьера.
    - `accountant/` — экраны для бухгалтера.
    - `director/` — экраны для директора.
  - `widgets/` — общие виджеты.
  - `models/` — модели данных.
  - `services/` — сервисы для работы с API.
  - `providers/` — управление состоянием.