<div align="center">

# 📱 Universal Barcode & QR Generator
### مولد وقارئ الرموز الشريطية ورموز QR الشامل

[![Flutter](https://img.shields.io/badge/Flutter-%E2%89%A5%203.19-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%E2%89%A5%203.3-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2B%20MVVM-4CAF50?style=for-the-badge)](https://flutter.dev)
[![State](https://img.shields.io/badge/State-Riverpod%202.5-00599C?style=for-the-badge)](https://riverpod.dev)
[![Offline](https://img.shields.io/badge/Privacy-100%25%20Offline-FF9800?style=for-the-badge)](#)
[![License](https://img.shields.io/badge/License-Proprietary-red?style=for-the-badge)](#)

[English Documentation](#english) • [التوثيق باللغة العربية](#arabic)

</div>

---

<a name="english"></a>
## 🇬🇧 English Documentation

### 🌟 Overview
**Universal Barcode & QR Generator** is a state-of-the-art, cross-platform Flutter application designed for high-performance barcode and QR code generation, customization, real-time scanning, and batch processing. Built following **Clean Architecture** principles and the **MVVM** pattern with **Riverpod**, it operates 100% offline with zero data tracking, providing ultimate privacy, reliability, and enterprise-grade performance.

---

### ✨ Key Features

#### 🔹 1. Comprehensive Content Support (26 Data Types)
- **General & Text**: Plain Text, Custom Strings, Live System Clipboard Monitoring.
- **Communication**: Web URLs (HTTP/HTTPS), Email (Address/Subject/Body), Phone Numbers, SMS Messages.
- **Connectivity**: Wi-Fi Networks (SSID, Password, Security Encryption: WPA/WPA2/WEP/Open, Hidden SSID support).
- **Personal & Events**: Contact Cards (vCard 3.0 & MeCard), Calendar Events (VEVENT with Title, Start/End Times, Location, & Description).
- **Geo Navigation**: GPS Coordinates (`geo:lat,lng` protocol).
- **Fintech & Cryptocurrency**: Wallet Addresses (Bitcoin, Ethereum, Litecoin, Dogecoin, Tron, Solana, Bitcoin Cash).
- **Social Media**: 15 pre-configured platforms (WhatsApp, Telegram, Instagram, X/Twitter, Facebook, LinkedIn, TikTok, YouTube, Snapchat, Pinterest, Reddit, GitHub, Discord, Threads, Custom Website).
- **App Stores**: Direct app links for Google Play Store & Apple App Store.
- **Commerce & Logistics**: Product Barcodes (EAN-13, EAN-8, UPC-A, UPC-E, ISBN, GS1 DataBar, Code128, Code39, ITF, Codabar).

#### 🔹 2. Barcode & QR Formats (17 Supported Formats)
- **2D Matrix Codes**: QR Code, PDF417, Data Matrix, Aztec Code.
- **1D Linear Barcodes**: Code 128, Code 39, Code 93, Codabar, ITF (Interleaved 2 of 5), EAN-13, EAN-8, UPC-A, UPC-E, ISBN, GS1-128, Telepen, RM4SCC.

#### 🔹 3. Advanced Design & Customization System
- **Color Palettes**: 10 built-in curated palettes (Classic, Ocean, Sunset, Forest, Berry, Royal, Carbon, Sand, Mint, Dark Berry).
- **Color Pickers**: Full RGBA / Hex color customization for foreground and background colors.
- **Gradient Styles**: 5 dynamic gradient directions (Horizontal, Vertical, Diagonal, Radial, Sweep).
- **Module Shapes**: 5 customizable module dot designs (Square, Rounded, Circular, Hexagon, Dots).
- **Eye Patterns**: 5 eye frame styles (Square, Rounded, Circular, Leaf, Bars).
- **Error Correction Levels**: 4 levels — Low (7%), Medium (15%), Quartile (25%), High (30%).
- **Branding & Logos**: Logo embedding with adjustable scale ratios (5%–35%) and optional white background backing for optimal scan rate.
- **Dimensions**: Precise size scaling (128px to 2048px), margins (0 to 16), and corner rounding (0 to 32).

#### 🔹 4. Universal Converter Engine
- **Smart Detection**: Automatically analyzes pasted or typed content to detect category (URL, Email, Wi-Fi, Phone, etc.).
- **Smart Recommendation**: Recommends the ideal barcode/QR format for the detected data type.
- **Simultaneous Previews**: Renders previews for ALL compatible formats in real-time for instant comparison.

#### 🔹 5. Real-Time Camera & Gallery Scanner
- **Live Camera**: Ultra-fast scanning powered by `mobile_scanner` with multi-format detection.
- **Gallery Import**: Scan barcodes directly from saved device photos and gallery images.
- **Controls**: Flashlight toggle, camera flip (front/rear), continuous scanning mode, auto-copy to clipboard.
- **Safety**: Link verification dialogs before opening web links to ensure browsing safety.

#### 🔹 6. Batch Generation & Data Import
- **Multi-Source Import**: Load data via CSV files, Excel spreadsheets, or bulk text paste.
- **Format Override**: Apply global or per-item format configurations across hundreds of codes.
- **Bulk Export**: Export generated codes as zipped PNG images or print-ready multi-page PDFs.

#### 🔹 7. High-Resolution Export & Printing
- **Raster Export**: High-DPI PNG rendering up to 8K resolution.
- **Vector Export**: Scalable SVG export for graphic design and print presses.
- **PDF Generation**: Custom page layouts (6 codes/page, multiple paper & label sizes).
- **Direct Printing**: Native OS print dialog integration (Windows, macOS, Linux, Android, iOS).

#### 🔹 8. Organization & Storage
- **Folders & Tags**: Organize generated barcodes into custom folders and tags.
- **Search & Filter**: Real-time fuzzy search with 5 sorting criteria (Date Asc/Desc, Name Asc/Desc, Category).
- **Backup & Restore**: Export/import complete local data backups (Hive DB) for cross-device migration.

#### 🔹 9. Complete Internationalization (i18n)
- **Languages**: Full English and Arabic translations out-of-the-box.
- **RTL & LTR**: Dynamic layout adaptation for Right-to-Left (Arabic) and Left-to-Right (English) with Cairo font support.

---

### 🏗️ Technical Architecture

This application strictly adheres to **Clean Architecture** combined with **MVVM** (Model-View-ViewModel) and **Riverpod** for reactive state management.

```
lib/
├── app/                    # Application setup, themes & initialization
│   ├── app.dart            # MaterialApp configuration & locale management
│   ├── app_theme.dart      # Material 3 light/dark themes & design tokens
│   └── bootstrap.dart      # Hive DB initialization & service locator setup
├── core/                   # Infrastructure, utilities & constants
│   ├── constants/          # App Constants, Enums (ContentType, BarcodeFormat, QrStyle)
│   ├── errors/             # Custom Failures, Either monad & Exception mappers
│   ├── extensions/         # BuildContext & String extension methods
│   ├── utils/              # Logger & ServiceLocator utilities
│   └── validators/         # ContentDetector & InputValidator engines
├── data/                   # Data Layer (Implementations)
│   ├── datasources/        # HiveLocalDataSource, FileDataSource, ClipboardDataSource
│   ├── repositories/       # Repository implementation classes
│   └── services/           # Concrete services (Generation, Export, Batch, Print, Scanner)
├── domain/                 # Domain Layer (Pure Dart business rules)
│   ├── entities/           # Value objects (QrDesign, BarcodeContent, HistoryEntry, …)
│   ├── repositories/       # Abstract repository interfaces
│   ├── services/           # Abstract service interfaces
│   └── usecases/           # 30+ Use Cases (GenerateCode, UniversalConverter, …)
├── l10n/                   # Internationalization
│   ├── app_en.arb          # English ARB translations
│   ├── app_ar.arb          # Arabic ARB translations
│   └── generated/          # Generated localization classes
├── presentation/           # Presentation Layer (UI & MVVM)
│   ├── providers/          # Riverpod providers & StateNotifiers
│   ├── router/             # GoRouter navigation setup
│   ├── screens/            # Screens (Generator, Scanner, Converter, History, Batch, Settings)
│   └── widgets/            # Reusable UI widgets & modal dialogs
└── main.dart               # Main application entry point
```

---

### 💻 Tech Stack & Dependencies

| Layer / Responsibility | Technology / Package |
| :--- | :--- |
| **Framework** | Flutter ≥ 3.19 (Dart ≥ 3.3) |
| **Architecture Pattern** | Clean Architecture + MVVM |
| **State Management** | Riverpod 2.5 (`flutter_riverpod`) |
| **Routing** | GoRouter 14 (`go_router`) |
| **Local Storage** | Hive 2.2 (`hive_flutter`), `shared_preferences` |
| **Barcode & QR Generation** | `pretty_qr_code`, `barcode`, `barcode_widget` |
| **Scanning** | `mobile_scanner` 5 |
| **Document Export & Printing** | `pdf`, `printing`, `share_plus` |
| **Data Processing & Import** | `csv`, `excel` |
| **Typography** | `google_fonts` (Cairo) |

---

### 🚀 Getting Started

#### Prerequisites
- Flutter SDK (≥ 3.19.0)
- Dart SDK (≥ 3.3.0)

#### Installation & Run
```bash
# 1. Clone the repository
git clone https://github.com/hozifa460/universal_barcode_gen.git

# 2. Change directory
cd universal_barcode_gen

# 3. Get dependencies
flutter pub get

# 4. Generate localization files
flutter gen-l10n

# 5. Run the application
flutter run
```

#### Run Unit Tests
```bash
flutter test
```

---

<br/>
<hr/>
<br/>

<a name="arabic"></a>
## 🇸🇦 التوثيق باللغة العربية

### 🌟 نظرة عامة
**مولد وقارئ الرموز الشريطية ورموز QR الشامل (Universal Barcode & QR Generator)** هو تطبيق احترافي، متكامل، ومتقاطع المنصات تم تطويره باستخدام إطار العمل **Flutter**. يتيح التطبيق إمكانية إنشاء وتخصيص وقراءة الرموز الشريطية (1D Barcodes) ورموز الاستجابة السريعة (QR Codes) لـ **26 نوعًا مختلفًا من البيانات**.

تم تصميم وتطوير التطبيق باتباع أعلى المعايير الهندسية (**Clean Architecture + MVVM + Riverpod**)، ويعمل التطبيق **100% بدون اتصال بالإنترنت (Offline)** لضمان الخصوصية التامة وأعلى مستويات الأداء.

---

### ✨ المميزات الرئيسية

#### 🔹 1. دعم شامل للمحتوى (26 نوع بيانات)
- **النصوص العامة**: نصوص حرة، نصوص مخصصة، والمراقبة المباشرة لحافظة النظام (Clipboard).
- **الاتصالات**: روابط الويب (HTTP/HTTPS)، البريد الإلكتروني (العنوان/الموضوع/المحتوى)، أرقام الهواتف، والرسائل النصية SMS.
- **شبكات الواي فاي (Wi-Fi)**: إنشاء رمز اتصالات تلقائي (اسم الشبكة SSID، كلمة المرور، نوع التشفير: WPA/WPA2/WEP/مفتوح، والشبكات المخفية).
- **جهات الاتصال والفعاليات**: بطاقات التعارف الرقمية (vCard 3.0 & MeCard)، وأحداث التقويم (VEVENT تشمل العنوان، الموعد، الموقع، والوصف).
- **الموقع الجغرافي**: إحداثيات الخرائط ببروتوكول (`geo:lat,lng`).
- **العملات الرقمية**: عناوين المحافظ الرقمية (Bitcoin, Ethereum, Litecoin, Dogecoin, Tron, Solana, Bitcoin Cash).
- **وسائل التواصل الاجتماعي**: قالب مخصص لـ 15 منصة عالمية (واتساب، تليجرام، إنستغرام، إكس/تويتر، فيسبوك، لينكد إن، تيك توك، يوتيوب، سناب شات، بينتريست، ريديت، جيت هاب، ديسكورد، ثريدز، وموقع مخصص).
- **متاجر التطبيقات**: روابط مباشرة لمتجري Google Play Store و Apple App Store.
- **المنتجات والتجارة**: الرموز التجارية والرمز الدولي الموحد للكتب (EAN-13, EAN-8, UPC-A, UPC-E, ISBN, GS1 DataBar, Code128, Code39, ITF, Codabar).

#### 🔹 2. أنواع وصيغ الرموز (17 صيغة مدعومة)
- **الرموز ثنائية الأبعاد (2D Codes)**: QR Code, PDF417, Data Matrix, Aztec Code.
- **الرموز الشريطية الخطية (1D Barcodes)**: Code 128, Code 39, Code 93, Codabar, ITF (Interleaved 2 of 5), EAN-13, EAN-8, UPC-A, UPC-E, ISBN, GS1-128, Telepen, RM4SCC.

#### 🔹 3. نظام تصميم وتخصيص متقدم جداً
- **لوحات الألوان الجاهزة**: 10 لوحات ألوان احترافية (كلاسيكي، محيطي، غروب، غابة، توتي، ملكي، كربوني، رملي، نعناعي، توتي داكن).
- **منتقي الألوان**: تخصيص دقيق لألوان الرمز والخلفية باستخدام قيم Hex و RGBA.
- **التدرجات اللونية (Gradients)**: 5 اتجاهات ديناميكية (أفقي، عمودي، قطري، شعاعي، دائري).
- **أشكال نقاط QR**: 5 أنماط للنقاط (مربع، حواف دائرية، دوائر، مسدس، نقاط).
- **أشكال عيون QR**: 5 أنماط لإطارات العيون (مربع، حواف دائرية، دائرة كاملة، ورقة شجر، أشرطة).
- **مستويات تصحيح الخطأ (Error Correction)**: 4 مستويات — منخفض (7%)، متوسط (15%)، مرتفع (25%)، أقصى (30%).
- **إضافة الشعارات (Logos)**: دمج شعار المؤسسة أو العلامة التجارية مع التحكم في الحجم (5% إلى 35%) إضافة لخلفية دائرية بيضاء لضمان سهولة المسح.
- **الأبعاد والقياسات**: التحكم في دقة التصدير (128 إلى 2048 بكسل)، الهوامش (0 إلى 16)، وتدوير الحواف.

#### 🔹 4. محرك التحويل الشامل (Universal Converter)
- **التحليل الذكي**: التعرف التلقائي على نوع البيانات فور لصقها أو كتابتها.
- **التوصية الذكية**: اقتراح الصيغة المثالية للرمز بناءً على البيانات.
- **المعاينة المتزامنة**: توليد وعرض جميع الصيغ المتوافقة في وقت واحد للمقارنة المباشرة.

#### 🔹 5. القارئ والمتحقق (Scanner)
- **الكاميرا الحية**: مسح عالي السرعة لجميع أنواع الرموز عبر مكتبة `mobile_scanner`.
- **استيراد الصور**: المسح والقراءة المباشرة من الصور المخزنة في معرض الجهاز.
- **أدوات التحكم**: الفلاش، التبديل بين الكاميرات، وضع المسح المستمر، والنسخ التلقائي للنصوص.
- **الأمان**: حوار تأكيد الأمان قبل فتح أي رابط ويب مجهول.

#### 🔹 6. التوليد الدفعي (Batch Generation)
- **استيراد متعدد المصادر**: دعم ملفات CSV، جداول Excel، أو اللصق الجماعي للنصوص.
- **تخصيص الصيغ**: تطبيق صيغ موحدة أو مخصصة لكل عنصر على حدة.
- **التصدير الجماعي**: تصدير الرموز كملف Zip يحتوي صور PNG، أو ملفات PDF جاهزة للطباعة.

#### 🔹 7. التصدير والطباعة عالية الدقة
- **الصور النقطية**: تصدير صيغة PNG عالية الدقة (تصل إلى 8K).
- **الصور المتجهة**: تصدير صيغة SVG القابلة للتكبير بدون التضحية بالجودة للمصممين والمطابع.
- **ملفات PDF**: تصميمات صفحات متعددة الرموز (6 رموز لكل صفحة مع خيارات أحجام الورق والملصقات).
- **الطباعة المباشرة**: تكامل مباشر مع نظام الطباعة الخاص بنظام التشغيل.

#### 🔹 8. التنظيم وإدارة البيانات
- **التصنيف**: تقسيم إلى مجلدات، إضافة وسوم، وتعليم المفضلة.
- **البحث والفرز**: بحث سريع مع 5 خيارات للفرز (حسب التاريخ، الاسم، أو التصنيف).
- **النسخ الاحتياطي**: تصدير واستيراد قاعدة البيانات المحلية (Hive) لنقل البيانات بين الأجهزة بسهولة.

#### 🔹 9. دعم كامل للغتين العربية والإنجليزية
- **اللغات**: واجهة كاملة باللغتين العربية والإنجليزية.
- **الاتجاهات**: адапية كاملة مع اتجاهات النص LTR و RTL مع خط Cairo العربي الأنيق.

---

### 🏗️ البنية البرمجية والتصميم المعماري

تم تطوير التطبيق باستخدام هيكلية **Clean Architecture** مع نمط **MVVM** وإدارة الحالة بواسطة **Riverpod**:

- **Presentation Layer**: الشاشات، عناصر الواجهة، ومزوّدات الحالة (Providers).
- **Domain Layer**: الكيانات (Entities)، حالات الاستخدام (Use Cases)، وعقود المستودعات (Interfaces).
- **Data Layer**: قواعد البيانات المحلية (Hive)، خدمات التصدير، المسح، والطباعة.

---

### 🚀 التشغيل والتثبيت

#### متطلبات التشغيل
- Flutter SDK (≥ 3.19.0)
- Dart SDK (≥ 3.3.0)

#### خطوات التشغيل
```bash
# 1. استنساخ المستودع
git clone https://github.com/hozifa460/universal_barcode_gen.git

# 2. الدخول إلى مجلد المشروع
cd universal_barcode_gen

# 3. تحميل الحزم والاعتمادات
flutter pub get

# 4. توليد ملفات الترجمة
flutter gen-l10n

# 5. تشغيل التطبيق
flutter run
```

---

### 📄 الترخيص (License)
حقوق الملكية محفوظة © 2026
