---
title: Eddie2 UI/UX Interaction Patterns
version: 1.5.0
last_updated: 2025-03-20
status: active
---

# Eddie2 UI/UX Interaction Patterns

![Version](https://img.shields.io/badge/version-1.5.0-blue.svg)
![Status](https://img.shields.io/badge/status-active-green.svg)
![Last Updated](https://img.shields.io/badge/last%20updated-2025--03--20-lightgrey.svg)

## 🗺️ Navigation
[Documentation Index](../INDEX.md) > [UI/UX Documentation](.) > Interaction Patterns

## 📚 Related Documents
- [Main UI/UX Specification](EDDIE_UIUX_SPEC_MAIN.md)
- [Design System](EDDIE_UIUX_DESIGN_SYSTEM.md)
- [Product Requirements](../prd/EDDIE_PRD_MAIN.md)
- [Feature Specifications](../prd/EDDIE_PRD_FEATURES.md)

## 📋 Table of Contents
1. [Navigation Patterns](#1-navigation-patterns)
2. [Input Patterns](#2-input-patterns)
3. [Feedback Patterns](#3-feedback-patterns)
4. [Gesture Support](#4-gesture-support)
5. [Animation Guidelines](#5-animation-guidelines)
6. [Error States](#6-error-states)
7. [Loading States](#7-loading-states)
8. [Image Attachment Interaction](#8-image-attachment-interaction)
9. [Chat Management Interactions](#9-chat-management-interactions)
10. [Project Setup Interactions](#10-project-setup-interactions)
11. [Cross-Screen Navigation System](#11-cross-screen-navigation-system)

## 🔗 Code References
- Navigation Service: `lib/services/navigation_service.dart`
- Input Components: `lib/widgets/input/`
- Feedback Components: `lib/widgets/feedback/`
- Animation Utilities: `lib/utils/animation_utils.dart`

# Eddie2 UI/UX – Extended Interactions & Advanced Flows

This document builds on the interaction patterns in [EDDIE_UIUX_SPEC_MAIN.md](./EDDIE_UIUX_SPEC_MAIN.md), offering more detailed or edge-case flows. It also outlines certain QA or administration processes.

---

## 1. Complex or Less Common User Flows

### 1.1 Chat with Multiple File Uploads
- **Implementation Status**: 
  - Multiple images: ✅ Implemented
  - Multiple documents: ⏳ Planned (Post-MVP)

#### Current Implementation (Images)
1. User clicks the "Attach" button in the chat input.
2. File picker dialog opens supporting multi-select for images.
3. User selects multiple image files (jpg, jpeg, png, webp, gif).
4. System validates each image (size, format).
5. Preview thumbnails appear in the input area showing all selected images.
6. User types a message (optional).
7. User clicks the send button.
8. Message with all image attachments is sent to the AI.
9. Images appear in a grid layout in the user's message bubble.
10. AI response references and analyzes all images content.

#### Planned Implementation (Documents)
1. Multiple document file support will be added in future updates.
2. Will include similar UI patterns adapted for document previews.
3. If any file is invalid, show error while preserving the valid ones.

### 1.2 Merging Q&A Pairs
- Potential future feature: user merges multiple Q&A pairs into one.  
- Could appear as a batch action in the Q&A screen.

### 1.3 Bulk Deletion of Chats/Q&A
1. User selects multiple items (checkbox or multi-select).  
2. Click "Delete All."  
3. Confirmation dialog with item count.  
4. On success, user sees "N items deleted."

---

## 2. QA & Testing Considerations

### 2.1 Manual Tests
- **Theme Switching**: Ensure UI updates instantly for both light/dark.  
- **Language Switching**: Confirm strings reload, no leftover text.  
- **Offline Mode**: Disconnect network mid-chat; does the system queue messages or show offline banner?

### 2.2 Automated Tests
- **Widget Tests**: For UI components (Sidebar, ChatInput, etc.).  
- **Integration Tests**: Full flows (login → open chat → send message → sign out).  
- **Golden Tests**: Check layout stability with different screen sizes & languages.

### 2.3 Performance Profiling
- **Startup Time**: Evaluate how quickly the main screen loads.  
- **Memory Use**: For large chat histories.  
- **API Latency**: Possibly measure round-trip time to OpenAI.

---

## 3. Admin or Moderator Flows (Optional)

### 3.1 Admin Q&A Editing
- Admin might override user data or delete items that violate terms.  
- Special admin UI or same UI with elevated permissions.

### 3.2 Remote Chat Monitoring
- If an institutional version is needed, an admin might watch multiple user chats in real time.  
- Requires strong privacy disclaimers and user consent.

---

## 4. Detailed Edge Cases

### 4.1 Chat Title Collisions
- If user's first message is identical across multiple new chats, you might have repeated chat titles.  
- Possibly append numeric suffix or date/time.

### 4.2 Q&A Pair with No Answer
- Some AI responses might yield a question but no answer.  
- Save as partial Q&A? Show a warning?

### 4.3 Setting an Invalid API Key
- Show user-friendly error: "Invalid key format."  
- Provide a link or tooltip to help them obtain a proper key.

---

## 5. Future Interaction Ideas

- **Drag-and-Drop** Chat Reordering  
- **Pin Important Chats**  
- **Q&A Tagging** & advanced filtering  
- **Batch Export** Q&A pairs as CSV or JSON  
- **In-app Notifications** for real-time updates

---

## 8. Image Attachment Interaction

### 8.1 Attaching Images to Chat Messages

#### Single Image Flow
1. User clicks attachment button in the chat input
2. File picker dialog opens showing supported image formats (jpg, jpeg, png, webp, gif)
3. User selects an image file
4. System validates the image (size, format)
5. If valid, a preview of the image appears in the input area
6. User types a message (optional)
7. User clicks send button
8. Message with image attachment is sent to the AI
9. Image appears inline in the user's message bubble
10. AI response references the image content

#### Multiple Image Flow
1. User clicks attachment button in the chat input
2. File picker dialog opens showing supported image formats (jpg, jpeg, png, webp, gif)
3. User selects multiple image files (multi-select is supported)
4. System validates each image (size, format)
5. If valid, previews of all selected images appear in the input area in the same order as selected
6. User types a message (optional)
7. User clicks send button
8. Message with all image attachments is sent to the AI, preserving the exact order as selected by the user
9. Images appear in a grid layout in the user's message bubble
   - First image (in user's selection order) is displayed prominently
   - Additional images are shown in a grid below the main image, maintaining the original selection order
10. AI response references and analyzes all images content in the order they were submitted

#### Error Handling
- If image is too large: Error message indicating the size limit
- If format is unsupported: Error message listing supported formats
- If image fails to load after sending: Error placeholder with descriptive message
- For web platform: Warning about temporary nature of attachments when errors occur
- For multiple images: Individual validation with indication of which images failed

#### Web Platform Considerations
- Web file data is persisted to localStorage for improved experience
- File data is keyed by a unique identifier
- Files can be accessed across page refreshes (up to 10 most recent files)
- Multiple image files are individually stored and tracked
- Error states include instructions about session limitations

#### Animation & Transitions
- Smooth fade-in of image previews
- Loading state when processing large images
- Subtle scale animation when attaching images
- Grid layout animation when displaying multiple images
- Error messages appear with brief fade-in

#### Component Interactions
- **MessageBubble** component displays images with appropriate formatting
  - Handles single and multiple image layouts adaptively
  - Provides grid layout for multiple images
- **ErrorPlaceholder** component shows when images fail to load
- **FileService** handles persistence of web file data
- **OpenAIService** processes and includes all images in API requests

## 9. Chat Management Interactions

### 9.1 Sidebar Chat Options Menu

#### Chat Options Flow
1. User navigates to the sidebar where recent chats are displayed
2. User selects a chat by clicking on it
3. When a chat is selected, a three-dot menu icon appears to the right of the chat item
4. User clicks on the three-dot menu icon
5. A context menu appears with two options: "Rename" and "Delete"
6. User selects the desired action

#### Rename Chat Flow
1. User clicks on "Rename" in the context menu
2. A modal dialog appears with:
   - Title: "Rename Chat"
   - Text field pre-populated with the current chat title
   - Cancel button
   - Save button
3. User modifies the chat title
4. User clicks "Save" to confirm changes or "Cancel" to discard
5. On save, the chat title is immediately updated in the sidebar and throughout the app
6. The dialog is dismissed automatically

#### Delete Chat Flow
1. User clicks on "Delete" in the context menu
2. A confirmation dialog appears with:
   - Title: "Delete chat?"
   - Warning message: "The chat will be deleted and removed from your chat history. This action cannot be undone."
   - Cancel button
   - Delete button (highlighted in red)
3. User clicks "Delete" to confirm or "Cancel" to abort
4. On deletion, the chat is removed from the sidebar and the user is redirected to:
   - Another chat if available
   - The empty state if no chats remain

#### Visual Feedback
- Selected chat is highlighted with:
  - Background color change
  - Primary color for the icon
  - Bold text for the title
- Three-dot menu only appears for the currently selected chat
- Hover effects on menu items provide visual feedback
- Dialog animations provide smooth transitions
- Error states (if a rename or delete operation fails) show appropriate error messages

#### Component Interactions
- **SidebarItem** component handles the display of each chat item and its options
- **MainScreen** manages the state of selected chats and provides callback functions
- **ChatProvider** handles the data operations for renaming and deleting chats

### 9.5 Sidebar List Expansion

#### Expanding Chat List
1. User clicks "View All" link in the Chats section of sidebar
2. List expands to show all chats in the same sidebar
3. The "View All" link changes to "Show Less" with an upward-facing arrow
4. User can scroll through the entire list of chats

#### Collapsing Chat List
1. User clicks "Show Less" link 
2. List collapses back to showing only the 5 most recent chats
3. The link text returns to "View All" with a downward-facing arrow

#### Expanding Q&A Pairs List
1. User clicks "View All" link in the Q&A Pairs section of sidebar
2. List expands to show all Q&A pairs in the same sidebar
3. The "View All" link changes to "Show Less" with an upward-facing arrow
4. User can scroll through the entire list of Q&A pairs

#### Collapsing Q&A Pairs List
1. User clicks "Show Less" link
2. List collapses back to showing only the 5 most recent Q&A pairs
3. The link text returns to "View All" with a downward-facing arrow

## 10. Project Setup Interactions

### 10.1 Conversational Project Setup Flow

#### Flow Overview
1. User creates a new project which enters setup mode
2. System displays welcome message: "Welcome to your new project! Please tell me about what you'd like to work on."
3. User responds with project description
4. System extracts project title and details from the user's message
5. System confirms the project setup is complete
6. Chat transitions to regular project chat mode

#### Project Setup Restrictions
1. During project setup, file attachments are disabled
2. If user attempts to upload files during setup:
   - A SnackBar appears with the message: "You cannot attach files until project setup is complete"
   - The file upload button remains visible but is non-functional
3. Once setup is complete, all file attachment capabilities are enabled

#### Setup State Visual Indicators
1. During setup, a subtle background color change in the chat indicates setup mode
2. The message input field shows a placeholder text: "Describe your project..."
3. Once complete, the chat reverts to standard appearance with normal input placeholder

### 10.2 Navigation During Project Setup

#### Setup Interruption Flow
1. If user navigates away during project setup:
   - Setup state is preserved
   - Navigating back to the project continues from where they left off
2. Settings button is always accessible during setup
3. Navigation to other projects is permitted but current setup state is maintained

#### Setup Completion Navigation
1. Once setup is complete:
   - Full navigation capabilities are enabled
   - Project appears in the sidebar with its extracted title
   - Project can be accessed from any screen via the sidebar

## 11. Cross-Screen Navigation System

### 11.1 Navigation Provider Interactions

#### Navigation State Changes
1. User clicks on a navigation element (sidebar item, settings button, etc.)
2. Navigation provider updates the relevant state:
   - `selectedScreenIndex` for main screen changes
   - `selectedProjectId` for project selection
   - visibility flags for content areas
3. UI components react to state changes and render appropriate content

#### Project-to-Settings Navigation
1. User is viewing a project and clicks Settings button
2. Navigation provider:
   - Updates `selectedScreenIndex` to 2 (Settings)
   - Sets `selectedProjectId` to null
   - Sets `showProjectContent` to false
3. UI transitions from project view to settings screen

#### Mobile-Specific Navigation
1. On small screens, bottom navigation bar appears
2. User taps navigation item to change screens
3. Navigation provider updates state and handles any cleanup needed
4. Visual transition indicates screen change
5. Selected item in bottom bar is highlighted

### 11.2 Screen Transition Patterns

#### Transition Effects
1. Cross-fade between main content areas
2. Sidebar selection indicators update immediately
3. Content containers maintain height during transitions to prevent layout shifts
4. Button states update to reflect current navigation context

#### Error State Navigation
1. If navigation fails due to an error:
   - Error message appears as a SnackBar
   - Navigation state remains at previous valid state
   - User can retry the navigation action

#### Deep Linking Support
1. When navigating via URL (future feature):
   - Navigation provider parses URL parameters
   - Sets appropriate state based on deep link target
   - Renders the correct screen with proper context

[↑ Back to Top](#eddie2-uiux-interaction-patterns)

---

**End of EDDIE_UIUX_INTERACTIONS.md**
