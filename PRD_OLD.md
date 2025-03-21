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
- **Recent Chats**: Display of the 5 most recent chats in the sidebar, sorted chronologically ✅
- **View All Links**: "View All" links for both Recent Chats and Q&A Pairs sections to show all items ✅
- **Sidebar Divider**: Vertical divider bar that acts as a toggle for the sidebar ✅
- **Welcome Message**: Clear welcome message "What can I help you learn?" in new chats ✅
- **Guided Input**: Input field placeholder "Ask Eddie to create..." to guide users ✅
- **Simplified Chat List**: Chat list items showing only titles in a single row for better space utilization ✅
- **Improved Chat Creation**: Enhanced workflow for creating and displaying new chats ✅
- **Breadcrumb Navigation**: Clear breadcrumb navigation in the app bar showing the current section and selected item ✅
- **Optimized Chat Creation**: New chats are only created after the first message is sent, not when clicking "New Chat" button ✅

### Full Implementation Scope (Post-MVP)
- **User Authentication**: Multi-user support and secure login ✅
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
- **Backend**: Firebase for user authentication and real-time database ✅
- **Database**: Firestore for storing Q&A pairs and user data ✅
- **Authentication**: Firebase Authentication (Email/Password, Google, Apple) ✅
- **File Handling**: Firebase Cloud Storage for large files and multi-file support ✅
- **MVP Technologies**: All components above remain in use and are extended

## 3. Features & Functional Requirements

### 3.1 Main Page (Chat Window)

#### MVP Requirements
- **Multi-Pane Layout Inspired by ChatGPT** ✅:
  - Sidebar for recent chats, quick access to saved Q&A pairs, or settings navigation.
  - Main Chat Section to display the ongoing conversation with the AI.
  - Responsive design ensures the sidebar can collapse on smaller screens (mobile) to preserve space.
  - Completely hideable sidebar with toggle button in the top-left corner ✅
  - Vertical divider bar between sidebar and main content that acts as a toggle ✅
  - App logo and title in the top bar when sidebar is collapsed ✅
  - Recent Chats section showing the 5 most recent chats, sorted chronologically ✅
  - "View All" links for both Recent Chats and Q&A Pairs sections to show all items ✅
- **Welcoming User Experience** ✅:
  - Large, bold welcome message "What can I help you learn?" in empty chats
  - Input field with helpful placeholder "Ask Eddie to create..." to guide users
  - Clean, focused interface with only essential controls (attach and send buttons)
- Real-time integration with the OpenAI API for user prompts and AI-generated responses ✅
- Persistent chat history stored locally ✅
- Automatic identification of potential Q&A pairs with a "Save as Q&A Pair" button ✅
- Text in both user and AI messages is selectable for convenient copy/paste ✅
- Clear error messages in the event of failed API communication ✅
- File Attachment: Single-file attachment workflow (see Section 3.6) ✅
- **Simplified Chat List Items** ✅:
  - Shows only chat titles in a single row for better space utilization
  - Improved visual appearance with reduced vertical spacing
  - Enhanced readability for quick navigation

#### Full Implementation Requirements (Post-MVP)
- **Advanced Multi-Pane UI**:
  - Additional side panels for analytics, Q&A detail previews, or user notes.
  - Drag-and-drop reordering of panels, or user-customizable layouts.
  - Rich text/HTML-based formatting.
  - Full integration with advanced file-upload features (Section 3.6).

### 3.2 Q&A Management (CRUD Operations)

#### MVP Requirements
- **Create** ✅:
  - Q&A pairs generated from AI responses or entered manually via a form
  - One-click save of AI-detected Q&A pairs directly from the chat
  - Create new Q&A pairs directly from the Q&A screen or sidebar ✅
- **Read** ✅:
  - Dedicated screen or section displaying all stored Q&A pairs
  - Quick navigation to each Q&A pair from the sidebar in the multi-pane layout
  - Search functionality to find specific Q&A pairs ✅
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
- Cloud-based database (e.g., Firestore) for data persistence ✅
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
- Language selection with immediate UI update ✅
- Dark mode toggle with immediate theme change ✅
- AI model selection ✅

#### Full Implementation Requirements (Post-MVP)
- User profile settings (name, avatar, etc.) ✅
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
  - AI responses in the user's selected language ✅
- **Localization Infrastructure** ✅:
  - Centralized string management using Flutter's intl package
  - Separation of UI code and text content
  - Easy addition of new languages in the future

#### Full Implementation Requirements (Post-MVP)
- Support for additional languages
- Right-to-left (RTL) language support
- Language detection based on user's system settings
- Region-specific formatting for dates, numbers, and currencies

### 3.8 User Authentication

#### Requirements
- **User Registration** ✅:
  - Email and password-based registration
  - Optional display name
  - Email verification
  - Comprehensive error handling with user-friendly messages ✅
- **User Login** ✅:
  - Secure login with email and password
  - Password reset functionality
  - Enhanced authentication flow with proper state management ✅
  - Detailed error handling and user feedback ✅
  - Improved sign-out process with proper cleanup ✅
- **User Profile** ✅:
  - Display user information in settings
  - Email verification status
  - Logout functionality
  - Profile picture upload and management ✅
- **Authentication State Management** ✅:
  - Persistent login state
  - Automatic redirection based on authentication status
  - Secure access to user-specific data
  - Robust handling of authentication state transitions ✅
- **Account Management** ✅:
  - Account deletion functionality
  - Confirmation dialogs for destructive actions
  - Proper error handling for authentication operations
  - Detailed logging of deletion process for troubleshooting ✅
  - Graceful handling of Firestore permission issues ✅

## 4. Non-Functional Requirements

### 4.1 Security & Privacy

#### MVP Requirements
- All communication with the OpenAI API over encrypted channels (HTTPS) ✅
- Secure, encrypted storage of user-provided API keys ✅
- Only essential data is stored; unneeded files or data are discarded ✅
- API key display is hidden or obscured by default ✅
- Uploaded files are used only for the immediate AI request and are not permanently stored ✅

#### Full Implementation Requirements (Post-MVP)
- Full user authentication with secure password policies ✅
- Token-based authentication for external API calls ✅
- Compliance with privacy regulations (GDPR, CCPA, etc.)
- End-to-end encryption for file transfers and data at rest
- Secure account deletion with proper data cleanup ✅

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

## 5. Version Control

### Implementation Status
Eddie2 has been successfully set up with Git version control and is hosted on GitHub:

- **Repository**: https://github.com/sparabu/eddie2
- **Current Version**: v1.9.0 (Chat Functionality and Error Handling Improvements)
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

- **v1.3.0**: UI improvements and bug fixes:
  - Redesigned sidebar with completely hideable functionality
  - Added toggle button in top-left corner to show/hide sidebar
  - Moved app logo and title to top bar when sidebar is collapsed
  - Improved Q&A management with direct creation from sidebar
  - Added "+" button to Q&A section in sidebar
  - Moved Settings to bottom of sidebar with separate panel
  - Adjusted font sizes and spacing for better readability
  - Fixed localization issues with missing strings
  - Improved responsive design for different screen sizes
  - Enhanced overall UI consistency

- **v1.4.0**: Enhanced user experience:
  - Added "View All" links for Recent Chats and Q&A Pairs sections
  - Created dedicated screens for viewing all chats and Q&A pairs
  - Added vertical divider bar that acts as a toggle for the sidebar
  - Implemented welcome message "What can I help you learn?" in new chats
  - Added guided input placeholder "Ask Eddie to create..." to help users
  - Improved overall UI consistency and user guidance

- **v1.5.0**: User Authentication:
  - Implemented Firebase Authentication for secure user management
  - Added email and password-based user registration
  - Created login screen with password reset functionality
  - Added email verification for new accounts
  - Updated settings screen to display user profile information
  - Implemented secure authentication state management
  - Added logout functionality
  - Updated documentation to reflect authentication features
  - Added Google Sign-in functionality
  - Implemented account deletion feature

- **v1.6.0**: Enhanced Profile Management:
  - Added comprehensive profile management in settings screen
  - Implemented profile picture upload functionality
  - Added support for username and display name customization
  - Enhanced user profile UI with avatar and editable fields
  - Improved profile data storage in Firestore
  - Added real-time profile updates across the application
  - Enhanced authentication flow with profile setup
  - Improved error handling for profile operations
  - Updated localization for profile management features
  - Added support for both web and mobile platforms

- **v1.7.0**: Google Sign-In and Firestore Integration:
  - Implemented Google Sign-In functionality for web
  - Added Google logo SVG for sign-in buttons
  - Enhanced authentication flow with Google credentials
  - Integrated Firestore database for user data storage
  - Improved error handling for authentication operations
  - Added retry logic for Firestore operations during network issues
  - Enhanced account management with better deletion confirmation
  - Updated UI components for Google Sign-In
  - Improved offline support with Firestore persistence
  - Added detailed logging for authentication and database operations
  - Updated documentation to reflect new authentication methods

- **v1.8.0**: UI and UX Enhancements:
  - Simplified chat list items to show only titles in a single row
  - Improved new chat creation workflow
  - Enhanced chat state management for better user experience
  - Fixed issue with chat dialogue not appearing after submitting first message
  - Optimized chat list item appearance with reduced vertical spacing
  - Improved chat provider to immediately add new chats to state
  - Updated documentation to reflect UI changes
  - Enhanced error handling in chat creation process

- **v1.9.0**: Chat Functionality and Error Handling Improvements:
  - Fixed issue with chat dialogue not displaying after submitting first message
  - Enhanced sign-out process with proper cleanup and state management
  - Improved error handling for Firestore permission issues
  - Added detailed logging for account deletion process
  - Implemented more user-friendly error messages
  - Enhanced chat provider to better handle new chat creation
  - Optimized chat list items to show only titles for better space utilization
  - Added admin tools for user management
  - Improved authentication state transitions
  - Enhanced offline error handling with retry mechanisms

- **v1.10.0**: Chat Creation Workflow and Navigation Improvements:
  - Optimized chat creation workflow to only create chats after first message is sent
  - Added breadcrumb navigation in the app bar showing "Chat > [Chat Title]" format
  - Improved visual hierarchy with distinct styling for breadcrumb elements
  - Enhanced user experience by showing empty chat state when clicking "New Chat"
  - Fixed issue with chat titles not appearing in the app bar
  - Improved responsive design for the app bar on smaller screens
  - Added consistent breadcrumb navigation for Q&A section as well
  - Enhanced visual feedback for current section in the app bar

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
  - Completely hideable sidebar with toggle button
  - Redesigned navigation with app logo and title in top bar
  - Simplified chat list items with optimized single-row layout
  - Enhanced new chat creation workflow
  - Breadcrumb navigation in app bar showing current section and selected item
  - Improved visual hierarchy with distinct styling for navigation elements
  
- **Core Functionality**:
  - Chat interface with OpenAI API integration
  - Q&A pair detection and management
  - File attachment support
  - Settings management with secure API key storage
  - Dynamic version display
  - Direct Q&A pair creation from sidebar
  - Improved chat state management for better user experience
  - Optimized chat creation workflow that only creates chats after first message is sent

- **Error Handling**:
  - Improved error handling for file picking failures
  - Enhanced Q&A detection with fallback to manual creation
  - User-friendly error messages and loading indicators
  - Detailed logging for troubleshooting
  - Graceful handling of Firestore permission issues
  - Improved offline error handling with retry mechanisms

- **Localization & Internationalization**:
  - Complete localization infrastructure for all UI elements
  - Support for English and Korean languages
  - Language selection in settings
  - AI responses in the user's chosen language
  - Consistent language experience throughout the app

- **Authentication & User Management**:
  - Email and password-based authentication
  - Google Sign-In integration
  - Account deletion with confirmation
  - Profile management with display name and profile picture
  - Firestore integration for user data persistence
  - Offline support with error handling
  - Enhanced authentication state management
  - Improved error handling and user feedback
  - Secure sign-out process with proper cleanup
  - Admin tools for user management

### 6.2 Known Issues
- File picker package shows warnings about missing implementations for desktop platforms
- These warnings don't affect web functionality but should be addressed for desktop deployment
- Firestore connectivity may experience intermittent issues in certain network environments
- Google Sign-In shows deprecation warnings for the `signIn` method which will need to be addressed in a future update
- Some users may experience a delay in chat dialogue appearing after submitting the first message

### 6.3 Next Steps
- Address file picker warnings for better desktop platform support
- Implement additional post-MVP features based on user feedback
- Set up automated testing and CI/CD pipeline
- Enhance Q&A detection algorithms for better accuracy
- Add support for additional languages
- Implement localization best practices for all future features
- Consider implementing cloud synchronization for multi-device support
- Migrate Google Sign-In to use the recommended `renderButton` approach
- Enhance Firestore offline persistence capabilities
- Implement additional authentication methods (Apple, GitHub, etc.)
- Add user profile picture upload from camera (for mobile)
- Implement real-time synchronization for multi-device support

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

### 6.6 Error Handling Guidelines
For all future development, the following error handling guidelines should be followed:

1. **User-Friendly Messages**: All error messages should be clear, concise, and helpful to users
2. **Detailed Logging**: Log detailed error information for debugging purposes
3. **Graceful Degradation**: Ensure the app continues to function even when errors occur
4. **Retry Mechanisms**: Implement retry logic for operations that may fail due to network issues
5. **Offline Support**: Handle offline scenarios gracefully with appropriate user feedback
6. **Security Considerations**: Never expose sensitive information in error messages
7. **Localization**: Ensure all error messages are properly localized

### 6.7 Design System Guidelines
For all future development, the following design system guidelines should be followed:

1. **Single Source of Truth**: Use `EddieColors` as the primary source of truth for all color-related functionality
2. **Helper Methods**: Always use the helper methods from `EddieColors` (like `getPrimary`, `getBackground`, etc.) rather than direct color constants
3. **Theme Extension**: For advanced theming needs, use the `EddieThemeExtension` which integrates with Flutter's theming system
4. **Documentation**: Refer to the `eddie_design_system.dart` file for comprehensive guidelines and best practices
5. **Deprecation**: Avoid using deprecated methods in `EddieTheme` that duplicate `EddieColors` functionality
6. **Consistency**: Maintain consistent styling across the application by using the design system components
7. **Accessibility**: Ensure sufficient color contrast and support for dynamic text sizing
8. **Examples**: Refer to the `eddie_theme_example.dart` file for examples of how to use the design system

### 6.8 Enhanced Design System Components
The Eddie2 application now includes a comprehensive design system with the following key components:

1. **EddieColors**: The primary source of truth for all color definitions and color-related functionality
   - Provides helper methods for accessing theme-aware colors
   - Includes semantic color definitions for different UI states
   - Supports both light and dark themes

2. **EddieTextStyles**: Contains all text style definitions and helper methods
   - Uses Google Fonts (Inter) for consistent typography
   - Provides helper methods for accessing theme-aware text styles
   - Includes styles for headings, body text, buttons, and more

3. **EddieConstants**: Provides standardized values for spacing, sizing, animations, and other constants
   - Includes spacing constants (xxs, xs, sm, md, lg, xl, xxl)
   - Defines border radius constants for consistent corner rounding
   - Provides animation duration constants for consistent timing
   - Includes elevation constants for shadows and depth

4. **Custom Components**: A growing library of reusable UI components
   - EddieButton: Customizable button with multiple variants and sizes
   - EddieOutlinedButton: Outlined variant of the button
   - EddieTextField: Styled text input field
   - EddieLogo: App logo component with customizable size
   - SidebarSection: Collapsible section for sidebar content
   - SidebarItem: Individual item for sidebar lists
   - ThemeToggle: Dark/light mode toggle switch
   - ViewAllLink: Link to view all items in a list

5. **Component Guidelines**: Clear guidelines for using components consistently
   - When to use each button variant
   - How to structure forms with proper spacing
   - Consistent patterns for sidebar navigation
   - Proper usage of spacing and sizing constants

For all future development, refer to the `eddie_design_system.dart` file for comprehensive documentation and best practices.