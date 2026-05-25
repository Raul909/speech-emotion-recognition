# 📱 VoxSense — Offline Android Speech Emotion Recognition (SER) App

VoxSense is a fully local, on-device Speech Emotion Recognition (SER) application built in **Kotlin** and **Jetpack Compose**. Operating entirely offline, VoxSense intercepts and decodes vocal emotional markers directly from your device's microphone, requiring **no internet connection or external API requests**, guaranteeing 100% data privacy and zero network latency.

This branch (`on-device`) is dedicated strictly to the **Android Application Codebase** and its local machine learning components.

---

## 🚀 On-Device Digital Signal Processing (DSP) Pipeline

The application processes voice inputs locally using a custom high-performance Kotlin audio engineering stack:

```text
  [User voice input] 
         │
         ▼
  ┌──────────────┐
  │ AudioRecord  │ ◄─── Captures raw 16-bit Mono PCM audio at 48,000 Hz
  └──────┬───────┘
         │
         ▼
  ┌──────────────┐
  │MfccExtractor │ ◄─── Cooley-Tukey Radix-2 FFT (Hanning Window) ──► 128 Mel bands ──► DCT-II
  └──────┬───────┘
         │
         ▼
  ┌──────────────┐
  │  TFLite Run  │ ◄─── Formats to [1, 40, 1] tensor ──► Executed by local TFLite Interpreter
  └──────┬───────┘
         │
         ▼
  ┌──────────────┐
  │  Compose UI  │ ◄─── Maps probabilities to alphabetic labels & renders dynamic M3 dashboard
  └──────────────┘
```

### 1. High-Quality Mic Capture (`AudioRecorder.kt`)
Captures raw audio at **48,000 Hz mono** (16-bit PCM configuration) to match the native sample rate of the RAVDESS training set:
- Computes peak amplitude in real-time to animate the canvas waveform visualizer using the formula:
  $$\text{amplitude} = \frac{\max(|x(n)|)}{32768.0}$$
- On stop, merges the 16-bit little-endian byte stream back into a normalized float array ($[-1.0, 1.0]$) for feature extraction.

### 2. On-Device Feature Extraction (`MfccExtractor.kt`)
An optimized, pre-allocated digital signal processing pipeline:
- **Framing**: Slices audio using periodic Hanning windows (frame size `2048`, hop size `512`).
- **Cooley-Tukey FFT**: Calculates the in-place Radix-2 Fast Fourier Transform in $O(N \log N)$ complexity, running in less than 0.1ms per frame on standard mobile CPUs.
- **Mel Filtering**: Multiplies the power spectrum by a Slaney-normalized triangular Mel scale filterbank of **128 bands** and log-compresses the energy into decibels.
- **DCT-II Representation**: Computes the orthogonal Discrete Cosine Transform to extract **40 MFCCs** per frame, averaging them over time to yield a single 40-dimensional feature vector.

### 3. On-Device TFLite Inference (`EmotionClassifier.kt`)
Loads the localized TensorFlow Lite model file:
- Maps `speech_emotion_recognition_cnn_model.tflite` directly from assets using a read-only `MappedByteBuffer` for zero-memory-copy execution.
- Reshapes the 40 MFCCs into a `[1, 40, 1]` tensor.
- The interpreter performs inference, outputting probabilities mapped to alphabetically sorted RAVDESS categories:
  `['angry', 'calm', 'disgust', 'fearful', 'happy', 'neutral', 'sad', 'surprised']`

---

## 📂 Mobile Codebase Layout

```text
speech-emotion-recognition/
├── android-app/                   # Root Android Studio Project
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── assets/            # Embedded speech_emotion_recognition_cnn_model.tflite
│   │   │   ├── java/com/example/voxsense/
│   │   │   │   ├── data/          # DSP feature extraction & TFLite run pipelines
│   │   │   │   ├── theme/         # Color palettes, custom typography, and Nord themes
│   │   │   │   ├── ui/main/       # Jetpack Compose Screens and Main ViewModel
│   │   │   │   ├── MainActivity.kt # Core Activity Entry Point
│   │   │   │   └── Navigation.kt  # Route controllers
│   │   │   └── AndroidManifest.xml # Record Audio & Internet permissions
│   │   └── build.gradle.kts       # App module configurations & libraries
│   ├── gradle/libs.versions.toml  # Dependency catalog (TFLite, Compose, Navigation)
│   └── settings.gradle.kts        # Root Gradle settings
├── voxsense-v1.0.1.apk            # Pre-compiled flagship APK binary (Ready-to-Install)
└── README.md                      # On-Device Mobile Handbook
```

---

## ✨ Premium Mobile UX Customizations

1. **Notch-Safe Glassmorphic Header**: Layout is fully wrapped in Compose's premium **`safeDrawingPadding()`** to dynamically offset the `"VOXSENSE"` branding and custom settings buttons safely out of status bar notches and physical punch-hole camera cutouts.
2. **Signal Customizations**:
   - **Pre-emphasis Filter**: Boosts high-frequency bands ($y[n] = x[n] - 0.97 \cdot x[n-1]$) to highlight vocal formants.
   - **Noise Gate**: Silences background ambient hum below an amplitude threshold of $0.015$.
   - **Duration Limiters**: Allows selecting Manual Stop, 3s, 5s, or 10s recording limits.
   - **Tracked Emotions Filters**: Toggleable checklists to filter which emotion progress bars render on the results card.
3. **Automated Material 3 Dynamic Colors**: Color templates adapt to system light/dark settings and Android 12+ wallpaper colors, mapping to custom paralinguistic colors for instant visual emotion feedback (e.g., Aurora Crimson for angry, Aurora Yellow for happy).
4. **Dynamic Model Manager**: Download advanced neural network models (CNN, LSTM, CRNN TFLite models) directly in-app! Supports high-speed local developer connections via `adb reverse tcp:5000 tcp:5000` to fetch models from the workspace server, automatically falling back to GitHub release URLs if unreachable.

---

## 🛠️ Build and Deploy

### 📥 Immediate Installation (Direct APK)
Get the application instantly without setting up compiler tools:
- **Download the precompiled flagship binary directly: [voxsense-v1.0.1.apk](voxsense-v1.0.1.apk)**.
- Copy it to your Android device, enable "Install from Unknown Sources", and launch!

### 💻 Compile from Source Code (Android Studio)
1. **Prerequisites**: Ensure you have Android SDK/NDK paths configured (typically defined in your environment or in `android-app/local.properties` as `sdk.dir=/path/to/Sdk`).
2. **Build Debug APK**:
   Open a terminal in the `android-app/` directory and run:
   ```bash
   cd android-app
   ./gradlew assembleDebug
   ```
3. **Deploy to USB-connected Device/Emulator**:
   Ensure USB Debugging is active on your device, then run:
   ```bash
   ./gradlew installDebug
   ```
