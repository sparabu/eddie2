---
title: Eddie2 UI/UX Specifications
version: 1.0.0
last_updated: 2024-03-15
status: active
---

# Eddie2 UI/UX Specifications

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Status](https://img.shields.io/badge/status-active-green.svg)
![Last Updated](https://img.shields.io/badge/last%20updated-2024--03--15-lightgrey.svg)

## 🗺️ Navigation
[Documentation Index](../INDEX.md) > [UI/UX Documentation](.) > Main Specifications

## 📑 Table of Contents
1. [UI Component Glossary](#1-ui-component-glossary)
2. [Screen Map](#2-screen-map)
3. [Design System Reference](#3-design-system-reference)
4. [Interaction Patterns](#4-interaction-patterns)
5. [User Flow Diagrams](#5-user-flow-diagrams)
6. [State Management Conventions](#6-state-management-conventions)
7. [API Integration Points](#7-api-integration-points)
8. [Localization Guidelines](#8-localization-guidelines)
9. [Responsive Behavior](#9-responsive-behavior)
10. [Accessibility Standards](#10-accessibility-standards)
11. [Error Handling](#11-error-handling)
12. [Empty States](#12-empty-states)
13. [Loading States](#13-loading-states)
14. [Animation & Transition Guidelines](#14-animation--transition-guidelines)
15. [Testing & QA Guidelines](#15-testing--qa-guidelines)
16. [Admin Tools](#16-admin-tools)

## 🔗 Code References
- Design System Implementation: `lib/theme/eddie_design_system.dart`
- Component Examples: See individual component documentation
- Theme Configuration: See `lib/theme/eddie_colors.dart` and `lib/theme/eddie_text_styles.dart`

# EDDIE2 UI/UX Specifications

This document defines the UI components, screens, design system, and interaction patterns for the Eddie2 application. It serves as a reference for maintaining UI consistency and improving communication between team members.

---
## Table of Contents

1. [UI Component Glossary](#1-ui-component-glossary)  
2. [Screen Map](#2-screen-map)  
3. [Design System Reference](#3-design-system-reference)  
4. [Interaction Patterns](#4-interaction-patterns)  
5. [User Flow Diagrams](#5-user-flow-diagrams)  
6. [State Management Conventions](#6-state-management-conventions)  
7. [API Integration Points](#7-api-integration-points)  
8. [Localization Guidelines](#8-localization-guidelines)  
9. [Responsive Behavior](#9-responsive-behavior)  
10. [Accessibility Standards](#10-accessibility-standards)  
11. [Error Handling](#11-error-handling)  
12. [Empty States](#12-empty-states)  
13. [Loading States](#13-loading-states)  
14. [Animation & Transition Guidelines](#14-animation--transition-guidelines)  
15. [Testing & QA Guidelines](#15-testing--qa-guidelines)  
16. [Admin Tools](#16-admin-tools)

---
## 1. UI Component Glossary

### Navigation Components

#### Sidebar
- **Location**: Left side of the screen  
- **Description**: Primary navigation component containing recent chats, Q&A section, and settings  
- **States**:  
  - Expanded: Shows full sidebar with all sections  
  - Collapsed: Hidden from view  
- **Elements**:
  - Toggle button: Shows/hides the sidebar  
  - Recent Chats section: List of 5 most recent chats with "New Chat" button above  
  - "View All" link for Recent Chats: Shows all chats in the main content area  
  - Q&A section: List of Q&A pairs with "Create Q&A" button  
  - "View All" link for Q&A Pairs: Shows all Q&A pairs in the main content area  
  - Settings section: At the bottom of sidebar  
- **Component ID**: `Sidebar`

#### Sidebar Divider
- **Location**: Between sidebar and main content area  
- **Description**: Vertical divider that acts as a toggle for the sidebar  
- **Properties**:
  - Width: 1px  
  - Height: Full height of the screen  
  - Color: Dark gray in dark mode, light gray in light mode  
- **Behavior**:
  - Click toggles expanded/collapsed sidebar  
  - Hover shows a resize cursor  
- **Component ID**: `SidebarDivider`

#### Top App Bar
- **Location**: Top of the screen  
- **Description**: Contains app title, logo, sidebar toggle, and breadcrumb navigation  
- **Elements**:
  - Sidebar toggle button  
  - App logo (Eddie2 logo)  
  - Breadcrumb navigation:  
    - Primary section (Chat/Q&A Pairs)  
    - Chevron ">" separator  
    - Selected item (chat title or Q&A question)  
  - App title "Eddie2" (shown if no breadcrumb is active)  
- **Variants**:
  - Default: Shows app title  
  - Chat selected: "Chat > [Chat Title]"  
  - Q&A selected: "Q&A Pairs > [Question]"  
  - View All: "Chat > View All" or "Q&A Pairs > View All"  
- **Component ID**: `TopAppBar`

#### Sidebar Section
- **Location**: Within sidebar  
- **Description**: Collapsible section for organizing sidebar content  
- **Properties**:
  - Title (e.g., "Recent Chats", "Q&A Pairs")  
  - Icon (optional, e.g., for Settings)  
  - Children: List of items in the section  
  - Add button: Optional (used in Q&A section)  
  - View All link: Optional link to see all items in main content  
- **States**:
  - Expanded: Shows children  
  - Collapsed: Header only  
- **Component ID**: `SidebarSection`

#### Bottom Navigation Bar
- **Location**: Bottom of the screen (mobile)  
- **Description**: Alternative navigation for small screens  
- **Elements**:  
  - Chat tab  
  - Q&A Pairs tab  
  - Settings tab  
- **Component ID**: `BottomNavigationBar`

### Chat Components

#### Chat List Item
- **Location**: Recent Chats section in sidebar  
- **Description**: Individual chat entry in the sidebar list  
- **Properties**:
  - Title (default "New Chat" or localized)  
  - Delete button (removes the chat)  
- **States**:
  - Selected: Highlighted  
  - Unselected: Regular background  
- **Component ID**: `ChatListItem`
- **Updated Design**:
  - Single-row title  
  - Reduced vertical spacing  
  - More chats visible in sidebar  
  - Enhanced readability

#### Message Bubble
- **Location**: Chat area  
- **Description**: Container for individual messages  
- **Variants**:
  - User Message: Right-aligned, primary color background  
  - Assistant Message: Left-aligned, neutral background  
- **Properties**:
  - Message content (text)  
  - Timestamp  
  - "Save as Q&A" button (assistant messages only)  
- **Component ID**: `MessageBubble`

#### Chat Input
- **Location**: Bottom of chat area  
- **Description**: Input field for typing messages  
- **Elements**:
  - Text field (placeholder "Ask Eddie to create...")  
  - Attach File button  
  - Send button  
- **States**:
  - Empty: Send disabled  
  - With text: Send enabled  
  - Loading: Shows loading indicator  
- **Component ID**: `ChatInput`

### Q&A Components

#### Q&A Pair Item
- **Location**: Q&A screen  
- **Description**: Container for a question-answer pair  
- **Properties**:
  - Question text  
  - Answer text  
  - Tags (if any)  
  - Edit button (opens dialog)  
  - Delete button  
- **Component ID**: `QAPairItem`

#### Q&A Pair Form
- **Location**: Dialog  
- **Description**: Form for creating/editing Q&A pairs  
- **Fields**:
  - Question  
  - Answer  
  - Tags  
- **Buttons**:
  - Save, Cancel  
- **Component ID**: `QAPairForm`

#### Q&A Search Bar
- **Location**: Top of Q&A screen  
- **Description**: Search input plus Create Q&A button  
- **Elements**:
  - Search field (filters Q&A pairs)  
  - Create Q&A button (opens Q&A Pair Form)  
- **Component ID**: `QASearchBar`

### Settings Components

#### API Key Form
- **Location**: Settings screen  
- **Description**: Manages OpenAI API key  
- **Elements**:
  - API key field  
  - Save button  
  - Delete button  
- **States**:
  - Empty: shows helper text  
  - With API key: masked key  
  - Error: validation error  
- **Component ID**: `APIKeyForm`

#### Settings Toggle
- **Location**: Settings screen  
- **Description**: Toggle switch for boolean settings  
- **Example**: Dark Mode toggle  
- **Component ID**: `SettingsToggle`

#### Settings Dropdown
- **Location**: Settings screen  
- **Description**: Dropdown for selecting from options  
- **Examples**:  
  - Language selector  
  - AI Model selector  
- **Component ID**: `SettingsDropdown`

### Authentication Components

#### Delete Account Button
- **Location**: Settings screen, Authentication section  
- **Description**: Button to permanently delete user account  
- **Properties**:
  - Icon (delete forever)  
  - Text ("Delete Account")  
  - Subtitle (consequences of deletion)  
- **States**:
  - Default: clickable  
  - Loading: indicator while processing  
  - Disabled: when deletion is in progress  
- **Component ID**: `DeleteAccountButton`

#### Confirmation Dialog
- **Location**: Modal overlay  
- **Description**: Confirm destructive actions (e.g., account deletion)  
- **Elements**:
  - Title  
  - Content (consequences)  
  - Cancel button  
  - Confirm button (red for destructive)  
- **Component ID**: `ConfirmationDialog`

#### Enhanced Sign Up Link
- **Location**: Bottom of login screen  
- **Description**: Button-like link to signup screen  
- **Properties**:
  - Text: "Sign Up"  
  - Font size: 16px, Bold  
  - Padding: 8px vertical, 16px horizontal  
  - Border radius: 8px  
- **States**:
  - Dark Mode: White text, primary color w/30% opacity background, 1.5px border  
  - Light Mode: Primary color text, no background  
  - Disabled: If login in progress  
- **Component ID**: `EnhancedSignUpLink`

#### Google Sign-In Button
- **Location**: Login & Signup screens  
- **Description**: Auth with Google credentials  
- **Properties**:
  - Height: 40px  
  - Border radius: 4px  
  - Border: 1px solid light gray  
  - Background: White  
  - Text color: Dark gray  
  - Font size: 14px, Medium  
  - Padding: 8px 16px  
  - Icon: Google logo (16x16)  
- **States**:
  - Default: White background  
  - Hover: Shadow/darker border  
  - Loading: Spinner, disabled  
  - Disabled: Gray when auth in progress  
- **Component ID**: `GoogleSignInButton`

### View All Link
- **Location**: Bottom of sidebar sections  
- **Description**: Link to view all items  
- **Properties**:
  - Text: "View All"  
  - Icon: Chevron right  
- **States**:
  - Default: normal text color  
  - Hover: slightly darker  
- **Component ID**: `ViewAllLink`

### Error Handling Components

#### Error Message
- **Location**: Various  
- **Description**: Displays error messages  
- **Properties**:
  - Message text (localized)  
  - Icon (optional)  
  - Action button (optional)  
- **Variants**:
  - Inline error (below form fields)  
  - Toast/snackbar (temporary)  
  - Dialog (critical issues)  
- **States**:
  - Default (error styling)  
  - With Action (button/link)  
- **Component ID**: `ErrorMessage`

#### Offline Indicator
- **Location**: Top of screen when offline  
- **Description**: Banner for offline status + retry option  
- **Properties**:
  - Message: "You are offline" or localized  
  - Retry Button: tries to reconnect  
- **States**:
  - Visible: if device is offline  
  - Hidden: if device is online  
- **Component ID**: `OfflineIndicator`

#### Loading State
- **Location**: Various  
- **Description**: Visual indicator of ongoing operations  
- **Variants**:
  - Button Loading  
  - Content Loading (overlay or skeleton)  
  - Full Screen Loading  
- **Properties**:
  - Size: small/medium/large  
  - Message: optional text  
- **Component ID**: `LoadingIndicator`

[↑ Back to Top](#eddie2-uiux-specifications)

## 2. Screen Map

### Main Screen
- **Purpose**: Container for all main functionality  
- **Structure**:
  - Top Bar: app title/logo/breadcrumb toggle  
  - Left Panel: Sidebar (when expanded)  
    - New Chat Button  
    - Recent Chats + View All  
    - Q&A Section + View All  
    - Settings Section  
  - Content Area: changes per selected section  
- **Screen ID**: `MainScreen`

### All Chats Screen
- **Purpose**: Shows all chats when user clicks "View All" in Recent Chats  
- **Structure**:
  - Header: "Recent Chats"  
  - List of all chats (most recent first)  
  - Each chat shows title, preview, delete button  
- **Screen ID**: `AllChatsScreen`

### All Q&A Pairs Screen
- **Purpose**: Shows all Q&A pairs ("View All" in Q&A Pairs)  
- **Structure**:
  - Header: "Q&A Pairs"  
  - List of all Q&A pairs  
  - Each item shows question, answer preview, delete button  
- **Screen ID**: `AllQAPairsScreen`

### Chat Screen
- **Purpose**: Primary interface for chatting with AI  
- **Structure**:
  - Left Panel: Sidebar (expanded or collapsed)  
  - Right Panel: Chat area  
    - Chat Header (breadcrumb: "Chat > [Chat Title]")  
    - Message List (User/Assistant bubbles)  
    - Empty State: "What can I help you learn?"  
    - Chat Input (text + file attach + send)  
- **Behavior**:
  - "New Chat" clears selection, shows empty state  
  - Actual chat created after first message  
  - Breadcrumb shows new chat title  
- **Screen ID**: `ChatScreen`

### Q&A Screen
- **Purpose**: Manage Q&A pairs  
- **Structure**:
  - Search Bar (search input + "Create Q&A" button)  
  - Q&A List (QAPairItem)  
  - Empty State if no pairs  
  - Header: breadcrumb "Q&A Pairs > [Question]" (when selected)  
- **Screen ID**: `QAScreen`

### Settings Screen
- **Purpose**: Configure the application  
- **Structure**:
  - Profile Section (when authenticated)  
    - Profile Pic, Display Name, etc.  
    - Delete Account, Logout  
  - API Key Section (APIKeyForm)  
  - Appearance Section (Dark Mode Toggle)  
  - Language Section (Dropdown)  
  - AI Model Section (Dropdown)  
  - About Section (version info, links)  
- **Screen ID**: `SettingsScreen`

### Authentication Screens

#### Login Screen (`LoginScreen`)
- **Location**: Shown if user not authenticated  
- **Description**: Email/pass login  
- **Components**:
  - AppLogo, Title, Email Field, Password Field, Forgot Password Link, Login Button, Sign Up Link  
- **States**:
  - Default (form)  
  - Loading (auth in progress)  
  - Error (invalid credentials)  
- **Enhanced Features**:
  - Clears existing auth state, detailed error messages, state refresh, Enter-key login  
- **Component ID**: `LoginScreen`

#### Signup Screen (`SignupScreen`)
- **Location**: From login screen  
- **Description**: Create account  
- **Components**:
  - AppLogo, Title, Name Field (optional), Email Field, Password Field, Confirm Password, Sign Up Button, Login Link  
- **States**:
  - Default (form)  
  - Loading  
  - Error (validation)  
- **Component ID**: `SignupScreen`

[↑ Back to Top](#eddie2-uiux-specifications)

## 3. Design System Reference

### Design Tokens

#### Color Tokens
| Token Name             | Light Mode  | Dark Mode  | Usage                                  |
|------------------------|------------|-----------|----------------------------------------|
| `colorPrimary`         | #000000    | #FFFFFF   | Primary actions, highlights            |
| `colorBackground`      | #F5F5F5    | #121212   | App background                         |
| `colorSurface`         | #FFFFFF    | #121212   | Cards, dialogs                         |
| `colorTextPrimary`     | #212121    | #FFFFFF   | Primary text                           |
| `colorTextSecondary`   | #757575    | #B0B0B0   | Secondary text                         |
| `colorError`           | #DC3545    | #FF453A   | Error states                           |
| `colorSuccess`         | #28A745    | #32D74B   | Success states                         |
| `colorWarning`         | #FFC107    | #FFD54F   | Warning states                         |
| `colorOutline`         | #E0E0E0    | #333333   | Borders, dividers                      |
| `colorInputBackground` | #F5F5F5    | #1A1A1A   | Input field backgrounds                |

*(See also [EDDIE_UIUX_DESIGN_SYSTEM.md](./EDDIE_UIUX_DESIGN_SYSTEM.md) if you want a deeper dive. The actual Dart implementations live in `eddie_colors.dart`.)*

#### Spacing Tokens
| Token Name      | Value | Usage                                           |
|-----------------|-------|-------------------------------------------------|
| `spacingXxs`    | 2px   | Minimal spacing between tightly related elements|
| `spacingXs`     | 4px   | Tight spacing                                   |
| `spacingSm`     | 8px   | Standard spacing                                |
| `spacingMd`     | 16px  | Standard padding                                |
| `spacingLg`     | 24px  | Section spacing                                 |
| `spacingXl`     | 32px  | Major section divisions                         |
| `spacingXxl`    | 48px  | Page-level spacing                              |

#### Typography Tokens
| Token Name       | Properties             | Usage                      |
|------------------|------------------------|----------------------------|
| `textHeading1`   | Inter, 24px, Bold     | Screen titles             |
| `textHeading2`   | Inter, 20px, Bold     | Section headings          |
| `textHeading3`   | Inter, 18px, SemiBold | Subsection headings       |
| `textBody1`      | Inter, 16px, Regular  | Primary content text      |
| `textBody2`      | Inter, 14px, Regular  | Secondary content text    |
| `textCaption`    | Inter, 12px, Regular  | Timestamps, helper text   |
| `textButtonText` | Inter, 16px, Medium   | Button labels             |
| `textInputLabel` | Inter, 14px, Medium   | Input field labels        |

#### Border Radius Tokens
| Token Name         | Value | Usage                                |
|--------------------|-------|--------------------------------------|
| `borderRadiusSmall`| 4px   | Buttons, small elements              |
| `borderRadiusMedium`| 8px  | Cards, input fields                  |
| `borderRadiusLarge`| 12px  | Larger components                    |
| `borderRadiusXl`   | 16px  | Modal dialogs                        |
| `borderRadiusRound`| 999px | Circular elements                    |

#### Animation Duration Tokens
| Token Name         | Value   | Usage                        |
|--------------------|---------|------------------------------|
| `animationShort`   | 150ms   | Quick transitions            |
| `animationMedium`  | 300ms   | Standard transitions         |
| `animationLong`    | 500ms   | More complex animations      |

*(For code implementations, see `eddie_constants.dart`, `eddie_text_styles.dart`, and `eddie_theme.dart`.)*

[↑ Back to Top](#eddie2-uiux-specifications)

## 4. Interaction Patterns

### Sidebar Interactions

#### Toggling Sidebar
1. User clicks toggle button or vertical divider  
2. Sidebar slides in/out  
3. Content area resizes  
4. If hidden, app title & logo appear in top bar

#### Creating a New Chat
1. User clicks "New Chat"  
2. Immediately shows an empty chat state; no chat record is created yet  
3. Once user sends first message, chat is officially created with that message as the title  
4. Chat becomes selected

#### Viewing All Chats
1. "View All" link in Recent Chats  
2. Main content → AllChatsScreen  
3. Displays full chat list

#### Creating a New Q&A Pair (Sidebar)
1. Click "+" in Q&A section  
2. Q&A Pair form opens  
3. Fill question/answer → Save  
4. New Q&A pair added

### Authentication Interactions

#### Logging In
1. Enter email/password  
2. Click Login → loading indicator  
3. On success, main screen loads  
4. On failure, error displayed

#### Signing Up
1. Enter email/password/etc.  
2. Click Sign Up → loading  
3. Success → email verification & success message  
4. Failure → error displayed

#### Deleting Account
1. Settings → "Delete Account"  
2. Confirmation dialog  
3. If confirm, loading → attempt delete  
4. Success → user is logged out  
5. Failure → error message

### Chat Interactions

#### Sending a Message
1. User types → send enabled  
2. On send, user message bubble appears  
3. Loading indicator while waiting for AI  
4. Assistant response bubble when ready

#### Attaching a File
1. Click attach → file picker  
2. Select file → name appears in input  
3. Send → file base64-encoded & sent  
4. If invalid or error, user sees error message

#### Saving Q&A Pairs
1. On assistant message, "Save as Q&A" button  
2. System tries to auto-detect Q&A pairs  
3. If found, auto-save + confirmation  
4. If not, user can manually create Q&A

### Q&A Interactions

#### Creating a Q&A Pair Manually
1. "Create Q&A Pair" → form opens  
2. Fill question/answer/tags → Save  
3. Appears in Q&A list

#### Searching Q&A Pairs
1. Type in search bar  
2. Real-time filtering  
3. "No matches found" if empty results

### Settings Interactions

#### Setting API Key
1. Enter key → Save  
2. If valid, success message; else error

#### Changing Language
1. Select language in dropdown  
2. UI strings switch instantly

#### Toggling Dark Mode
1. Click toggle  
2. Immediately applies theme

[↑ Back to Top](#eddie2-uiux-specifications)

## 5. User Flow Diagrams

### Chat Flow
┌─────────────┐ ┌─────────────┐ ┌─────────────┐ │ Start App │────▶│ Select Chat │────▶│ Type Message│ └─────────────┘ └─────────────┘ └──────┬──────┘ ▲ │ │ ▼ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ │ View Response│◀────│ AI Processes│◀────│ Send Message│ └──────┬──────┘ └─────────────┘ └─────────────┘ │ ▼ ┌─────────────┐ ┌─────────────┐ │ Save as Q&A │────▶│ Q&A Saved │ └─────────────┘ └─────────────┘

### Improved Chat Creation Flow
┌─────────────┐ ┌─────────────┐ ┌─────────────┐ │ Start App │────▶│ Click "New │────▶│ Empty Chat │ └─────────────┘ │ Chat" Button│ │ Screen │ └─────────────┘ └──────┬──────┘ │ ▼ ┌─────────────┐ ┌─────────────┐ │ Type Message│────▶│ Send Message│ └─────────────┘ └──────┬──────┘ │ ▼ ┌─────────────┐ │ New Chat │ │ Created │ └──────┬──────┘ │ ▼ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ │ View Response│◀────│ AI Processes│◀───────────────────────│ Breadcrumb │ └──────┬──────┘ └─────────────┘ │ Updated │ │ └─────────────┘ ▼ ┌─────────────┐ ┌─────────────┐ │ Save as Q&A │────▶│ Q&A Saved │ └─────────────┘ └─────────────┘

### Sidebar Toggle Flow
┌─────────────┐ ┌─────────────┐ ┌─────────────┐ │ View App │────▶│ Click Toggle│────▶│Sidebar Shows│ └─────────────┘ └─────────────┘ └──────┬──────┘ │ ▼ ┌─────────────┐ │Click Toggle │ │ Again │ └──────┬──────┘ │ ▼ ┌─────────────┐ │Sidebar Hides│ │App Title │ │Shows in Top │ └─────────────┘

[↑ Back to Top](#eddie2-uiux-specifications)

## 6. State Management Conventions

Eddie2 uses **Riverpod**.  

### Provider Types

- **State Notifier Providers** for complex state (chatProvider, qaPairProvider, settingsProvider, localeProvider, sidebarProvider).  
- **State Providers** for simple booleans/IDs (e.g., selectedChatIdProvider, isDarkModeProvider).

### State Flow

┌─────────────┐ ┌─────────────┐ ┌─────────────┐ │ User Action │────▶│State Provider│────▶│ UI Updates │ └─────────────┘ └──────┬──────┘ └─────────────┘ │ ▲ ▼ │ ┌─────────────┐ ┌─────────────┐ │ Business │────▶│ State │ │ Logic │ │ Changes │ └─────────────┘ └─────────────┘


### Update Patterns

- **UI-Triggered**: e.g., user toggles dark mode → triggers state notifier → updates UI  
- **API-Triggered**: e.g., user sends a chat → API response → updates chat state

[↑ Back to Top](#eddie2-uiux-specifications)

## 7. API Integration Points

### OpenAI API
- **Endpoint**: Chat Completions  
- **Method**: POST  
- **Request Data**: model, messages, temperature  
- **Response**: AI text in `choices[].message.content`  
- **UI**: `ChatInput`, `MessageBubble`  
- **Error Handling**: show error in assistant bubble

### File Uploads
- **Endpoint**: same (Chat Completions) but with file data base64  
- **Error Handling**: file size/format issues

### Q&A Detection
- **Endpoint**: Possibly same Chat Completion, instruct system to parse Q&A  
- **UI**: "Save as Q&A" button → auto-detect → fallback to manual creation

### Local Storage
- **SharedPreferences** for chat/Q&A data  
- **SecureStorage** for API key  
- **JSON** for data format

### Firebase Auth (Post-MVP or partial)
- **Email/password** flows  
- **Google Sign-In**  
- **Firestore** for user profiles

[↑ Back to Top](#eddie2-uiux-specifications)

## 8. Localization Guidelines

- **No Hardcoded Strings**: everything in ARB files  
- **Use placeholders** (e.g. `qaPairsDetected(count)`)  
- **Context** for translators in ARB comments  
- **Switching languages**: immediate UI update  
- **Test** for layout overflow/truncation

[↑ Back to Top](#eddie2-uiux-specifications)

## 9. Responsive Behavior

- **Mobile**: bottom nav, single column  
- **Tablet**: toggleable sidebar, 2-column chat layout  
- **Desktop**: full sidebar, comfortable spacing  
- **Breakpoints**: <600 (mobile), 600–1200 (tablet), >1200 (desktop)

[↑ Back to Top](#eddie2-uiux-specifications)

## 10. Accessibility Standards

- **Keyboard Accessibility** for all interactive elements  
- **Min touch target** 44x44px  
- **Color contrast** ratio >= 4.5:1  
- **Alt text** for images  
- **Semantic** heading levels, aria labels, logical tab order

[↑ Back to Top](#eddie2-uiux-specifications)

## 11. Error Handling

### Error Types
- **API Errors**: issues w/OpenAI  
- **Validation Errors**: user input  
- **Network Errors**: offline/timeouts  
- **File Errors**: invalid/oversize attachments  
- **Auth Errors**: login, signup, or account mgmt  
- **Database Errors**: Firestore ops

### Error Display
- **Snackbars**, **dialogs**, **inline errors**  
- Should be **clear & user-friendly**  
- Provide **retry** if possible  
- **Fallback** if service unavailable

[↑ Back to Top](#eddie2-uiux-specifications)

## 12. Empty States

- **Chat Empty State**: "What can I help you learn?"  
- **No Q&A**: message that no pairs exist  
- **No search results**: "No matches found"

[↑ Back to Top](#eddie2-uiux-specifications)

## 13. Loading States

- **Spinner** for short ops  
- **Progress bar** for longer ops  
- **Skeleton screens** for initial content  
- **Three bouncing dots** for chat

[↑ Back to Top](#eddie2-uiux-specifications)

## 14. Animation & Transition Guidelines

- **Timing**: 150ms for quick, 200ms standard, 300–500ms complex  
- **Easing**: ease-in-out typically, ease-out for acceleration, ease-in for deceleration  
- **Specific**: Slide for navigation, fade/scale for dialogs, etc.

[↑ Back to Top](#eddie2-uiux-specifications)

## 15. Testing & QA Guidelines

- **Responsive Testing** across breakpoints  
- **Accessibility**: keyboard nav, screen readers, contrast checks  
- **Localization**: switch languages, check text overflow  
- **State Testing**: empty/loading/error states  
- **Animations**: consistent, not too jarring  
- **Acceptance Criteria**: matches design specs, works across devices, handles states, is localized, is accessible, smooth animations

### Profile Management Components
- ProfilePictureComponent: circular avatar, upload, error states  
- ProfileForm: name/username, validation, saving states

[↑ Back to Top](#eddie2-uiux-specifications)

## 16. Admin Tools

### User Management
- Admin tools for user data in Firestore  
- CLI scripts to delete users  
- Access control for administrators

### Error Handling in Admin Tools
- Confirmations before destructive ops  
- Logging + rollback if needed

### Admin Tool Docs
- See `tools/README.md` for usage examples, security guidelines, troubleshooting

[↑ Back to Top](#eddie2-uiux-specifications)

**End of EDDIE_UIUX_SPEC_MAIN.md**
