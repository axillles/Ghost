# Реализация системы подписок

## Что было сделано

### 1. Создан экран подписок (SubscriptionView)
- Красивый UI с двумя вариантами подписки (месяц и год)
- Отображение цен из Revenue Cat
- Индикация рекомендуемого плана (годовая подписка)
- Список преимуществ Premium
- Кнопки для покупки и восстановления подписок
- Ссылки на Terms of Service и Privacy Policy

### 2. Интеграция Revenue Cat
- Создан `SubscriptionService` для работы с Revenue Cat SDK
- Настроена инициализация Revenue Cat
- Реализована проверка статуса подписки
- Обновление статуса подписки после покупки

### 3. ViewModel для подписок
- `SubscriptionViewModel` управляет состоянием экрана подписок
- Загрузка предложений из Revenue Cat
- Обработка покупок и восстановления
- Обработка ошибок

### 4. Интеграция в приложение
- Экран подписок появляется через 5 секунд после завершения онбординга
- Показывается только если нет активной подписки
- Обновление статуса Premium после успешной покупки

### 5. Подготовка к App Store Connect
- Создан файл `Ghost.entitlements` для In-App Purchases
- Обновлен `PaywallService` для работы с Revenue Cat
- Создана документация по настройке

## Структура файлов

```
Ghost/
├── Views/
│   └── SubscriptionView.swift          # Экран подписок
├── ViewModels/
│   └── SubscriptionViewModel.swift    # ViewModel подписок
├── Services/
│   ├── SubscriptionService.swift      # Сервис Revenue Cat
│   └── PaywallService.swift            # Обновлен для Revenue Cat
├── Ghost.entitlements                   # Entitlements для IAP
└── GhostApp.swift                       # Обновлен для показа подписок
```

## Следующие шаги

1. **Добавить Revenue Cat SDK**:
   - Откройте проект в Xcode
   - Добавьте пакет: `https://github.com/RevenueCat/purchases-ios`
   - Следуйте инструкциям в `REVENUE_CAT_SETUP.md`

2. **Настроить Revenue Cat Dashboard**:
   - Создайте проект в Revenue Cat
   - Добавьте приложение с Bundle ID: `com.axillles`
   - Создайте продукты и offerings
   - Скопируйте API ключ

3. **Настроить App Store Connect**:
   - Создайте подписки (месяц и год)
   - Настройте Subscription Group
   - Следуйте инструкциям в `APP_STORE_CONNECT_SETUP.md`

4. **Обновить API ключ**:
   - Откройте `SubscriptionService.swift`
   - Замените `YOUR_REVENUE_CAT_API_KEY` на ваш ключ

5. **Обновить ссылки**:
   - В `SubscriptionView.swift` обновите URL для Terms и Privacy Policy

6. **Протестировать**:
   - Используйте Sandbox тестовый аккаунт
   - Протестируйте покупки и восстановление
   - Проверьте работу на реальных устройствах

## Важные замечания

- **API ключ Revenue Cat**: Не коммитьте ключ в репозиторий! Используйте переменные окружения или конфигурационные файлы.
- **Product IDs**: Убедитесь, что Product IDs в App Store Connect совпадают с теми, что настроены в Revenue Cat.
- **Entitlements**: Файл `Ghost.entitlements` должен быть добавлен к проекту в Xcode.
- **Тестирование**: Всегда тестируйте подписки через Sandbox перед публикацией.

## Документация

- `REVENUE_CAT_SETUP.md` - Подробная инструкция по настройке Revenue Cat
- `APP_STORE_CONNECT_SETUP.md` - Инструкция по подготовке к App Store Connect
- `README.md` - Обновлен с информацией о подписках
