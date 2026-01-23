# Тестирование Paywall без Apple ID

## ✅ Да, можно тестировать без Apple ID!

RevenueCat предоставляет **Test Store**, который позволяет:
- ✅ Тестировать paywall в симуляторе iOS
- ✅ Видеть как выглядит paywall из RevenueCat Dashboard
- ✅ Тестировать UI и навигацию
- ✅ Не требует Apple ID или Sandbox аккаунт

## Как протестировать

### 1. Запуск в симуляторе

1. Откройте проект в Xcode
2. Выберите симулятор iOS (любой)
3. Запустите приложение (Cmd+R)
4. Paywall автоматически загрузит конфигурацию из RevenueCat Dashboard

### 2. Где показать paywall

Paywall показывается в следующих местах:
- **Settings (Настройки)** - нажмите на кнопку Premium/Subscription
- **MainView** - когда требуется Premium доступ
- **После онбординга** - автоматически через 5 секунд (если нет активной подписки)

### 3. Быстрый просмотр в Preview

В Xcode можно использовать Preview для быстрого просмотра:
1. Откройте `PaywallView.swift`
2. Нажмите на иконку Preview справа
3. Paywall отобразится в Preview (может показать ошибку, если RevenueCat не настроен)

## Что вы увидите

PaywallView от RevenueCat автоматически:
- Загружает конфигурацию из RevenueCat Dashboard
- Показывает цены и планы подписки
- Отображает дизайн, настроенный в Dashboard
- Показывает все продукты, которые вы настроили

## Ограничения тестирования без Apple ID

⚠️ **Без Apple ID вы НЕ сможете:**
- Совершить реальную покупку
- Протестировать процесс покупки до конца
- Получить реальные entitlements

✅ **Но вы МОЖЕТЕ:**
- Увидеть как выглядит paywall
- Проверить UI и дизайн
- Убедиться, что конфигурация загружается правильно
- Протестировать навигацию

## Для полного тестирования покупок

Если нужно протестировать реальные покупки:

1. **Создайте Sandbox тестер в App Store Connect:**
   - App Store Connect → Users and Access → Sandbox Testers
   - Создайте тестовый аккаунт

2. **Войдите в Sandbox на устройстве:**
   - Настройки → App Store → Sandbox Account
   - Войдите с тестовым аккаунтом

3. **Тестируйте покупки:**
   - Покупки будут работать с тестовым аккаунтом
   - Деньги не списываются
   - Подписки истекают быстрее для тестирования

## Проверка конфигурации

Убедитесь, что в RevenueCat Dashboard:
- ✅ Настроен Paywall (Paywalls → Create Paywall)
- ✅ Настроены Products (Products → Add Product)
- ✅ Настроены Offerings (Offerings → Create Offering)
- ✅ API ключ правильный (тестовый ключ работает для тестирования)

## Отладка

Если paywall не загружается:
1. Проверьте консоль Xcode на ошибки
2. Убедитесь, что RevenueCatUI добавлен в проект
3. Проверьте, что API ключ правильный в `SubscriptionService.swift`
4. Убедитесь, что в Dashboard настроен Paywall и Offering

## Полезные ссылки

- [RevenueCat Test Store Documentation](https://www.revenuecat.com/docs/test-and-launch/test-store)
- [RevenueCat Sandbox Testing](https://www.revenuecat.com/docs/test-and-launch/sandbox)
