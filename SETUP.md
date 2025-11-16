# Setup Guide for Scam SMS Detector

## Quick Start

1. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   flutter run
   ```

## Adding a Machine Learning Model (Optional)

The app works with a rule-based fallback system, but you can add a TensorFlow Lite model for better accuracy:

1. **Train or obtain a TensorFlow Lite model:**
   - The model should accept text input and output binary classification (scam/legitimate)
   - Save it as `scam_model.tflite`

2. **Place the model file:**
   - Copy `scam_model.tflite` to `assets/models/scam_model.tflite`

3. **Update labels (if needed):**
   - Edit `assets/labels.txt` to match your model's output classes

## Permissions

The app will automatically request SMS permissions when it starts. Make sure to grant:
- Read SMS
- Receive SMS

## Testing

To test the app:
1. Install on a physical Android device (SMS features don't work on emulators)
2. Send test SMS messages to the device
3. The app will automatically detect and classify them

## Troubleshooting

### Model not loading
- Check that `scam_model.tflite` exists in `assets/models/`
- Verify the model format is TensorFlow Lite
- The app will use rule-based detection if no model is found

### SMS not being detected
- Ensure SMS permissions are granted
- Check that the app is running in the foreground or background
- On some Android versions, you may need to disable battery optimization

### Build errors
- Run `flutter clean` and `flutter pub get`
- Ensure you have the latest Flutter SDK
- Check that all dependencies are compatible



