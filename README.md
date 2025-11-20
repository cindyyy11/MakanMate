# 🍽️ MakanMate

<div align="center">

**Your AI-Powered Food Companion** 🤖✨

[![Flutter](https://img.shields.io/badge/Flutter-3.8.1+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.8.1+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![TensorFlow](https://img.shields.io/badge/TensorFlow_Lite-FF6F00?style=for-the-badge&logo=tensorflow&logoColor=white)](https://www.tensorflow.org/lite)

*Discover your next favorite meal with the power of AI* 🎯

[Features](#-features) • [Getting Started](#-getting-started) • [Architecture](#-architecture) • [Screenshots](#-screenshots) • [Contributing](#-contributing)

</div>

---

## 🎯 What is MakanMate?

Ever stood in front of a restaurant thinking, "What should I eat?" Well, those days are over! 🎉

**MakanMate** (from Malay: "Makan" = Eat, "Mate" = Friend) is your intelligent food companion that uses cutting-edge AI to recommend dishes and restaurants tailored specifically to *your* taste. Built with Flutter and powered by TensorFlow Lite, it learns from your preferences and delivers personalized recommendations faster than you can say "I'm hungry!"

### Why MakanMate?

- 🧠 **Smart AI Recommendations** - Machine learning that actually understands what you like
- 📍 **Location-Aware** - Find great food near you in real-time
- ⚡ **Lightning Fast** - On-device AI inference means instant recommendations
- 🔒 **Privacy First** - Your data stays on your device
- 🎨 **Beautiful UI** - Modern, intuitive design with dark mode support
- 🌐 **Multi-Platform** - Runs on Android, iOS, Web, and more!

---

## ✨ Features

### For Food Lovers (Regular Users)

<table>
<tr>
<td width="50%">

#### 🤖 **AI-Powered Recommendations**
Get personalized food suggestions based on:
- Your taste preferences
- Past orders and reviews
- Current location & time
- Weather conditions
- Similar users' choices

Our hybrid recommendation engine combines collaborative filtering, content-based filtering, and contextual awareness for spot-on suggestions!

</td>
<td width="50%">

#### 🗺️ **Smart Location Features**
- Real-time nearby restaurant discovery
- Interactive Google Maps integration
- Distance & route calculations
- Location-based promotions
- Geofenced deals

</td>
</tr>

<tr>
<td width="50%">

#### 🔍 **Advanced Search**
- Search by cuisine, dish, or restaurant
- Filter by price, rating, distance
- Dietary preference filters
- Smart autocomplete suggestions

</td>
<td width="50%">

#### ⭐ **Reviews & Ratings**
- Write detailed reviews with photos
- Rate dishes and restaurants
- Helpful/unhelpful voting system
- Fraud detection for fake reviews
- Review history tracking

</td>
</tr>

<tr>
<td width="50%">

#### 🎟️ **Promotions & Vouchers**
- Exclusive app-only deals
- Time-based flash promotions
- Fortune wheel rewards
- Location-based offers
- Easy voucher redemption

</td>
<td width="50%">

#### 💖 **Bookmarks & Favorites**
- Save favorite restaurants
- Create custom food lists
- Quick access to preferred dishes
- Sync across devices

</td>
</tr>
</table>

### For Restaurant Owners (Vendors)

#### 📊 **Analytics Dashboard**
Get deep insights into your business:
- Real-time order tracking
- Customer behavior analytics
- Popular dish statistics
- Revenue trends & forecasts
- Peak hours analysis

#### 🍕 **Menu Management**
- Easy-to-use menu editor
- Photo upload with optimization
- Pricing & availability control
- Category organization
- Dietary labels (vegan, halal, etc.)

#### 🎯 **Promotion Tools**
- Create targeted campaigns
- Schedule limited-time offers
- Track promotion performance
- Automated expiration handling

#### 💬 **Customer Engagement**
- Respond to reviews
- View customer feedback
- Track ratings over time
- Push notification system

### For Platform Managers (Admin)

#### 🛡️ **Comprehensive Management**
- User management & verification
- Vendor approval workflow
- Review moderation system
- Voucher approval process
- Promotion oversight

#### 📈 **Platform Analytics**
- System-wide metrics dashboard
- Seasonal trend analysis
- Activity logs & audit trails

#### 📄 **Reporting & Export**
- PDF report generation
- CSV data exports
- Custom metric queries
- Automated alerting system

---

## 🏗️ Architecture

MakanMate follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── 🎨 features/           # Feature-based modular architecture
│   ├── auth/             # Authentication & user management
│   ├── home/             # Restaurant browsing
│   ├── recommendations/  # AI recommendation engine
│   ├── map/              # Location & maps
│   ├── reviews/          # Rating & review system
│   ├── vendor/           # Vendor dashboard
│   ├── admin/            # Admin panel
│   ├── promotions/       # Deals & vouchers
│   ├── search/           # Search functionality
│   └── profile/          # User profiles
│
├── 🧠 ai_engine/         # Machine learning models
│   ├── recommendation_engine.dart
│   └── model integrations
│
├── 🔧 core/              # Shared utilities
│   ├── di/              # Dependency injection
│   ├── theme/           # App theming
│   ├── services/        # Core services
│   └── utils/           # Helper functions
│
├── 🚀 services/          # Business services
│   ├── metrics_service.dart
│   ├── push_notification_service.dart
│   └── location_service.dart
│
└── 📱 main.dart         # App entry point
```

### 🎭 Design Pattern: BLoC (Business Logic Component)

Every feature follows a consistent three-layer structure:

- **Presentation Layer** → UI (widgets, pages) + BLoC (state management)
- **Domain Layer** → Business logic (entities, use cases, repository interfaces)
- **Data Layer** → Data handling (models, datasources, repository implementations)

This means: **Clean code, easy testing, and maintainable for the long run!** 🎯

---

## 🛠️ Tech Stack

### Frontend Framework
- **Flutter** 3.8.1+ - Cross-platform UI toolkit
- **Dart** SDK 3.8.1+ - Programming language

### State Management
- **flutter_bloc** - BLoC pattern implementation
- **riverpod** - Provider-based state management
- **equatable** - Value equality

### Backend & Database
- **Firebase Auth** - User authentication
- **Cloud Firestore** - NoSQL database
- **Firebase Storage** - File storage
- **Firebase Cloud Messaging** - Push notifications
- **Firebase Analytics** - Usage tracking
- **Firebase Crashlytics** - Crash reporting

### AI/ML & Computer Vision
- **TensorFlow Lite** - On-device ML inference
- **Google ML Kit** - Image labeling, text recognition, face detection
- **Custom recommendation model** - Trained on user behavior data

### Maps & Location
- **Google Maps Flutter** - Interactive maps
- **Geolocator** - Device location
- **Geocoding** - Address conversion

### UI & Animations
- **Google Fonts** - Custom typography
- **Lottie** - Vector animations
- **Shimmer** - Loading effects
- **cached_network_image** - Image caching
- **FL Chart** - Data visualization

### Local Storage & Caching
- **Hive** - Fast NoSQL local database
- **shared_preferences** - Key-value storage
- **sqflite** - SQLite database

### Additional Libraries
- **dio** & **http** - Network requests
- **image_picker** - Camera & gallery access
- **pdf** & **printing** - Report generation
- **flutter_tts** - Text-to-speech
- **connectivity_plus** - Network monitoring

---

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have:

- ✅ Flutter SDK 3.8.1 or higher ([Install Flutter](https://docs.flutter.dev/get-started/install))
- ✅ Dart SDK 3.8.1+ (comes with Flutter)
- ✅ Android Studio / VS Code with Flutter extensions
- ✅ A physical device or emulator
- ✅ Firebase project set up ([Firebase Console](https://console.firebase.google.com))

### Installation

#### 1️⃣ Clone the Repository

```bash
git clone https://github.com/yourusername/makan_mate.git
cd makan_mate
```

#### 2️⃣ Install Dependencies

```bash
flutter pub get
```

#### 3️⃣ Set Up Firebase

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Add Android and/or iOS apps to your Firebase project
3. Download `google-services.json` (Android) → Place in `android/app/`
4. Download `GoogleService-Info.plist` (iOS) → Place in `ios/Runner/`
5. Enable these Firebase services:
   - Authentication (Email, Google, Facebook)
   - Cloud Firestore
   - Storage
   - Analytics
   - Cloud Messaging
   - Crashlytics

#### 4️⃣ Configure Environment Variables

Create a `.env` file in the root directory:

```env
# API Keys (Get from Firebase console)
FIREBASE_API_KEY=your_api_key_here
GOOGLE_MAPS_API_KEY=your_google_maps_key_here

# Optional: Social Auth
FACEBOOK_APP_ID=your_facebook_app_id
GOOGLE_CLIENT_ID=your_google_client_id
```

⚠️ **Important:** Add `.env` to `.gitignore` to keep your secrets safe!

#### 5️⃣ Set Up Google Maps API

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Enable Maps SDK for Android/iOS
3. Create an API key
4. Add the key to your `.env` file

For Android, also add to `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${GOOGLE_MAPS_API_KEY}"/>
```

#### 6️⃣ Set Up ML Model

The TensorFlow Lite recommendation model is already included at:
```
assets/ml_models/recommendation_model.tflite
```

If you want to retrain the model:

```bash
cd python_ai_training
pip install -r requirements.txt
python train_recommendation_model.py
```

#### 7️⃣ Run the App

```bash
# Run on connected device
flutter run

# Run in release mode (better performance)
flutter run --release

# Run on specific device
flutter devices
flutter run -d <device_id>
```

---

## 🧪 Testing

Run the test suite:

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Test specific file
flutter test test/features/auth/auth_test.dart

# Test with coverage
flutter test --coverage
```

---

## 📦 Building for Production

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release

# Split APKs by architecture
flutter build apk --split-per-abi
```

Output: `build/app/outputs/`

### iOS

```bash
# Build iOS app
flutter build ios --release

# Build for App Store
flutter build ipa
```

Output: `build/ios/`

### Web

```bash
flutter build web --release
```

Output: `build/web/`

---

## 📱 Screenshots

<!-- You can add your actual screenshots here -->

<div align="center">

| Home Screen | Restaurant Details | AI Recommendations |
|:-----------:|:------------------:|:------------------:|
| 🏠 | 🍽️ | 🤖 |

| Map View | Reviews | Vendor Dashboard |
|:--------:|:-------:|:----------------:|
| 🗺️ | ⭐ | 📊 |

*Screenshots coming soon! The app is functional and ready to go.* 📸

</div>

---

## 🤝 Contributing

We welcome contributions! Here's how you can help make MakanMate even better:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/AmazingFeature`)
3. **Commit your changes** (`git commit -m 'Add some AmazingFeature'`)
4. **Push to the branch** (`git push origin feature/AmazingFeature`)
5. **Open a Pull Request**

### Coding Standards

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use the included linter (`very_good_analysis`)
- Write tests for new features
- Document public APIs
- Keep commits atomic and descriptive

---

## 📝 Project Structure & Key Files

```
MakanMate/
├── 📱 lib/                    # Main application code
├── 🤖 python_ai_training/    # ML model training scripts
├── 🎨 assets/                # Images, fonts, animations
│   ├── images/
│   ├── lottie/
│   ├── ml_models/
│   └── fonts/
├── 🧪 test/                  # Unit & widget tests
├── 🔗 integration_tests/     # Integration tests
├── 🔥 functions/             # Firebase Cloud Functions
├── 📄 pubspec.yaml          # Dependencies
├── 🔧 .env                  # Environment variables (create this!)
└── 📖 README.md            # You are here!
```

---

## 🐛 Troubleshooting

### Common Issues

**Issue: Firebase initialization fails**
```
✅ Solution: Ensure google-services.json and firebase_options.dart are properly configured
```

**Issue: Google Maps not showing**
```
✅ Solution: Check that GOOGLE_MAPS_API_KEY is set in .env and AndroidManifest.xml
```

**Issue: ML model fails to load**
```
✅ Solution: Verify recommendation_model.tflite exists in assets/ml_models/
```

**Issue: Location permissions denied**
```
✅ Solution: Grant location permissions in device settings
```

**Issue: Build fails on iOS**
```
✅ Solution: Run 'pod install' in ios/ directory and ensure Xcode is up to date
```

### Need More Help?

- 📧 Email: support@makanmate.com
- 💬 Issues: [GitHub Issues](https://github.com/yourusername/makan_mate/issues)
- 📚 Docs: Check code comments for detailed explanations

---

## 🗺️ Roadmap

### 🚀 Coming Soon

- [ ] Voice search integration
- [ ] AR menu visualization
- [ ] Social features (follow friends, share favorites)
- [ ] Dietary restriction filters (allergens, halal, kosher)
- [ ] Multi-language support (Malay, Chinese, Tamil)
- [ ] Apple Watch & Android Wear support
- [ ] Reservation system integration
- [ ] Recipe suggestions based on ingredients

### 💡 Future Ideas

- Meal planning & nutrition tracking
- Integration with food delivery services
- Gamification & achievement system
- Community challenges & leaderboards

---

## 📄 License

This project is proprietary software. All rights reserved.

For licensing inquiries, please contact: [license@makanmate.com](mailto:license@makanmate.com)

---

## 🙏 Acknowledgments

Built with ❤️ using:

- [Flutter](https://flutter.dev) - Google's UI toolkit
- [Firebase](https://firebase.google.com) - Backend infrastructure
- [TensorFlow](https://www.tensorflow.org) - Machine learning
- [Google Maps](https://developers.google.com/maps) - Mapping services
- And many amazing open-source packages! 🎉

Special thanks to the Flutter community for their incredible support and resources.

---

## 📞 Connect With Us

- 🌐 Website: [www.makanmate.com](https://www.makanmate.com)
- 📱 Twitter: [@MakanMateApp](https://twitter.com/makanmateapp)
- 💼 LinkedIn: [MakanMate](https://linkedin.com/company/makanmate)
- 📧 Contact: hello@makanmate.com

---

<div align="center">

### ⭐ Star us on GitHub — it motivates us a lot!

**Made with 🍜 and ☕ by the MakanMate Team**

*"Good food, great recommendations, amazing experiences"* 🎯

</div>
