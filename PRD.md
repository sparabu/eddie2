# Eddie2 – AI-Powered Education App: Product Requirements Document

## 1. Overview

Eddie2 is an AI-driven education-focused application that helps users interact with the OpenAI API through a text-based chat interface. Users can create, read, update, and delete (CRUD) AI-generated question-and-answer (Q&A) pairs either by chatting with the AI or by manually entering them in a dedicated interface.

### MVP Scope
- **Chat Interface**: Text-based chat for user prompts and OpenAI-generated responses, featuring a multi-pane layout similar to ChatGPT (sidebar + main chat area) ✅
- **Q&A CRUD**: Basic create, read, update, and delete operations for Q&A pairs ✅
- **Local Storage**: On-device storage for chat history and Q&A pairs ✅
- **Single User**: No authentication or multi-user support ✅
- **Web Platform**: Responsive design for web browsers ✅
- **Error Handling**: Robust handling and user-friendly messaging for all API interactions ✅
- **Direct Q&A Creation**: Manually create Q&A pairs outside of chat flow ✅
- **One-Click Saving**: Automatic detection of Q&A pairs in chat with a quick-save option ✅
- **API Key Storage**: Secure management of user-provided API keys ✅
- **Selectable Text**: Allows copy/paste of chat messages ✅
- **File Upload**: Basic single-file attachment within the chat, supporting any file type allowed by OpenAI ✅

### Full Implementation Scope (Post-MVP)
- **User Authentication**: Multi-user support and secure login
- **Cloud Database**: Storage of Q&A pairs and chat history in the cloud
- **Cross-Platform Support**: Native builds for Windows, Mac, Linux, tablets, and mobile
- **Advanced File Handling**: Multiple file uploads, drag-and-drop, advanced previews, etc.
- **Offline Support & Synchronization**: Data sync across multiple devices, with offline access
- **Optional Dark Mode**: Toggleable dark/light themes ✅
- **Multilingual Support**: Full localization with language selection ✅

## 2. Technology Stack

### MVP Technology Stack
- **UI Framework**:
  - **Flutter with Custom Theming** ✅:
    - Leverages Material 3 for advanced theming controls.
    - Overrides default Material styling to achieve a minimal, ChatGPT-like look (flat elements, minimal shadows, neutral color palette).
    - Maintains Flutter's multi-platform deployment benefits (web, iOS, Android, desktop).
- **State Management**: Riverpod ✅
- **API Handling**: Dio for HTTP requests to the OpenAI API ✅
- **Storage**:
  - Shared Preferences for local data (chat history and Q&A pairs) ✅
  - Flutter Secure Storage for sensitive data (API keys) ✅
- **File Handling**:
  - File picker for selecting single files ✅
  - Base64 encoding for sending file data to OpenAI ✅
- **AI Processing**: OpenAI API for generating Q&A content ✅
- **Web Deployment**: Flutter web with responsive design ✅
- **JSON Handling**: Dart convert library with error handling ✅
- **Localization**: Flutter's intl package for multilingual support ✅
- **Version Information**: Package Info Plus for dynamic version display ✅

### Alternative Web-Centric Option (Non-MVP)
For teams focused primarily on a web application and wanting to use Tailwind CSS or shadcn/ui, a React/Next.js stack could be used instead of Flutter. However, this would forgo the single codebase benefit for mobile/desktop.

### Full Implementation Technology Stack (Post-MVP)
- **Backend**: Firebase for user authentication and real-time database
- **Database**: Firestore for storing Q&A pairs and user data
- **Authentication**: Firebase Authentication (Email/Password, Google, Apple)
- **File Handling**: Firebase Cloud Storage for large files and multi-file support
- **MVP Technologies**: All components above remain in use and are extended

## 3. Features & Functional Requirements

### 3.1 Main Page (Chat Window)

#### MVP Requirements
- **Multi-Pane Layout Inspired by ChatGPT** ✅:
  - Sidebar for chat history, quick access to saved Q&A pairs, or settings navigation.
  - Main Chat Section to display the ongoing conversation with the AI.
  - Responsive design ensures the sidebar can collapse on smaller screens (mobile) to preserve space.
- Real-time integration with the OpenAI API for user prompts and AI-generated responses ✅
- Persistent chat history stored locally ✅
- Automatic identification of potential Q&A pairs with a "Save as Q&A Pair" button ✅
- Text in both user and AI messages is selectable for convenient copy/paste ✅
- Clear error messages in the event of failed API communication ✅
- File Attachment: Single-file attachment workflow (see Section 3.6) ✅

#### Full Implementation Requirements (Post-MVP)
- **Advanced Multi-Pane UI**:
  - Additional side panels for analytics, Q&A detail previews, or user notes.
  - Drag-and-drop reordering of panels, or user-customizable layouts.
  - Optional dark mode toggle for all panels ✅
  - Rich text/HTML-based formatting.
  - Full integration with advanced file-upload features (Section 3.6).

### 3.2 Q&A Management (CRUD Operations)

#### MVP Requirements
- **Create** ✅:
  - Q&A pairs generated from AI responses or entered manually via a form
  - One-click save of AI-detected Q&A pairs directly from the chat
- **Read** ✅:
  - Dedicated screen or section displaying all stored Q&A pairs
  - Quick navigation to each Q&A pair from the sidebar in the multi-pane layout
- **Update** ✅:
  - Ability to edit existing Q&A pairs
- **Delete** ✅:
  - Delete individual Q&A pairs or perform bulk removals
- **Local Storage** ✅:
  - Data persistence using Shared Preferences
- **Error Handling** ✅:
  - Graceful recovery if the API is unavailable or errors occur

#### Full Implementation Requirements (Post-MVP)
- Cloud-based synchronization of Q&A pairs across devices
- Advanced search and filtering tools
- Categorization and tagging of Q&A pairs
- Sharing features for Q&A pairs

### 3.3 OpenAI API Integration

#### MVP Requirements
- Sends user-entered text to the OpenAI API ✅
- Detects and structures Q&A pairs from AI responses ✅
- Multiple strategies for parsing response data (JSON, Markdown, or direct extraction) ✅
- Logs errors in detail for debugging ✅
- Stores and manages the API key securely ✅

#### Full Implementation Requirements (Post-MVP)
- Additional AI endpoints for specialized tasks
- Configurable AI parameters (temperature, max tokens, etc.)
- Batch processing for multiple files or prompts in a single interaction
- Handling of advanced or custom OpenAI endpoints
- Language-aware AI responses based on user's selected language ✅

### 3.4 Storage & Data Management

#### MVP Requirements
- Local storage of both chat history and Q&A pairs (Shared Preferences) ✅
- Secure storage of sensitive information like API keys (Flutter Secure Storage) ✅
- Automatic serialization and deserialization of Q&A data to/from JSON ✅
- Resilience to partial/corrupt data with fallback mechanisms ✅

#### Full Implementation Requirements (Post-MVP)
- Cloud-based database (e.g., Firestore) for data persistence
- Real-time synchronization and multi-device support
- Backup and recovery features
- Optional encryption of stored Q&A pairs

### 3.5 Settings Management

#### MVP Requirements
- Dedicated settings screen for basic preferences ✅
- Secure interface for adding/updating/removing OpenAI API key ✅
- Visual feedback upon successful/failed operations ✅
- Configurable file size limits and disclaimers for file uploads ✅
- Dynamic version display that automatically updates with each release ✅

#### Full Implementation Requirements (Post-MVP)
- User profile settings (name, avatar, etc.)
- Theme customization (including dark mode) ✅
- Language and localization options ✅
- Advanced AI parameter configuration

### 3.6 File Upload Functionality

#### MVP Requirements
- **Basic File Attachment** ✅:
  - Users can attach a single file (any type supported by OpenAI) within the chat.
  - File size validation according to OpenAI's API limits.
  - Progress indicator for the upload process.
  - Clear error handling for invalid or failed uploads.
  - Ability to cancel or remove a file before sending.
- **Transmission** ✅:
  - Base64-encoded upload of the file's contents to the OpenAI API.
  - Minimal local retention of the file (only as needed for the request).

#### Full Implementation Requirements (Post-MVP)
- **Expanded File Handling**:
  - Multiple file uploads in a single message.
  - Drag-and-drop functionality from the user's file system.
  - File compression for large attachments.
  - Advanced preview and annotation within the app.
  - Integration with Firebase Cloud Storage or similar for long-term file needs.

### 3.7 Localization & Internationalization

#### MVP Requirements
- **Multilingual Support** ✅:
  - Support for multiple languages (initially English and Korean)
  - Language selection in the settings screen
  - Localized UI elements, error messages, and tooltips
- **Localization Infrastructure** ✅:
  - Centralized string management using Flutter's intl package
  - Separation of UI code and text content
  - Easy addition of new languages in the future

#### Full Implementation Requirements (Post-MVP)
- Support for additional languages
- Right-to-left (RTL) language support
- Language detection based on user's system settings
- Region-specific formatting for dates, numbers, and currencies

### 3.8 UI/UX Documentation

#### MVP Requirements
- **Comprehensive UI/UX Specifications** ✅:
  - Detailed documentation of all UI components and their properties
  - Screen maps showing the structure of each screen
  - Design system reference including colors, typography, and spacing
  - Interaction patterns for common user flows
  - User flow diagrams for key features
  - State management conventions
  - API integration points
  - Localization guidelines
  - Responsive behavior specifications
  - Accessibility standards
  - Error handling, empty states, and loading states
  - Animation and transition guidelines
  - Testing and QA guidelines

## 4. Non-Functional Requirements

### 4.1 Security & Privacy

#### MVP Requirements
- All communication with the OpenAI API over encrypted channels (HTTPS) ✅
- Secure, encrypted storage of user-provided API keys ✅
- Only essential data is stored; unneeded files or data are discarded ✅
- API key display is hidden or obscured by default ✅
- Uploaded files are used only for the immediate AI request and are not permanently stored ✅

#### Full Implementation Requirements (Post-MVP)
- Full user authentication with secure password policies
- Token-based authentication for external API calls
- Compliance with privacy regulations (GDPR, CCPA, etc.)
- End-to-end encryption for file transfers and data at rest

### 4.2 Performance

#### MVP Requirements
- Low-latency chat interactions with the OpenAI API ✅
- Efficient local storage operations for chat history and Q&A pairs ✅
- Non-blocking UI with background processing for API calls ✅
- Optimized file encoding/transmission for single-file uploads ✅

#### Full Implementation Requirements (Post-MVP)
- Server-side optimizations and caching for data sync
- Smooth handling of large datasets and multiple file uploads
- Advanced caching for frequently accessed data or Q&A sets
- Background processing for resource-intensive operations

### 4.3 Usability & UI/UX Design

#### MVP Requirements
- **Multi-Pane Layout & Modern Design** ✅:
  - Inspired by ChatGPT's UI: a sidebar for chat navigation/Q&A lists, a main panel for conversation, and a fluid layout that adapts to different screen sizes.
- **Custom Material 3 Theming in Flutter** ✅:
  - Use neutral or minimal color palettes, reduce heavy shadows, and keep the UI uncluttered to mimic ChatGPT's style.
- Clear, actionable error messages and visible loading indicators ✅
- Collapsible sidebar on smaller screens ✅
- Straightforward file-attachment flow with an obvious "Attach File" or "Upload" button ✅
- Simple settings screen with logical navigation ✅

#### Full Implementation Requirements (Post-MVP)
- **Advanced Layout & Customization**:
  - Additional panels for analytics, user notes, or data insights
  - Drag-and-drop repositioning of UI elements, user-customizable layout
  - Dark Mode Toggle with fully themed panels ✅
  - Additional layout options and advanced text formatting in chat
  - Accessibility features (font sizes, screen reader compatibility)
  - More robust file management interfaces

## 5. Version Control

### Implementation Status
Eddie2 has been successfully set up with Git version control and is hosted on GitHub:

- **Repository**: https://github.com/sparabu/eddie2
- **Current Version**: v1.2.1 (UI/UX documentation and dynamic version display)
- **Branching Strategy**:
  - Main branch contains the production-ready code
  - Feature branches will be created for new features and improvements

### Version History
- **v1.0.0**: Initial MVP implementation with all core features completed:
  - Multi-pane layout with responsive design
  - Chat interface with OpenAI API integration
  - Q&A pair management (CRUD operations)
  - Settings management with API key storage
  - File attachment support
  - Dark mode toggle
  - Improved UI for first-time users (showing sidebar even when API key is not set)

- **v1.1.0**: Enhanced localization and language support:
  - Full localization infrastructure using Flutter's intl package
  - Support for English and Korean languages
  - Language selection in settings
  - AI responses in the user's chosen language
  - Fixed localization issues with hardcoded strings
  - Improved user experience with consistent language throughout the app

- **v1.2.0**: Localization refinements and language-aware AI responses:
  - Fixed remaining hardcoded strings in the chat interface
  - Updated the Chat model to use localized strings for new chat titles
  - Enhanced OpenAI service to respond in the user's selected language by default
  - Added comprehensive localization guidelines for future development
  - Improved tooltips and UI elements to be fully localized
  - Ensured consistent language experience across all parts of the application

- **v1.2.1**: UI/UX documentation and version display improvements:
  - Created comprehensive UI/UX specifications document (UIUX_SPEC.md)
  - Implemented dynamic version display in the Settings screen
  - Added Package Info Plus package for retrieving app version information
  - Updated file naming conventions for documentation files
  - Standardized component IDs and screen IDs in UI documentation
  - Added design tokens, user flow diagrams, and API integration details
  - Included animation guidelines and testing/QA criteria

### Version Control Strategy
To maintain a consistent, collaborative, and traceable development workflow, Eddie2 uses a structured Git-based version control strategy:

- **Collaboration**: Enable multiple contributors to work in parallel without conflicts.
- **Traceability**: Track all changes, revert if necessary, and maintain detailed commit histories.
- **Branching Strategy**:
  - Main branch holds production-ready code.
  - Feature branches are created for each new feature or bug fix, then merged back via pull requests.
- **Release Management**: Tag specific commits for major releases (e.g., v1.0.0, v1.1.0, v1.2.0) for easy reference and rollback if needed.
- **Tools**:
  - GitHub for hosting the repository and collaboration.
  - SSH key authentication for secure access.
- **Semantic Versioning**: Following the X.Y.Z (Major.Minor.Patch) format:
  - Major (X): Incompatible API changes
  - Minor (Y): New features in a backward-compatible manner
  - Patch (Z): Backward-compatible bug fixes

## 6. Implementation Notes

### 6.1 Completed Features
- **UI Implementation**: 
  - Multi-pane layout with sidebar navigation
  - Responsive design for different screen sizes
  - Dark mode support with custom theming
  - Improved first-time user experience showing the sidebar even when API key is not set
  - Comprehensive UI/UX specifications document
  
- **Core Functionality**:
  - Chat interface with OpenAI API integration
  - Q&A pair detection and management
  - File attachment support
  - Settings management with secure API key storage
  - Dynamic version display
  
- **Error Handling**:
  - Improved error handling for file picking failures
  - Enhanced Q&A detection with fallback to manual creation
  - User-friendly error messages and loading indicators

- **Localization & Internationalization**:
  - Complete localization infrastructure for all UI elements
  - Support for English and Korean languages
  - Language selection in settings
  - AI responses in the user's chosen language
  - Consistent language experience throughout the app

### 6.2 Known Issues
- File picker package shows warnings about missing implementations for desktop platforms
- These warnings don't affect web functionality but should be addressed for desktop deployment

### 6.3 Next Steps
- Address file picker warnings for better desktop platform support
- Implement additional post-MVP features based on user feedback
- Set up automated testing and CI/CD pipeline
- Enhance Q&A detection algorithms for better accuracy
- Add support for additional languages
- Implement localization best practices for all future features
- Consider implementing cloud synchronization for multi-device support

### 6.4 Localization Guidelines
For all future development, the following localization guidelines should be followed:

1. **No Hardcoded Strings**: All user-facing text must be defined in localization files
2. **Use Localization Keys**: Access text through the localization system using the `l10n` object
3. **Consider Context**: Provide context for translators through comments in ARB files
4. **Test All Languages**: Verify that UI elements display correctly in all supported languages
5. **Update Documentation**: Document new localization keys and their purpose
6. **Consider Cultural Differences**: Be aware of cultural differences when designing features
7. **Maintain Consistency**: Use consistent terminology across the application

### 6.5 Documentation Guidelines
For all future development, the following documentation guidelines should be followed:

1. **Keep Documentation Updated**: Update the PRD.md and UIUX_SPEC.md files with any new features or changes
2. **Follow Naming Conventions**: Use consistent naming for files (e.g., uppercase with underscores for documentation files)
3. **Component IDs**: Assign unique IDs to all UI components and reference them consistently
4. **Screen IDs**: Assign unique IDs to all screens and reference them consistently
5. **Design Tokens**: Define new design tokens for any new UI elements or styles
6. **User Flows**: Document user flows for any new features
7. **API Integration**: Document API integration points for any new features
8. **Testing Criteria**: Define testing criteria for any new features