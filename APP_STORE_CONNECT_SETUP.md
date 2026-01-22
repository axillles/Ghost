# Подготовка проекта к публикации в App Store Connect

## Шаг 1: Настройка Bundle Identifier и Signing

1. Откройте проект в Xcode
2. Выберите проект в навигаторе
3. Выберите таргет `Ghost`
4. Перейдите на вкладку **Signing & Capabilities**
5. Убедитесь, что:
   - **Team** выбран правильно
   - **Bundle Identifier** установлен (например: `com.axillles`)
   - **Automatically manage signing** включен

## Шаг 2: Добавление Entitlements

1. В той же вкладке **Signing & Capabilities**
2. Нажмите **+ Capability**
3. Добавьте **In-App Purchase**
4. Убедитесь, что файл `Ghost.entitlements` добавлен к проекту

## Шаг 3: Настройка Info.plist

Настройки Info.plist уже включены в проект через build settings. Проверьте следующие ключи:

- `NSCameraUsageDescription` - описание использования камеры
- `NSMicrophoneUsageDescription` - описание использования микрофона

Эти настройки уже добавлены в `project.pbxproj`.

## Шаг 4: Создание App в App Store Connect

1. Войдите в [App Store Connect](https://appstoreconnect.apple.com)
2. Перейдите в **My Apps**
3. Нажмите **+** для создания нового приложения
4. Заполните информацию:
   - **Name**: Ghost Detector (или ваше название)
   - **Primary Language**: Russian (или ваш язык)
   - **Bundle ID**: Выберите ваш Bundle Identifier
   - **SKU**: Уникальный идентификатор (например: `ghost-detector-001`)

## Шаг 5: Настройка In-App Purchases

### Создание Subscription Group

1. В App Store Connect перейдите в раздел **In-App Purchases**
2. Нажмите **Manage** рядом с **Subscription Groups**
3. Создайте новую группу: **Ghost Premium** (или другое название)
4. Установите Reference Name (например: "Ghost Premium Subscriptions")

### Создание месячной подписки

1. В разделе **In-App Purchases** нажмите **+** → **Auto-Renewable Subscription**
2. Заполните информацию:
   - **Subscription Group**: Выберите созданную группу
   - **Product ID**: `com.axillles.ghost.monthly` (или ваш формат)
   - **Reference Name**: Ghost Premium Monthly
   - **Subscription Duration**: 1 Month
3. Нажмите **Create**
4. Заполните метаданные:
   - **Display Name**: Premium (Месяц)
   - **Description**: Описание подписки
5. Установите цены для всех регионов
6. Добавьте скриншоты (если требуется)

### Создание годовой подписки

1. В разделе **In-App Purchases** нажмите **+** → **Auto-Renewable Subscription**
2. Заполните информацию:
   - **Subscription Group**: Та же группа, что и для месячной подписки
   - **Product ID**: `com.axillles.ghost.yearly` (или ваш формат)
   - **Reference Name**: Ghost Premium Yearly
   - **Subscription Duration**: 1 Year
3. Нажмите **Create**
4. Заполните метаданные:
   - **Display Name**: Premium (Год)
   - **Description**: Описание подписки
5. Установите цены для всех регионов
6. Добавьте скриншоты (если требуется)

### Настройка Subscription Terms

1. Для каждой подписки перейдите в раздел **Subscription Terms**
2. Заполните:
   - **Subscription Terms**: Условия подписки
   - **Privacy Policy URL**: URL вашей политики конфиденциальности
   - **Subscription Localizations**: Локализация для разных языков

## Шаг 6: Настройка Revenue Cat

Следуйте инструкциям в файле `REVENUE_CAT_SETUP.md` для настройки Revenue Cat Dashboard.

## Шаг 7: Обновление Product IDs в коде

Если вы использовали другие Product IDs, обновите их в следующих местах:

1. **Revenue Cat Dashboard**: Убедитесь, что Product IDs совпадают
2. **SubscriptionViewModel.swift**: Проверьте логику определения типов подписок

## Шаг 8: Тестирование

### Sandbox Testing

1. Создайте Sandbox тестовый аккаунт в App Store Connect:
   - Перейдите в **Users and Access** → **Sandbox Testers**
   - Создайте новый тестовый аккаунт
2. На устройстве выйдите из App Store
3. Запустите приложение
4. При покупке используйте Sandbox аккаунт

### TestFlight

1. Соберите архив приложения в Xcode:
   - Product → Archive
2. Загрузите в App Store Connect:
   - Window → Organizer
   - Выберите архив → Distribute App
   - Следуйте инструкциям
3. В App Store Connect перейдите в **TestFlight**
4. Добавьте внутренних тестеров
5. Протестируйте подписки через TestFlight

## Шаг 9: Подготовка к публикации

1. Заполните все обязательные поля в App Store Connect:
   - Описание приложения
   - Ключевые слова
   - Скриншоты (для всех размеров устройств)
   - Иконка приложения
   - Политика конфиденциальности URL
2. Установите возрастной рейтинг
3. Заполните информацию о подписках
4. Подготовьте описание для App Review

## Шаг 10: Важные замечания

### Безопасность

- **НЕ коммитьте API ключи Revenue Cat в репозиторий!**
- Используйте переменные окружения или конфигурационные файлы
- Для продакшена используйте Production API Key

### Соответствие требованиям App Store

- Убедитесь, что все подписки находятся в одной Subscription Group
- Проверьте, что цены установлены для всех регионов
- Убедитесь, что Terms of Service и Privacy Policy доступны
- Проверьте, что все метаданные заполнены

### Тестирование перед публикацией

- Протестируйте покупки через Sandbox
- Протестируйте восстановление покупок
- Проверьте работу на разных устройствах
- Убедитесь, что экран подписок появляется корректно

## Полезные ссылки

- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [In-App Purchase Guide](https://developer.apple.com/in-app-purchase/)
- [Revenue Cat Documentation](https://docs.revenuecat.com/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

## Чеклист перед отправкой на ревью

- [ ] Bundle Identifier настроен
- [ ] Signing настроен правильно
- [ ] In-App Purchase capability добавлена
- [ ] Подписки созданы в App Store Connect
- [ ] Revenue Cat настроен и протестирован
- [ ] API ключ Revenue Cat обновлен в коде
- [ ] Product IDs совпадают в App Store Connect и Revenue Cat
- [ ] Sandbox тестирование пройдено
- [ ] TestFlight тестирование пройдено
- [ ] Все метаданные заполнены
- [ ] Privacy Policy URL добавлен
- [ ] Terms of Service добавлены
- [ ] Скриншоты добавлены
- [ ] Описание приложения заполнено
