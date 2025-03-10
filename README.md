# Eddie2 - AI-Powered Education App

Eddie2 is an AI-driven education-focused application designed to help users interact with the OpenAI API through a text-based chat interface. The application provides a seamless chat experience where users can create, read, update, and delete (CRUD) AI-generated question-and-answer (Q&A) pairs.

## Features

### Chat Interface
- Text-based chat for user prompts and OpenAI-generated responses
- Multi-pane layout similar to ChatGPT (sidebar + main chat area)
- File attachment support for sending documents to the OpenAI API

### Q&A Management
- Create Q&A pairs from AI responses or manually
- One-click saving of AI-detected Q&A pairs
- Search and filter Q&A pairs
- Edit and delete Q&A pairs

### Settings
- Secure API key management
- Dark mode toggle
- AI model selection

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (2.17.0 or higher)
- An OpenAI API key

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/eddie2.git
cd eddie2
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run -d chrome
```

### Configuration

On first launch, you'll need to enter your OpenAI API key in the Settings screen. This key is stored securely on your device and is never sent to our servers.

## Project Structure

- `lib/models/` - Data models for chats, messages, and Q&A pairs
- `lib/providers/` - State management using Riverpod
- `lib/screens/` - UI screens for chat, Q&A management, and settings
- `lib/services/` - Services for API communication, storage, and file handling
- `lib/utils/` - Utility classes and theme configuration
- `lib/widgets/` - Reusable UI components

## Technologies Used

- **Flutter**: UI framework
- **Riverpod**: State management
- **Dio**: HTTP client for API requests
- **SharedPreferences**: Local storage
- **FlutterSecureStorage**: Secure storage for API keys
- **FilePicker**: File selection for attachments

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- OpenAI for providing the API that powers the AI functionality
- The Flutter team for the amazing framework
