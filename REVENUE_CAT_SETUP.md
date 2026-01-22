# Настройка Revenue Cat для Ghost App

## Шаг 1: Добавление Revenue Cat SDK

1. Откройте проект `Ghost.xcodeproj` в Xcode
2. Выберите проект в навигаторе
3. Перейдите на вкладку **Package Dependencies**
4. Нажмите кнопку **+** для добавления новой зависимости
5. Введите URL: `https://github.com/RevenueCat/purchases-ios`
6. Выберите версию (рекомендуется последняя стабильная версия)
7. Нажмите **Add Package**
8. Убедитесь, что пакет `RevenueCat` добавлен к таргету `Ghost`

## Шаг 2: Настройка Revenue Cat Dashboard

1. Зарегистрируйтесь или войдите в [Revenue Cat Dashboard](https://app.revenuecat.com)
2. Создайте новый проект или выберите существующий
3. Добавьте новое приложение:
   - **Bundle ID**: `com.axillles` (или ваш Bundle ID)
   - **Platform**: iOS
4. Скопируйте **Public API Key** (начинается с `appl_` или `rcapi_`)

## Шаг 3: Настройка App Store Connect

1. Войдите в [App Store Connect](https://appstoreconnect.apple.com)
2. Создайте новое приложение или выберите существующее
3. Перейдите в раздел **In-App Purchases**
4. Создайте две подписки:

   ### Подписка на месяц:
   - **Product ID**: `com.axillles.ghost.monthly` (или ваш формат)
   - **Type**: Auto-Renewable Subscription
   - **Subscription Group**: Создайте новую группу (например, "Ghost Premium")
   - **Duration**: 1 Month
   - Установите цену для всех регионов

   ### Подписка на год:
   - **Product ID**: `com.axillles.ghost.yearly` (или ваш формат)
   - **Type**: Auto-Renewable Subscription
   - **Subscription Group**: Та же группа, что и месячная подписка
   - **Duration**: 1 Year
   - Установите цену для всех регионов

5. Создайте **Entitlement**:
   - **Identifier**: `premium` (или другой идентификатор)
   - Привяжите обе подписки к этому entitlement

## Шаг 4: Настройка Revenue Cat Products

1. В Revenue Cat Dashboard перейдите в раздел **Products**
2. Нажмите **Add Product**
3. Добавьте оба продукта из App Store Connect:
   - `com.axillles.ghost.monthly`
   - `com.axillles.ghost.yearly`
4. Создайте **Offering**:
   - Название: "Default Offering"
   - Добавьте оба пакета:
     - **Monthly Package**: привяжите `com.axillles.ghost.monthly`
     - **Annual Package**: привяжите `com.axillles.ghost.yearly`
5. Установите это Offering как **Current Offering**

## Шаг 5: Настройка Entitlements в Revenue Cat

1. Перейдите в раздел **Entitlements**
2. Создайте entitlement с идентификатором `premium` (или тем, который вы использовали в App Store Connect)
3. Привяжите оба продукта к этому entitlement

## Шаг 6: Обновление кода

1. Откройте файл `Ghost/Services/SubscriptionService.swift`
2. Найдите строку:
   ```swift
   let apiKey = "YOUR_REVENUE_CAT_API_KEY"
   ```
3. Замените `YOUR_REVENUE_CAT_API_KEY` на ваш Public API Key из Revenue Cat Dashboard

## Шаг 7: Настройка Entitlements в Xcode

1. Откройте проект в Xcode
2. Выберите таргет `Ghost`
3. Перейдите на вкладку **Signing & Capabilities**
4. Нажмите **+ Capability**
5. Добавьте **In-App Purchase**
6. Убедитесь, что файл `Ghost.entitlements` добавлен к проекту

## Шаг 8: Обновление Product IDs (если необходимо)

Если вы использовали другие Product IDs, обновите логику в `SubscriptionViewModel.swift`:

```swift
// В методе loadOfferings() обновите проверки productIdentifier
if package.storeProduct.productIdentifier.contains("month") || 
   package.storeProduct.productIdentifier.contains("monthly") {
    monthlyPrice = formattedPrice
} else if package.storeProduct.productIdentifier.contains("year") || 
          package.storeProduct.productIdentifier.contains("yearly") {
    yearlyPrice = formattedPrice
}
```

## Тестирование

1. Используйте Sandbox тестовый аккаунт в App Store Connect
2. Запустите приложение на симуляторе или устройстве
3. Пройдите онбординг
4. Через 5 секунд должен появиться экран подписок
5. Протестируйте покупку через Sandbox аккаунт

## Важные замечания

- **Не коммитьте API ключ Revenue Cat в репозиторий!** Используйте переменные окружения или конфигурационные файлы, которые не попадают в git
- Для продакшена используйте Production API Key
- Убедитесь, что все подписки находятся в одной Subscription Group
- Проверьте, что entitlement правильно настроен в Revenue Cat и App Store Connect

## Поддержка

Если возникли проблемы:
- [Revenue Cat Documentation](https://docs.revenuecat.com/)
- [Revenue Cat iOS SDK](https://github.com/RevenueCat/purchases-ios)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
