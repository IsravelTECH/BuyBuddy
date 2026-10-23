# BuyBuddy Mobile Application (Flutter)

A cross-platform mobile shopping application for BuyBuddy built with Flutter, Provider, and Dio, adhering strictly to the BuyBuddy modern light-theme design system.

---

## 📱 Features

- **Storefront & Featured Products**: Curated hero promotion banner, category explorer pills, and responsive product grid.
- **Category Filtering**: Dedicated screens for Jeans, T-Shirts, Shoes, Glasses, Jackets, Suits, and Bags.
- **Shopping Cart & Checkout**: Real-time cart synchronization, quantity steppers, coupon voucher redemption (`SAVE20`, etc.), and order summary calculation.
- **User Authentication**: Login & Sign-up with persistent JWT token storage using `flutter_secure_storage`.
- **Light Theme Design System**: Built with modern typography, smooth cards, and BuyBuddy's brand palette (`#2563EB` primary, `#F8FAFC` background).

---

## 🛠️ Project Structure

```text
mobile/
├── android/                   # Native Android project configuration
│   └── app/src/main/AndroidManifest.xml  # Includes INTERNET permission
├── lib/
│   ├── core/
│   │   ├── constants.dart     # Brand colors, typography, API URLs
│   │   └── api_service.dart   # Dio client with JWT token interceptors
│   ├── data/
│   │   └── models.dart        # User, Product, CartItem, Coupon models
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── product_provider.dart
│   │   └── cart_provider.dart
│   ├── views/
│   │   ├── auth/              # Login, Sign-up & Profile screens
│   │   ├── cart/              # Cart, Voucher redemption, Order summary
│   │   ├── category/          # Category-filtered product catalog
│   │   └── home/              # Hero banner, category pills, product grid
│   └── main.dart              # App root, MultiProvider & navigation shell
├── test/
│   └── widget_test.dart       # Unit & Model validation test suite
└── pubspec.yaml               # Flutter dependencies & assets
```

---

## 🚀 How to Run the App

### 1. Install Dependencies
```bash
cd mobile
flutter pub get
```

### 2. Run in Debug Mode (Emulator or USB Device)
```bash
flutter run
```

---

## 📦 How to Build the APK File

### Option A: Build Debug APK (Fastest, No Keystore Required)
Ideal for testing on your phone immediately:
```bash
flutter build apk --debug
```
**Output location:**
`mobile/build/app/outputs/flutter-apk/app-debug.apk`

---

### Option B: Build Release APK (Optimized & Minified)
```bash
flutter build apk --release
```
**Output location:**
`mobile/build/app/outputs/flutter-apk/app-release.apk`

---

### Option C: Build App Bundle (For Google Play Store)
```bash
flutter build appbundle
```
**Output location:**
`mobile/build/app/outputs/bundle/release/app-release.aab`

---

## 📲 How to Install the APK on Your Android Device

1. Enable **Developer Options** and **USB Debugging** on your phone (or allow installing unknown apps from your file manager).
2. Connect your device via USB and run:
   ```bash
   flutter install
   ```
   *Alternatively*, transfer `app-release.apk` or `app-debug.apk` directly to your phone via Google Drive, WhatsApp, or USB cable, and tap to install!

---

## 🌐 Configuring the Backend API Endpoint

The API endpoint is defined in [lib/core/constants.dart](file:///d:/Projects/Buybuddy/mobile/lib/core/constants.dart):

```dart
static const String apiBaseUrl = 'https://e-commerce-store-anqa.onrender.com/api';
```

- When connecting to a **local Express server** running on your computer via an **Android Emulator**, use:
  ```dart
  static const String apiBaseUrl = 'http://10.0.2.2:5000/api';
  ```
- When connecting via a **physical device** over Wi-Fi, use your machine's local LAN IP:
  ```dart
  static const String apiBaseUrl = 'http://192.168.x.x:5000/api';
  ```
