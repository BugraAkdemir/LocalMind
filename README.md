# LocalMind 🧠

LocalMind is a premium, production-grade Flutter mobile application designed to connect to locally running Large Language Models (LLMs) via the **LM Studio REST API**. 

Unlike web-based alternatives, LocalMind provides a high-performance, native mobile experience with a strong focus on privacy, aesthetics, and user flexibility. It allows users to turn their powerful local machines into personal AI servers accessible from anywhere in their home network.

---

## ✨ Key Features

### 🖥️ Advanced Server & Model Management
*   **Multi-Server support**: Save and switch between multiple LM Studio server profiles seamlessly.
*   **Network Diagnostics**: Integrated connection testing with instant visual feedback and URL sanitization.
*   **Intelligent Model Selection**: Dynamically fetch models from the active server with automatic capability detection.
*   **Capability Badges**: Instantly identify models with `Vision`, `Tools`, `Embedding`, or `Chat` specializations through color-coded badges.

### 💬 Premium Chat Experience
*   **Real-time Streaming**: Low-latency Server-Sent Events (SSE) streaming for immediate AI responses.
*   **Stop Production**: Stop generation mid-stream with a dedicated "Cancel" button to redirect conversations instantly.
*   **Rich Markdown Support**: Beautiful rendering of Markdown, including headers, tables, and complex formatting.
*   **Syntax Highlighting**: Industry-standard code highlighting for multiple languages with one-tap copy functionality.
*   **Persistent History**: Full chat history indexed by conversation, stored locally for offline review.

### 🖼️ Vision & Multimodal Capabilities
*   **Local Image Upload**: Attach images from your **Gallery** or take photos with the **Camera**.
*   **Native Base64 Serialization**: Automatically converts local images into formatted payloads for vision models (like LLaVA) running on your backend.

### 🎙️ Interactive User Inputs
*   **Voice-to-Text**: High-accuracy speech recognition with a dedicated pulsing microphone interface.
*   **System Prompts**: Manage a library of custom "Personalities" or system instructions to guide the AI's behavior.

### 🎨 Visuals & Customization
*   **Dynamic Theming**: Seamless switching between **OLED-Black Dark Mode**, **Minimalist Light Mode**, and System Default.
*   **Typography Controls**: Adjustable text sizing (Small, Medium, Large) to optimize readability across devices.
*   **Generation Parameters**: Manual override sliders for `Temperature`, `Top-P`, and `Max Tokens`.

---

## 🏗️ Architecture & Tech Stack

LocalMind follows **Clean Architecture** principles to ensure scalability and maintainability.

*   **Presentation Layer**: Flutter widgets with **Riverpod** for robust reactive state management.
*   **Domain Layer**: Pure logic and entity definitions.
*   **Data Layer**: **Dio** for advanced networking and **Hive** / **Isar** for high-performance NoSQL local storage.
*   **Service Layer**: Modular API services following the repository pattern.

**Tech Highlights:**
- **State Management**: Flutter Riverpod
- **Navigation**: GoRouter
- **Persistence**: Hive (with custom TypeAdapters)
- **Networking**: Dio (supporting SSE streams)
- **Markdown**: flutter_markdown + flutter_highlight
- **Utilities**: speech_to_text, image_picker, permission_handler

---

## 🚀 Getting Started

### Prerequisites
1.  **LM Studio**: Ensure [LM Studio](https://lmstudio.ai/) is installed and running on your PC.
2.  **Server Start**: Enable the "Local Inference Server" in LM Studio (usually on port `1234`).
3.  **Local Network**: Ensure your mobile device is on the same Wi-Fi network as your PC.

### Installation
1.  Clone the repository:
    ```bash
    git clone https://github.com/BugraAkdemir/LocalMind.git
    cd LocalMind
    ```
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  (Optional) Configure secrets locally:
    - Copy `.env.example` to `.env`
    - Fill `PICOVOICE_ACCESS_KEY` if you want wake-word assistant features
4.  Generate Hive adapters:
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```
5.  Run the application:
    ```bash
    flutter run
    ```

### Server Configuration
- In the app, navigate to **Servers** -> **Add Server**.
- Enter your PC's local IP address (e.g., `192.168.1.50:1234`).
- Tap **Test Connection** to verify.

---

## 🔒 Privacy & Security

LocalMind is built on the principle of **Zero-Data Leakage**.
*   All conversations are stored locally on your device.
*   No intermediate cloud servers are used.
*   Your data flows directly from your device to your PC over your local network.

---

## 🤝 Contributing

Contributions are welcome! If you'd like to improve LocalMind, please fork the repository and submit a pull request.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

Developed with ❤️ for the AI community.
