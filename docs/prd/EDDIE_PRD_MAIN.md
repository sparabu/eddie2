---
title: Eddie2 Product Requirements Document
version: 1.0.0
last_updated: 2024-03-15
status: active
---

# Eddie2 Product Requirements Document

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Status](https://img.shields.io/badge/status-active-green.svg)
![Last Updated](https://img.shields.io/badge/last%20updated-2024--03--15-lightgrey.svg)

## 🗺️ Navigation
[Documentation Index](../INDEX.md) > [Product Requirements](.) > Main PRD

## �� Related Documents
- [Features Specification](EDDIE_PRD_FEATURES.md)
- [Version History](EDDIE_PRD_VERSIONS.md)
- [Authentication Details](EDDIE_PRD_AUTH.md)
- [UI/UX Specifications](../uiux/EDDIE_UIUX_SPEC_MAIN.md)
- [Design System](../uiux/EDDIE_UIUX_DESIGN_SYSTEM.md)

## 📑 Table of Contents
1. [Overview](#1-overview)
2. [Technology Stack](#2-technology-stack)
3. [Features & Functional Requirements](#3-features--functional-requirements)
4. [Non-Functional Requirements](#4-non-functional-requirements)
5. [Version Control](#5-version-control)
6. [Implementation Notes](#6-implementation-notes)

## 1. Overview

Eddie2 is an AI-driven education-focused application that helps users interact with the OpenAI API through a text-based chat interface. Users can create, read, update, and delete (CRUD) AI-generated question-and-answer (Q&A) pairs either by chatting with the AI or by manually entering them in a dedicated interface.

### MVP Scope
- **Chat Interface**: Text-based chat for user prompts and OpenAI-generated responses, featuring a multi-pane layout similar to ChatGPT (sidebar + main chat area)  
- **Q&A CRUD**: Basic create, read, update, and delete operations for Q&A pairs  
- **Local Storage**: On-device storage for chat history and Q&A pairs  
- **Single User**: No authentication or multi-user support  
- **Web Platform**: Responsive design for web browsers  
- **Error Handling**: Robust handling and user-friendly messaging for all API interactions  
- **Direct Q&A Creation**: Manually create Q&A pairs outside of chat flow  
- **One-Click Saving**: Automatic detection of Q&A pairs in chat with a quick-save option  
- **API Key Storage**: Secure management of user-provided API keys  
- **Selectable Text**: Allows copy/paste of chat messages  
- **File Upload**: Basic single-file attachment within the chat, supporting any file type allowed by OpenAI  
- **Recent Chats**: Display of the 5 most recent chats in the sidebar, sorted chronologically  
- **View All Links**: "View All" links for both Recent Chats and Q&A Pairs sections to show all items  
- **Sidebar Divider**: Vertical divider bar that acts as a toggle for the sidebar  
- **Welcome Message**: Clear welcome message "What can I help you learn?" in new chats  
- **Guided Input**: Input field placeholder "Ask Eddie to create..." to guide users  
- **Simplified Chat List**: Chat list items showing only titles in a single row for better space utilization  
- **Improved Chat Creation**: Enhanced workflow for creating and displaying new chats  
- **Breadcrumb Navigation**: Clear breadcrumb navigation in the app bar showing the current section and selected item  
- **Optimized Chat Creation**: New chats are only created after the first message is sent, not when clicking "New Chat" button  

### Full Implementation Scope (Post-MVP)
- **User Authentication**: Multi-user support and secure login  
- **Cloud Database**: Storage of Q&A pairs and chat history in the cloud  
- **Cross-Platform Support**: Native builds for Windows, Mac, Linux, tablets, and mobile  
- **Advanced File Handling**: Multiple file uploads, drag-and-drop, advanced previews, etc.  
- **Offline Support & Synchronization**: Data sync across multiple devices, with offline access  
- **Optional Dark Mode**: Toggleable dark/light themes  
- **Multilingual Support**: Full localization with language selection  

[↑ Back to Top](#eddie2-product-requirements-document)

## 2. Technology Stack

### MVP Technology Stack
- **UI Framework**:  
  - **Flutter with Custom Theming**:  
    - Leverages Material 3 for advanced theming controls  
    - Overrides default Material styling to achieve a minimal, ChatGPT-like look  
    - Maintains Flutter's multi-platform deployment benefits (web, iOS, Android, desktop)

- **State Management**: Riverpod  
- **API Handling**: Dio for HTTP requests to the OpenAI API  
- **Storage**:  
  - Shared Preferences for local data (chat history and Q&A pairs)  
  - Flutter Secure Storage for sensitive data (API keys)

- **File Handling**:  
  - File picker for selecting single files  
  - Base64 encoding for sending file data to OpenAI

- **AI Processing**: OpenAI API for generating Q&A content  
- **Web Deployment**: Flutter web with responsive design  
- **JSON Handling**: Dart convert library with error handling  
- **Localization**: Flutter's intl package for multilingual support  
- **Version Information**: Package Info Plus for dynamic version display  

### Alternative Web-Centric Option (Non-MVP)
For teams focused primarily on a web application and wanting to use Tailwind CSS or shadcn/ui, a React/Next.js stack could be used instead of Flutter. However, this would forgo the single codebase benefit for mobile/desktop.

### Full Implementation Technology Stack (Post-MVP)
- **Backend**: Firebase for user authentication and real-time database  
- **Database**: Firestore for storing Q&A pairs and user data  
- **Authentication**: Firebase Authentication (Email/Password, Google, Apple)  
- **File Handling**: Firebase Cloud Storage for large files and multi-file support  
- **MVP Technologies**: All components above remain in use and are extended  

[↑ Back to Top](#eddie2-product-requirements-document)

## 3. Features & Functional Requirements

### 3.1 Main Page (Chat Window)

#### MVP Requirements
- **Multi-Pane Layout Inspired by ChatGPT**:  
  - Sidebar for recent chats, Q&A pairs, or settings navigation  
  - Main Chat Section for the AI conversation  
  - Responsive design that collapses the sidebar on mobile  
  - Hideable sidebar with a toggle button in the top-left corner  
  - Vertical divider as a toggle  
  - App logo/title in top bar when sidebar is collapsed  
  - Recent Chats section (5 most recent) with "View All" link  
- **Welcoming User Experience**:  
  - Large welcome message "What can I help you learn?"  
  - Input field placeholder "Ask Eddie to create..."  
  - Clean interface with minimal controls  
- **Conversational Project Setup**:  
  - Natural language interaction to gather project information
  - Dynamic extraction of title and description from user messages
  - Contextual feedback based on what information is still needed
  - Prevention of file attachments during setup phase
  - Seamless transition from setup to normal chat mode
- **Real-time Integration** with the OpenAI API for prompts & responses  
- **Persistent Chat History** stored locally  
- **Automatic Q&A Pair Detection** with a "Save as Q&A" button  
- **Selectable Text** for convenient copy/paste  
- **File Attachment**: Single-file upload workflow  
- **Simplified Chat List Items** for better space utilization

#### Full Implementation (Post-MVP)
- Advanced multi-pane UI (analytics panel, reordering, etc.)  
- Rich text/HTML-based formatting  
- Integration with advanced file-upload features

### 3.2 Q&A Management (CRUD Operations)

#### MVP Requirements
- **Create**:  
  - Q&A from AI responses or a manual form  
  - One-click save of detected Q&A  
  - Sidebar or Q&A screen "Create Q&A"
- **Read**:  
  - Dedicated screen listing all Q&A pairs  
  - Quick navigation from the sidebar
- **Update**:  
  - Edit existing Q&A pairs
- **Delete**:  
  - Remove individual or multiple Q&A pairs
- **Local Storage**:  
  - Persistence via Shared Preferences
- **Error Handling**:  
  - Graceful recovery if API errors occur

#### Full Implementation (Post-MVP)
- Cloud-based sync  
- Advanced search/filter  
- Categorization, tagging, & sharing

### 3.3 OpenAI API Integration

#### MVP Requirements
- Send user-entered text to OpenAI API  
- Detect & structure Q&A pairs from responses  
- Parse response data (JSON, Markdown, or direct)  
- Store & manage API key securely  
- Log errors for debugging

#### Full Implementation (Post-MVP)
- More AI endpoints, batch processing, advanced OpenAI features  
- Configurable AI parameters (temperature, etc.)  
- Language-aware AI responses

### 3.4 Storage & Data Management

#### MVP Requirements
- Local chat/Q&A storage with Shared Preferences  
- Secure API key storage in Flutter Secure Storage  
- JSON serialization for Q&A data  
- Resilience to partial/corrupt data

#### Full Implementation (Post-MVP)
- Firestore-based data storage & multi-device sync  
- Backup/recovery features  
- Optional encryption

### 3.5 Settings Management

#### MVP Requirements
- Basic preferences screen (appearance, language, etc.)  
- Secure interface for managing OpenAI API key  
- Feedback for successful/failed operations  
- File size limits disclaimers  
- Dynamic version display (Package Info Plus)  
- Language selection with immediate UI update  
- Dark mode toggle  
- AI model selection

#### Full Implementation (Post-MVP)
- Profile settings (name, avatar)  
- Advanced AI parameter configuration

### 3.6 File Upload Functionality

#### MVP Requirements
- Single file attachment (valid type & size)  
- Progress indicator, cancel/remove option  
- Base64-encoded file sending to OpenAI  
- Minimal local file retention

#### Full Implementation (Post-MVP)
- Multiple file uploads, drag-and-drop, advanced previews  
- File compression & annotation  
- Integration with Firebase Cloud Storage

### 3.7 Localization & Internationalization

#### MVP Requirements
- Multilingual support (English & Korean)  
- Language selection in Settings  
- Localized UI elements, error messages, tooltips  
- AI responses in user's chosen language

#### Full Implementation (Post-MVP)
- Additional languages, RTL support, auto-detection, region-specific formatting

### 3.8 User Authentication

**Note**: Detailed authentication steps or multi-user scenarios are considered post-MVP. See also **EDDIE_PRD_AUTH.md** if you'd like an in-depth doc about advanced authentication.

- **User Registration**: Email/password, optional display name  
- **User Login**: Secure login, password reset  
- **User Profile**: Display name, profile picture  
- **Authentication State**: Persistent login, automatic redirection  
- **Account Management**: Deletion, confirmation dialogs, error handling

[↑ Back to Top](#eddie2-product-requirements-document)

## 4. Non-Functional Requirements

### 4.1 Security & Privacy
- HTTPS communication  
- Encrypted storage for API keys  
- Minimal data retention  
- Obscured API key display  
- File uploads used only for immediate AI request  

#### Full Implementation (Post-MVP)
- Strong user auth policies  
- Token-based authentication for external APIs  
- Compliance with privacy regulations (GDPR, CCPA)  
- End-to-end encryption for file/data transfers

### 4.2 Performance
- Low-latency chat with OpenAI  
- Efficient local data handling  
- Non-blocking UI  
- Optimized single-file encoding/transmission

#### Full Implementation (Post-MVP)
- Server-side caching, real-time sync for large datasets  
- Background processing for heavy tasks

[↑ Back to Top](#eddie2-product-requirements-document)

## 5. Version Control

We use Git (GitHub) with a structured branching strategy and semantic versioning (X.Y.Z).  
- **Collaboration**: Multiple contributors use feature branches, merging via pull requests.  
- **Traceability**: Detailed commit histories, tags for major releases.  
- **Release Management**: Tag commits as v1.0.0, v1.1.0, etc., for easy rollback.  
- **Semantic Versioning**:  
  - Major (X): Incompatible API changes  
  - Minor (Y): New features, backward-compatible  
  - Patch (Z): Backward-compatible fixes

For the **full version-by-version breakdown**, see [EDDIE_PRD_VERSIONS.md](EDDIE_PRD_VERSIONS.md).

[↑ Back to Top](#eddie2-product-requirements-document)

## 6. Implementation Notes

### 6.1 Completed Features
- **UI**: Multi-pane layout, responsive design, dark mode theming, improved new-chat workflow, breadcrumb navigation, etc.  
- **Core**: AI chat integration, Q&A detection, file attachments, local storage for settings, dynamic version display.  
- **Error Handling**: Enhanced file picking fallback, user-friendly messages, offline retries, Firestore permission fallback.  
- **Localization & i18n**: Full framework for multiple languages, consistent language experience.  
- **Authentication & User Management** (Post-MVP or partial): Email/password, Google Sign-In, profile management, offline support for Firestore, detailed logging.

### 6.2 Known Issues
- Desktop file-picker warnings  
- Firestore connectivity issues in certain networks  
- Deprecation warnings for `signIn` method in Google Sign-In  
- Possible delay in chat dialogue on first message

### 6.3 Next Steps
- Address file-picker warnings for better desktop support  
- Implement more post-MVP features (cloud sync, multiple file uploads, etc.)  
- Set up automated testing/CI/CD  
- Improve Q&A detection algorithms  
- Add more languages & better offline support  
- Migrate Google Sign-In to recommended approach

### 6.4 Localization Guidelines
- No hardcoded strings; define everything in localization files  
- Use placeholders for dynamic content (e.g., `qaPairsDetected(count)`)  
- Provide context for translators; test layout in each language  
- Update docs with new keys  
- Consider cultural differences & maintain consistent terminology

### 6.5 Documentation Guidelines
- Keep docs updated with new features  
- Use consistent file naming (uppercase underscores for docs, snake_case for code)  
- Assign unique IDs to UI components & screens  
- Document new design tokens & user flows in UI/UX specs  
- Define QA testing criteria for any new features

### 6.6 Error Handling Guidelines
- Always show clear, concise user-friendly messages  
- Log detailed error info for debugging  
- Graceful degradation under partial failure  
- Implement retry logic for network issues  
- Respect offline scenarios with queued operations  
- Never expose sensitive data in error logs  
- Localize error messages

### 6.7 Design System Guidelines
- Use `EddieColors` as the single source of truth for color usage  
- Use `EddieThemeExtension` for advanced theming integration  
- Deprecate older `EddieTheme` color helpers  
- Keep styling consistent across the app  
- Ensure accessibility via color contrast, dynamic text sizing  
- Reference `eddie_design_system.dart` for best practices

### 6.8 Enhanced Design System Components
- **EddieColors**: Key color definitions, semantic states, theme-aware methods  
- **EddieTextStyles**: Font families, heading/body styles, dynamic color references  
- **EddieConstants**: Spacing, sizing, animations, consistent corner rounding  
- **EddieThemeExtension**: Integrates custom color sets with Flutter's `Theme`  
- **Custom Components** (e.g., EddieButton, EddieOutlinedButton, EddieTextField, etc.) with usage guidelines and best practices.

[↑ Back to Top](#eddie2-product-requirements-document)

**End of EDDIE_PRD_MAIN.md**  
