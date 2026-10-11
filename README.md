<p align="center">
  <img src="docs/logo.png" width="120" alt="Dev Pomodoro logo">
</p>

<h1 align="center">🚀 Dev Pomodoro</h1>

<p align="center">
  <strong>A smart Pomodoro timer tailored for software developers.</strong><br>
  <i>Scan your desk before you start, and let the app warn you about objects that could break your focus!</i>
</p>

[![Flutter](https://img.shields.io/badge/Made%20with-Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Stars](https://img.shields.io/github/stars/furkansagsoyu/dev-pomodoro?style=social)](https://github.com/furkansagsoyu/dev-pomodoro/stargazers)

<hr>

## ✨ Features

- **🍅 Smart Pomodoro Timer**: Standard focus, short break, and long break sessions to keep you productive.
- **📷 AI-Powered Desk Scan**: Uses on-device object detection (TensorFlow Lite, SSD MobileNet on COCO) to warn you about distractions (like smartphones or snacks) before you start coding.
- **🔔 Seamless Notifications**: Live countdown in the notification panel and alerts when a session ends.
- **💡 Daily Developer Briefs**: Get short, actionable developer tips every day (e.g., "What is `git push`?").
- **📊 Detailed Statistics**: Track your focus time, session counts, streaks, and view your weekly progress chart.
- **🎨 Dual Themes**: Eye-friendly Dark (black-blue) and crisp Light (white-blue) themes.
- **🌍 Bilingual**: Fully supports English and Turkish.

## 🛠️ Tech Stack

- **Frontend & Core**: [Flutter](https://flutter.dev/) & Dart
- **Machine Learning**: TensorFlow Lite
- **Model Experiments**: Python & TensorFlow

## 🚀 Getting Started

Follow these instructions to get a copy of the project up and running on your local machine.

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Android Studio or VS Code

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/furkansagsoyu/dev-pomodoro.git
   cd dev-pomodoro
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. **Setup ML Model**: Download the COCO SSD MobileNet TFLite model. Place the `detect.tflite` and `labelmap.txt` files into the `assets/` directory.
4. Run the app on a connected device or emulator:
   ```bash
   flutter run
   ```

## 📱 Screenshots

| Home | Statistics | Settings |
|:----:|:----------:|:--------:|
| <img src="docs/screenshots/home.jpg" width="250" alt="Home"> | <img src="docs/screenshots/stats.jpg" width="250" alt="Stats"> | <img src="docs/screenshots/settings.jpg" width="250" alt="Settings"> |

## 🗺️ Roadmap

- [ ] Custom-trained CNN tailored specifically for developer distractions.
- [ ] Support for more languages.
- [ ] iOS version support.
- [ ] Web dashboard for cross-device tracking.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! 
Feel free to check the [issues page](https://github.com/furkansagsoyu/dev-pomodoro/issues) if you want to contribute.

## 📝 License

This project is licensed under the [MIT License](LICENSE) - see the LICENSE file for details.
