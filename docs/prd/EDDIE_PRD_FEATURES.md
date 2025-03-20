---
title: Eddie2 Features Specification
version: 1.5.0
last_updated: 2025-03-20
status: active
---

# Eddie2 Features Specification

![Version](https://img.shields.io/badge/version-1.5.0-blue.svg)
![Status](https://img.shields.io/badge/status-active-green.svg)
![Last Updated](https://img.shields.io/badge/last%20updated-2025--03--20-lightgrey.svg)

## 🗺️ Navigation
[Documentation Index](../INDEX.md) > [Product Requirements](.) > Features

## 📚 Related Documents
- [Main PRD](EDDIE_PRD_MAIN.md)
- [Version History](EDDIE_PRD_VERSIONS.md)
- [Authentication Details](EDDIE_PRD_AUTH.md)
- [UI/UX Specifications](../uiux/EDDIE_UIUX_SPEC_MAIN.md)
- [Design System](../uiux/EDDIE_UIUX_DESIGN_SYSTEM.md)

## 📑 Table of Contents
1. [Core Features](#1-core-features)
2. [MVP Features](#2-mvp-features)
3. [Post-MVP Features](#3-post-mvp-features)
4. [Feature Dependencies](#4-feature-dependencies)
5. [Implementation Priorities](#5-implementation-priorities)

## 🔗 Code References
- Feature Implementation: See individual feature documentation
- State Management: `lib/providers/`
- API Integration: `lib/services/`
- UI Components: `lib/widgets/`

# Eddie2 – Detailed Feature Breakdown

## 1. Core Features

### 1.1 Chat Interface
- **User Story**: As a user, I want a familiar chat-like layout with a sidebar for quick navigation and a main pane for the conversation, so I can manage multiple chats easily.
- **Key Points**:
  - Sidebar can collapse on mobile or user's command.
  - "Recent Chats" in the sidebar for quick switching.
  - "View All" expands the list in-place to show all chats within the sidebar.
  - Context menu for each chat in the sidebar with options to rename or delete the chat.
  - Three-dot menu appears when a chat is selected, providing quick access to management functions.
  - Modal dialogs for confirmation of chat deletion or renaming.

### 1.2 OpenAI Integration
- **User Story**: As a user, I want to send prompts to the OpenAI API and receive responses, so I can get AI-generated answers to my questions.
- **Key Points**:
  - Secure API key storage.
  - Error handling for API issues.
  - Response formatting.

### 1.3 File Attachment
- **User Story**: As a user, I want to attach files for the AI to analyze or reference, so I can get context-based answers.
- **Key Points**:
  - Restrict size to OpenAI's limits.
  - Show progress while uploading.
  - If file is invalid or too large, show error.
  - Support for image file attachments in chat messages.
  - Support for multiple image attachments in a single message.
  - Image previews within the chat interface.
  - Display of multiple images in a grid layout when attached to the same message.
  - Persistence of image attachments across browser sessions (web platform).
  - All images in a multi-image message are sent to OpenAI for comprehensive analysis.
  - Preservation of file order exactly as selected by the user in the file picker.
  - Consistent ordering of files throughout the UI and when sending to the API.

### 1.4 Enhanced Chat Creation
- **User Story**: As a user, I want a new chat to appear only after sending a first message, so my chat list doesn't fill with empty placeholders.
- **Key Points**:
  - Clicking "New Chat" leads to an "empty chat" state.
  - Actual chat record is created when the user sends a message.
  - The first user message becomes the default chat title.

### 1.5 Breadcrumb Navigation
- **User Story**: As a user, I want to see where I am in the app (Chat > My Chat Title), so I never feel lost.
- **Key Points**:
  - Replaces the default app title when in a chat or Q&A detail.
  - "Chat > View All" for All Chats Screen, etc.

### 1.6 Improved Project Setup Flow
- **User Story**: As a user, I want a natural conversation flow when setting up a new project, so I can provide title and description without feeling like I'm filling out a form.
- **Key Points**:
  - Conversational approach to collecting project information
  - Dynamic adaptation to user responses
  - Ability to extract both title and description from a single message
  - Prevention of duplicate messages during setup
  - Blocking of file/image attachments until setup is complete
  - Clear user feedback about project setup state

[↑ Back to Top](#eddie2-features-specification)

## 2. MVP Features

### 2.1 Q&A Management
- **User Story**: As a user, I want to create, read, update, and delete Q&A pairs, so I can maintain a library of useful information.
- **Key Points**:
  - Manual creation of Q&A pairs.
  - List view of all Q&A pairs.
  - Edit and delete functionality.

### 2.2 Automatic Q&A Detection
- **User Story**: As a user, I want to save a Q&A directly from an AI's answer without retyping it, so I can build my Q&A library easily.
- **Key Points**:
  - "Save as Q&A" on assistant messages.
  - If not parseable automatically, user can do it manually.

### 2.3 Local Storage
- **User Story**: As a single user, I want my Q&As to be saved on-device, so I don't lose them when I close the app.
- **Key Points**:
  - Shared Preferences for quick access.
  - JSON serialization for data structure.
  - Error handling for corrupted data.

[↑ Back to Top](#eddie2-features-specification)

## 3. Post-MVP Features

### 3.1 Multi-User Support
- **User Story**: As a user, I want to create an account and sync my data across devices, so I can access my Q&As from anywhere.
- **Key Points**:
  - User authentication.
  - Cloud storage sync.
  - Profile management.

### 3.2 Advanced File Handling
- **User Story**: As a user, I want to upload multiple files and get AI analysis of their content, so I can work with complex documents.
- **Implementation Status**:
  - Multiple image attachments: ✅ Implemented
  - Multiple document/text files: ⏳ Planned
- **Key Points**:
  - Multiple file upload for images, currently limited to image formats (jpg, jpeg, png, webp, gif).
  - Support for sending multiple images to OpenAI in a single message.
  - Future enhancement for multiple document upload.
  - File type validation.
  - Progress tracking.

### 3.3 Offline Support
- **User Story**: As a user, I want to work with my Q&As even when offline, so I can continue learning without internet access.
- **Key Points**:
  - Local data persistence.
  - Sync when online.
  - Conflict resolution.

[↑ Back to Top](#eddie2-features-specification)

## 4. Feature Dependencies

### 4.1 Core Dependencies
- OpenAI API access
- Local storage capabilities
- File system access

### 4.2 MVP Dependencies
- Q&A parsing logic
- JSON serialization
- Error handling system

### 4.3 Post-MVP Dependencies
- Authentication system
- Cloud storage
- Sync mechanism

[↑ Back to Top](#eddie2-features-specification)

## 5. Implementation Priorities

### 5.1 Phase 1: Core Features
1. Chat interface
2. OpenAI integration
3. Basic file attachment
4. Enhanced chat creation

### 5.2 Phase 2: MVP Features
1. Q&A management
2. Automatic Q&A detection
3. Local storage

### 5.3 Phase 3: Post-MVP Features
1. Multi-user support
2. Advanced file handling
3. Offline support

[↑ Back to Top](#eddie2-features-specification)

## 6. Settings & Customization

### 6.1 API Key Management
- **User Story**: As a user, I want to securely store my OpenAI key so the app can call the API on my behalf.
- **Key Points**:
  - Secure Storage for the key.
  - Masked display in the Settings screen.
  - Proper error handling if the key is invalid.

### 6.2 Appearance & Language
- **Dark Mode Toggle**: Instantly switches theme to dark or light.
- **Language Selection**: Switch UI strings on the fly, with fallback to English if incomplete.

### 6.3 AI Model Selection
- **User Story**: As a user, I want to choose between GPT-3.5, GPT-4, or other models, so I can control cost or performance.
- **Key Points**:
  - Model dropdown in Settings.
  - Pass the chosen model to OpenAI.

### 6.4 Chat Management
- **User Story**: As a user, I want to easily manage my chats directly from the sidebar, so I can keep my chat list organized.
- **Key Points**:
  - Context menu (three-dot menu) for each chat in the sidebar.
  - Rename option to modify chat titles for better organization.
  - Delete option with confirmation to remove unwanted conversations.
  - Visual indicators that highlight the currently selected chat.
  - Streamlined interaction pattern with minimal clicks required.

## 7. Navigation & User Flow

### 7.1 Centralized Navigation System
- **User Story**: As a user, I want to navigate between different sections of the app seamlessly, so I can focus on my work without confusion.
- **Implementation Status**: ✅ Implemented
- **Key Points**:
  - Centralized navigation state management.
  - Consistent navigation experience across devices.
  - Proper state resetting when navigating away from screens.
  - Special handling for mobile navigation patterns.
  - Clear visual indicators of the current screen.

### 7.2 Project Setup Flow
- **User Story**: As a user, I want a guided process to set up my projects, so I can easily provide all necessary information.
- **Implementation Status**: ✅ Implemented
- **Key Points**:
  - Chat-based interface for collecting project information.
  - Step-by-step guidance through the setup process.
  - Validation of user inputs in real-time.
  - Restricted operations during setup (no file uploads).
  - Clear indication of setup state.
  - Smooth transition to normal chat after setup completion.

[↑ Back to Top](#eddie2-features-specification)

## 8. Localization & Internationalization

### 8.1 Current Support
- English, Korean by default.
- UI & errors fully localized.

### 8.2 Future Plans
- Additional languages (Chinese, Spanish, etc.).
- Right-to-Left layout if Arabic/Hebrew are supported.
- Region-specific formatting (dates, numbers).

## 9. Advanced File Handling (Post-MVP)

### 9.1 Multiple Files
- **User Story**: As a user, I want to attach multiple files at once for the AI to consider.
- **Plan**:
  - Possibly multi-file pickers, drag-and-drop in the chat input.

### 9.2 Compression & Preview
- Inline previews for images, PDF expansions, etc.

## 10. Cross-Platform Goals (Post-MVP)

### 10.1 Desktop Builds
- Windows, Mac, Linux packaging.
- Some adjustments for file pickers, system menubar, etc.

### 10.2 Mobile Builds
- iOS/Android store deployment.
- Same Flutter codebase, but ensure performance & memory usage are tested.

---

## 11. Offline Support & Sync (Post-MVP)

- Real-time sync with Firestore if user logs in.
- Offline read/write with queued updates.
- Conflict resolution (last-write-wins or custom merges).

---

## 12. Additional Feature Ideas

- **User Profiles** with advanced preferences (post-MVP).
- **Notifications** for chat updates or Q&A reminders.
- **Analytics**: track usage patterns to refine Q&A suggestions.

---

**End of EDDIE_PRD_FEATURES.md**
