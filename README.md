# Scam SMS Detector

A Flutter mobile application that detects scam SMS messages using machine learning.

## Features

- **Real-time SMS Monitoring**: Automatically scans incoming SMS messages
- **ML-based Detection**: Uses TensorFlow Lite model for scam detection
- **Rule-based Fallback**: Includes rule-based detection when ML model is not available
- **Message History**: View and analyze past messages
- **Statistics Dashboard**: See scam detection statistics
- **Detailed Analysis**: View confidence scores and analysis for each message

## Setup Instructions

### 1. Prerequisites

- Flutter SDK (3.0.0 or higher)
- Android Studio / Xcode
- Android device or emulator (API 21+)

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Add ML Model (Optional)

To use the ML model, you need to:

1. Train or obtain a TensorFlow Lite model for SMS scam detection
2. Place the model file at `assets/models/scam_model.tflite`
3. Create a labels file at `assets/labels.txt` with class labels (one per line)

**Note**: The app includes a rule-based fallback detection system that works without a model.

### 4. Run the App

```bash
flutter run
```

## Permissions

The app requires the following permissions:
- **READ_SMS**: To read incoming messages
- **RECEIVE_SMS**: To receive SMS broadcasts
- **SEND_SMS**: For potential future features

These permissions are requested automatically when the app starts.

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── message_model.dart   # Message data model
├── providers/
│   └── message_provider.dart # State management
├── screens/
│   ├── home_screen.dart     # Main screen
│   └── message_detail_screen.dart # Message details
├── services/
│   ├── ml_service.dart      # ML detection service
│   └── sms_service.dart     # SMS handling service
├── utils/
│   └── text_preprocessor.dart # Text preprocessing
└── widgets/
    ├── message_card.dart    # Message card widget
    └── stats_card.dart      # Statistics card widget
```

## How It Works

1. **SMS Reception**: The app listens for incoming SMS messages
2. **Text Preprocessing**: Messages are preprocessed (lowercase, remove URLs, etc.)
3. **ML Detection**: The preprocessed text is fed to the ML model
4. **Fallback Detection**: If no model is available, rule-based detection is used
5. **Result Display**: Results are shown with confidence scores

## Rule-based Detection

The fallback system checks for:
- Common scam keywords (urgent, verify, suspended, etc.)
- Suspicious patterns (URLs, long numbers, all caps)
- Calculates a scam score based on these indicators

## Future Enhancements

- Custom ML model training
- Message reporting feature
- Blocklist functionality
- Cloud sync for model updates
- Multi-language support

## License

This project is for educational purposes.

## Disclaimer

This app is provided as-is. Always verify important messages through official channels. The detection accuracy depends on the quality of the ML model used.



