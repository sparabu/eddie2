# Eddie2 UI/UX Specifications

This document defines the UI components, screens, design system, and interaction patterns for the Eddie2 application. It serves as a reference for maintaining UI consistency and improving communication between team members.

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
  - Color: Very dark gray (almost black) in dark mode, light gray in light mode
- **Behavior**:
  - When clicked, toggles the sidebar between expanded and collapsed states
  - Shows a resize cursor on hover to indicate it's interactive
- **Component ID**: `SidebarDivider`

#### Top App Bar
- **Location**: Top of the screen
- **Description**: Contains app title, logo, and sidebar toggle
- **Elements**:
  - Sidebar toggle button: Shows/hides the sidebar
  - App logo: Eddie2 logo
  - Breadcrumb navigation: Shows current section and selected item
    - Primary section: "Chat" or "Q&A Pairs"
    - Chevron separator: ">"
    - Selected item: Chat title or Q&A question
  - App title: "Eddie2" text (shown when no breadcrumb is active)
- **Variants**:
  - Default: Shows app title only
  - Chat selected: Shows "Chat > [Chat Title]"
  - Q&A selected: Shows "Q&A Pairs > [Question]"
  - View All: Shows "Chat > View All" or "Q&A Pairs > View All"
- **Component ID**: `TopAppBar`

#### Sidebar Section
- **Location**: Within sidebar
- **Description**: Collapsible section for organizing sidebar content
- **Properties**:
  - Title: Section name (e.g., "Recent Chats", "Q&A Pairs")
  - Icon: Visual indicator for the section (optional, used only for Settings)
  - Children: List of items in the section
  - Add button: Optional button to add new items (used only for Q&A section)
  - View All link: Optional link to show all items in the main content area
- **States**:
  - Expanded: Shows all children
  - Collapsed: Shows only the header
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
  - Title: Shows chat title (default "New Chat" or localized equivalent)
  - Delete button: Removes the chat
- **States**:
  - Selected: Highlighted with primary color
  - Unselected: Regular background
- **Component ID**: `ChatListItem`
- **Updated Design**:
  - Simplified to show only the chat title in a single row
  - Reduced vertical spacing for better space utilization
  - Enhanced readability for quick navigation
  - Optimized appearance for displaying more chats in the sidebar

#### Message Bubble
- **Location**: Chat area
- **Description**: Container for individual messages
- **Variants**:
  - User Message: Right-aligned, primary color background
  - Assistant Message: Left-aligned, neutral background
- **Properties**:
  - Message content: Text of the message
  - Timestamp: When the message was sent
  - "Save as Q&A" button: Only on assistant messages
- **Component ID**: `MessageBubble`

#### Chat Input
- **Location**: Bottom of chat area
- **Description**: Input field for typing messages
- **Elements**:
  - Text field: For typing messages with placeholder "Ask Eddie to create..."
  - Attach File button: For uploading files
  - Send button: For sending messages
- **States**:
  - Empty: Send button disabled
  - With text: Send button enabled
  - Loading: Shows loading indicator
- **Component ID**: `ChatInput`

### Q&A Components

#### Q&A Pair Item
- **Location**: Q&A screen
- **Description**: Container for a question-answer pair
- **Properties**:
  - Question: The question text
  - Answer: The answer text
  - Tags: Associated tags (if any)
  - Edit button: Opens edit dialog
  - Delete button: Removes the pair
- **Component ID**: `QAPairItem`

#### Q&A Pair Form
- **Location**: Dialog
- **Description**: Form for creating or editing Q&A pairs
- **Fields**:
  - Question field
  - Answer field
  - Tags field
- **Buttons**:
  - Save button
  - Cancel button
- **Component ID**: `QAPairForm`

#### Q&A Search Bar
- **Location**: Top of Q&A screen
- **Description**: Search input with create button
- **Elements**:
  - Search field: For filtering Q&A pairs
  - Create Q&A button: Opens the Q&A Pair Form
- **Component ID**: `QASearchBar`

### Settings Components

#### API Key Form
- **Location**: Settings screen
- **Description**: Form for managing OpenAI API key
- **Elements**:
  - API key field: For entering the API key
  - Save button: Saves the API key
  - Delete button: Removes the API key
- **States**:
  - Empty: Shows helper text
  - With API key: Shows masked key
  - Error: Shows validation error
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
- **Description**: Button to permanently delete the user's account
- **Properties**:
  - Icon: Delete forever icon (red)
  - Text: "Delete Account"
  - Subtitle: Explains the consequences of account deletion
- **States**:
  - Default: Clickable button
  - Loading: Shows loading indicator while processing deletion
  - Disabled: When deletion is in progress
- **Component ID**: `DeleteAccountButton`

#### Confirmation Dialog
- **Location**: Modal overlay
- **Description**: Dialog to confirm destructive actions like account deletion
- **Elements**:
  - Title: Action being confirmed (e.g., "Delete Account")
  - Content: Description of consequences
  - Cancel button: Dismisses dialog without action
  - Confirm button: Proceeds with the action (styled in red for destructive actions)
- **Component ID**: `ConfirmationDialog`

#### Enhanced Sign Up Link
- **Location**: Bottom of login screen
- **Description**: Button-like link that navigates to the signup screen
- **Properties**:
  - Text: "Sign Up" (localized)
  - Font Size: 16px
  - Font Weight: Bold
  - Padding: 8px vertical, 16px horizontal
  - Border Radius: 8px
- **States**:
  - Dark Mode: 
    - Text Color: White
    - Background: Primary color with 30% opacity
    - Border: 1.5px primary color
  - Light Mode:
    - Text Color: Primary color
    - Background: None
    - Border: None
  - Disabled: When login is in progress
- **Component ID**: `EnhancedSignUpLink`

#### Google Sign-In Button
- **Location**: Login and Signup screens
- **Description**: Button for authenticating with Google credentials
- **Properties**:
  - Height: 40px
  - Border Radius: 4px
  - Border: 1px solid light gray
  - Background: White
  - Text Color: Dark gray
  - Font Size: 14px
  - Font Weight: Medium
  - Padding: 8px 16px
  - Icon: Google logo SVG (16x16px)
  - Icon Spacing: 8px from text
- **States**:
  - Default: White background with Google logo and text
  - Hover: Slight shadow and darker border
  - Loading: Shows loading indicator, button disabled
  - Disabled: Grayed out when authentication is in progress
- **Component ID**: `GoogleSignInButton`

### View All Link
- **Location**: Bottom of sidebar sections
- **Description**: Link to view all items in a section
- **Properties**:
  - Text: "View All" (localized)
  - Icon: Chevron right
- **States**:
  - Default: Regular text color
  - Hover: Slightly darker text color
- **Component ID**: `ViewAllLink`

### Error Handling Components

#### Error Message
- **Location**: Various locations throughout the application
- **Description**: Displays error messages to users in a clear, concise manner
- **Properties**:
  - Message: The error text (always localized)
  - Icon: Visual indicator of error type (optional)
  - Action: Button or link to resolve the error (optional)
- **Variants**:
  - Inline Error: Displayed directly beneath form fields
  - Toast/Snackbar: Temporary notification at the bottom of the screen
  - Dialog: Modal error for critical issues requiring acknowledgment
- **States**:
  - Default: Displayed with error styling
  - With Action: Includes actionable button or link
- **Component ID**: `ErrorMessage`

#### Offline Indicator
- **Location**: Top of screen when network connectivity is lost
- **Description**: Banner indicating offline status with retry options
- **Properties**:
  - Message: "You are offline" or similar text (localized)
  - Retry Button: Attempts to reconnect or retry failed operations
- **States**:
  - Visible: When device is offline
  - Hidden: When device is online
- **Component ID**: `OfflineIndicator`

#### Loading State
- **Location**: Various locations throughout the application
- **Description**: Visual indicator of ongoing operations
- **Variants**:
  - Button Loading: Replaces button text with spinner
  - Content Loading: Overlay or skeleton UI for content areas
  - Full Screen Loading: Covers entire screen for initial loading
- **Properties**:
  - Size: Small, medium, or large
  - Message: Optional text explaining the operation
- **Component ID**: `LoadingIndicator`

## 2. Screen Map

### Main Screen
- **Purpose**: Container for all main functionality
- **Structure**:
  - Top Bar: App title, logo, and sidebar toggle
  - Left Panel: Sidebar (when expanded)
    - New Chat Button
    - Recent Chats Section (5 most recent chats)
    - View All link for Recent Chats
    - Q&A Section
    - View All link for Q&A Pairs
    - Settings Section
  - Content Area: Changes based on selected section
- **Screen ID**: `MainScreen`

### All Chats Screen
- **Purpose**: Display all chats when "View All" is clicked in Recent Chats section
- **Structure**:
  - Header: "Recent Chats" title
  - List of all chats sorted by most recent first
  - Each chat item shows title, preview, and delete button
- **Screen ID**: `AllChatsScreen`

### All Q&A Pairs Screen
- **Purpose**: Display all Q&A pairs when "View All" is clicked in Q&A Pairs section
- **Structure**:
  - Header: "Q&A Pairs" title
  - List of all Q&A pairs
  - Each Q&A pair item shows question, preview of answer, and delete button
- **Screen ID**: `AllQAPairsScreen`

### Chat Screen
- **Purpose**: Primary interface for chatting with AI
- **Structure**:
  - Left Panel: Sidebar (when expanded)
    - Chat Section
      - New Chat Button
      - Chat List Items
    - Q&A Section
    - Settings Section
  - Right Panel: Chat Area
    - Chat Header
      - Breadcrumb Navigation showing "Chat > [Chat Title]"
    - Message List
      - User Message Bubbles
      - Assistant Message Bubbles
    - Empty State: Large welcome message "What can I help you learn?"
    - Chat Input Area
      - Message Input Field with placeholder "Ask Eddie to create..."
      - Attach File Button
      - Send Button
- **Behavior**:
  - Clicking "New Chat" button clears the current chat selection and shows the empty state
  - A new chat is only created after the user submits their first message
  - The first message becomes the title of the new chat
  - The breadcrumb navigation updates to show the current chat title
- **Screen ID**: `ChatScreen`

### Q&A Screen
- **Purpose**: Interface for managing Q&A pairs
- **Structure**:
  - Search Bar
    - Search Input
    - Create Q&A Button
  - Q&A List
    - Q&A Pair Items
  - Empty State (when no pairs exist)
  - Header
    - Breadcrumb Navigation showing "Q&A Pairs > [Question]" when a Q&A pair is selected
- **Behavior**:
  - When a Q&A pair is selected, the breadcrumb navigation updates to show the question
  - When viewing all Q&A pairs, the breadcrumb shows "Q&A Pairs > View All"
- **Screen ID**: `QAScreen`

### Settings Screen
- **Purpose**: Interface for configuring the application
- **Structure**:
  - Profile Section (when authenticated)
    - Profile Picture with Upload Button
    - Display Name Field
    - Username Field
    - Email Display (read-only)
    - Email Verification Status
    - Save Changes Button
    - Delete Account Button
    - Logout Button
  - API Key Section
    - API Key Form
  - Appearance Section
    - Dark Mode Toggle
  - Language Section
    - Language Dropdown
  - AI Model Section
    - Model Dropdown
  - About Section
    - Version Information
    - Source Code Link
    - Report Issue Link
- **Screen ID**: `SettingsScreen`

### Authentication Screens

#### Login Screen (LoginScreen)
- **Location**: Displayed when the user is not authenticated
- **Description**: Allows users to log in with email and password
- **Components**:
  - **AppLogo**: Displays the Eddie logo at the top
  - **Title**: "Login to Eddie" text
  - **Email Field**: Input field for email with validation
  - **Password Field**: Secure input field for password
  - **Forgot Password Link**: Link to reset password
  - **Login Button**: Primary button to submit credentials
  - **Sign Up Link**: Enhanced button-like link to navigate to the signup screen
    - Dark Mode: White text on semi-transparent primary color background with primary color border
    - Light Mode: Primary color text with no background
- **States**:
  - **Default**: Shows the login form
  - **Loading**: Shows a loading indicator while authenticating
  - **Error**: Displays error messages for invalid credentials
- **Component ID**: `LoginScreen`
- **Enhanced Features**:
  - **Improved Authentication Flow**: Clears existing auth state before login
  - **Detailed Error Handling**: Shows specific error messages for different authentication issues
  - **State Refresh**: Forces auth state refresh after successful login
  - **Enter Key Support**: Pressing Enter in the password field triggers login
  - **Keyboard Navigation**: Tab and Enter keys can be used to navigate the form

#### Signup Screen (SignupScreen)
- **Location**: Accessed from the login screen
- **Description**: Allows users to create a new account
- **Components**:
  - **AppLogo**: Displays the Eddie logo at the top
  - **Title**: "Create Account" text
  - **Name Field**: Optional input for display name
  - **Email Field**: Input field for email with validation
  - **Password Field**: Secure input field for password with strength requirements
  - **Confirm Password Field**: Field to confirm password with matching validation
  - **Sign Up Button**: Primary button to create account
  - **Login Link**: Link to navigate back to login screen
- **States**:
  - **Default**: Shows the signup form
  - **Loading**: Shows a loading indicator while creating account
  - **Error**: Displays error messages for validation issues or existing email
- **Component ID**: `SignupScreen`

## 3. Design System Reference

### Design Tokens

#### Color Tokens
| Token Name | Light Mode | Dark Mode | Usage |
|------------|------------|-----------|-------|
| `colorPrimary` | #000000 | #FFFFFF | Primary actions, highlights |
| `colorBackground` | #F5F5F5 | #121212 | App background |
| `colorSurface` | #FFFFFF | #121212 | Cards, dialogs |
| `colorTextPrimary` | #212121 | #FFFFFF | Primary text |
| `colorTextSecondary` | #757575 | #B0B0B0 | Secondary text |
| `colorError` | #DC3545 | #FF453A | Error states |
| `colorSuccess` | #28A745 | #32D74B | Success states |
| `colorWarning` | #FFC107 | #FFD54F | Warning states |
| `colorOutline` | #E0E0E0 | #333333 | Borders, dividers |
| `colorInputBackground` | #F5F5F5 | #1A1A1A | Input field backgrounds |

#### Spacing Tokens
| Token Name | Value | Usage |
|------------|-------|-------|
| `spacingXxs` | 2px | Minimal spacing between tightly related elements |
| `spacingXs` | 4px | Tight spacing between related elements |
| `spacingSm` | 8px | Standard spacing between related elements |
| `spacingMd` | 16px | Standard padding, spacing between components |
| `spacingLg` | 24px | Section spacing |
| `spacingXl` | 32px | Major section divisions |
| `spacingXxl` | 48px | Page-level spacing |

#### Typography Tokens
| Token Name | Properties | Usage |
|------------|------------|-------|
| `textHeading1` | Inter, 24px, Bold | Screen titles |
| `textHeading2` | Inter, 20px, Bold | Section headings |
| `textHeading3` | Inter, 18px, SemiBold | Subsection headings |
| `textBody1` | Inter, 16px, Regular | Primary content text |
| `textBody2` | Inter, 14px, Regular | Secondary content text |
| `textCaption` | Inter, 12px, Regular | Timestamps, helper text |
| `textButtonText` | Inter, 16px, Medium | Button labels |
| `textInputLabel` | Inter, 14px, Medium | Input field labels |

#### Border Radius Tokens
| Token Name | Value | Usage |
|------------|-------|-------|
| `borderRadiusSmall` | 4px | Small elements, buttons |
| `borderRadiusMedium` | 8px | Cards, input fields |
| `borderRadiusLarge` | 12px | Large components |
| `borderRadiusXl` | 16px | Modal dialogs |
| `borderRadiusRound` | 999px | Circular elements |

#### Animation Duration Tokens
| Token Name | Value | Usage |
|------------|-------|-------|
| `animationShort` | 150ms | Quick transitions (hover states) |
| `animationMedium` | 300ms | Standard transitions (page changes) |
| `animationLong` | 500ms | Complex animations (modals) |

### Design System Components

#### EddieColors
The primary source of truth for all color definitions and color-related functionality in the application.

**Key Features**:
- Helper methods for accessing theme-aware colors (e.g., `getPrimary(context)`)
- Semantic color definitions for different UI states
- Support for both light and dark themes

**Usage Example**:
```dart
// Get the primary color based on the current theme
color: EddieColors.getPrimary(context)

// Get the appropriate background color
backgroundColor: EddieColors.getBackground(context)
```

#### EddieTextStyles
Contains all text style definitions and helper methods for accessing theme-aware text styles.

**Key Features**:
- Uses Google Fonts (Inter) for consistent typography
- Helper methods for accessing theme-aware text styles
- Includes styles for headings, body text, buttons, and more

**Usage Example**:
```dart
// Apply heading style
style: EddieTextStyles.heading1(context)

// Apply body text style
style: EddieTextStyles.body1(context)
```

#### EddieConstants
Provides standardized values for spacing, sizing, animations, and other constants used throughout the application.

**Key Features**:
- Spacing constants for consistent layout
- Border radius constants for consistent corner rounding
- Animation duration constants for consistent timing
- Elevation constants for shadows and depth

**Usage Example**:
```dart
// Apply consistent padding
padding: EdgeInsets.all(EddieConstants.spacingMd)

// Use standard animation duration
duration: EddieConstants.animationMedium
```

#### Custom Components

##### EddieButton
A customizable button component with multiple variants and sizes.

**Properties**:
- `text`: Button label text
- `onPressed`: Callback function when button is pressed
- `variant`: Button style variant (primary, secondary, danger)
- `size`: Button size (small, medium, large)
- `isLoading`: Whether to show loading indicator
- `leadingIcon`: Optional icon before text
- `trailingIcon`: Optional icon after text

**Usage Example**:
```dart
EddieButton(
  text: 'Submit',
  onPressed: handleSubmit,
  variant: EddieButtonVariant.primary,
  size: EddieButtonSize.medium,
)
```

##### EddieTextField
A styled text input field component.

**Properties**:
- `label`: Field label text
- `placeholder`: Placeholder text
- `controller`: Text editing controller
- `errorText`: Optional error message
- `helperText`: Optional helper text
- `obscureText`: Whether to hide text (for passwords)
- `keyboardType`: Type of keyboard to display

**Usage Example**:
```dart
EddieTextField(
  label: 'Email',
  placeholder: 'Enter your email',
  controller: emailController,
  keyboardType: TextInputType.emailAddress,
)
```

##### SidebarSection
A collapsible section component for organizing sidebar content.

**Properties**:
- `title`: Section title text
- `children`: List of widgets to display in the section
- `trailing`: Optional widget to display at the end of the header
- `isExpanded`: Whether the section is expanded
- `onToggle`: Callback function when toggle is pressed

**Usage Example**:
```dart
SidebarSection(
  title: 'Recent Chats',
  children: chatItems,
  trailing: addButton,
)
```

##### SidebarItem
An individual item component for sidebar lists.

**Properties**:
- `title`: Item title text
- `subtitle`: Optional subtitle text
- `icon`: Optional leading icon
- `isSelected`: Whether the item is selected
- `onTap`: Callback function when item is tapped
- `showTrailing`: Whether to show trailing delete button
- `onDelete`: Callback function when delete button is pressed

**Usage Example**:
```dart
SidebarItem(
  title: 'Chat Title',
  icon: Icons.chat_bubble_outline,
  isSelected: isSelected,
  onTap: () => selectChat(chatId),
)
```

### Colors

#### Primary Colors
- **Primary (Light Mode)**: #000000 (Black)
  - Used for: buttons, selected items, highlights
- **Primary (Dark Mode)**: #FFFFFF (White)
  - Used for: buttons, selected items, highlights

#### UI Colors
- **Background (Light Mode)**: #F5F5F5
- **Background (Dark Mode)**: #121212
- **Surface (Light Mode)**: #FFFFFF
- **Surface (Dark Mode)**: #121212
- **Text Primary (Light Mode)**: #000000
- **Text Primary (Dark Mode)**: #FFFFFF
- **Text Secondary (Light Mode)**: #757575
- **Text Secondary (Dark Mode)**: #B0B0B0

#### Semantic Colors
- **Error (Light Mode)**: #DC3545
- **Error (Dark Mode)**: #FF453A
- **Success (Light Mode)**: #28A745
- **Success (Dark Mode)**: #32D74B
- **Warning (Light Mode)**: #FFC107
- **Warning (Dark Mode)**: #FFD54F

### Typography

#### Text Styles
- **Heading 1**: Inter, 24px, Bold
  - Used for: Screen titles
- **Heading 2**: Inter, 20px, Bold
  - Used for: Section headings
- **Heading 3**: Inter, 18px, SemiBold
  - Used for: Subsection headings
- **Body 1**: Inter, 16px, Regular
  - Used for: Primary content text
- **Body 2**: Inter, 14px, Regular
  - Used for: Secondary content text
- **Caption**: Inter, 12px, Regular
  - Used for: Timestamps, helper text
- **Button Text**: Inter, 16px, Medium
  - Used for: Button labels
- **Input Label**: Inter, 14px, Medium
  - Used for: Input field labels

### Spacing

#### Standard Spacing
- **Extra Extra Small**: 2px
  - Used for: Minimal spacing between tightly related elements
- **Extra Small**: 4px
  - Used for: Tight spacing between related elements
- **Small**: 8px
  - Used for: Standard spacing between related elements
- **Medium**: 16px
  - Used for: Standard padding, spacing between components
- **Large**: 24px
  - Used for: Section spacing
- **Extra Large**: 32px
  - Used for: Major section divisions
- **Extra Extra Large**: 48px
  - Used for: Page-level spacing

### Component Styles

#### Cards
- **Border Radius**: 8px
- **Elevation (Light Mode)**: 1dp shadow
- **Elevation (Dark Mode)**: Subtle border or contrast change
- **Padding**: 24px

#### Buttons
- **Primary Button**:
  - Background: Primary color
  - Text: White
  - Border Radius: 4px
  - Padding: 8px 16px
- **Outlined Button**:
  - Background: Transparent
  - Border: 1px solid Primary color
  - Text: Primary color
  - Border Radius: 4px
  - Padding: 8px 16px
- **Text Button**:
  - Background: Transparent
  - Text: Primary color
  - Padding: 8px 16px
- **Icon Button**:
  - Size: 40px x 40px
  - Border Radius: 20px (circular)
- **Danger Button**:
  - Background: Danger color
  - Text: White
  - Border Radius: 4px
  - Padding: 8px 16px

#### Input Fields
- **Border**: 1px solid (Light: #E0E0E0, Dark: #424242)
- **Border Radius**: 4px
- **Padding**: 16px
- **Focus State**: Primary color border

## 4. Interaction Patterns

### Sidebar Interactions

#### Toggling Sidebar
1. User clicks sidebar toggle button in top-left corner or the vertical divider bar
2. Sidebar slides in or out of view
3. Content area adjusts to fill available space
4. App title and logo appear in top bar when sidebar is hidden

#### Creating a New Chat
1. User clicks "New Chat" button in sidebar
2. System creates a new chat with default title "New Chat" (or localized equivalent)
3. Chat input becomes active for first message
4. New chat is selected automatically

#### Creating a New Q&A Pair from Sidebar
1. User clicks "+" button in Q&A section of sidebar
2. Q&A Pair form dialog opens
3. User fills in question and answer fields
4. User clicks Save button
5. New Q&A pair appears in list

#### Viewing All Chats
1. User clicks "View All" link in Recent Chats section
2. Main content area changes to show All Chats Screen
3. All chats are displayed in a list, sorted by most recent first
4. User can select a chat to view or delete chats from this screen

#### Viewing All Q&A Pairs
1. User clicks "View All" link in Q&A Pairs section
2. Main content area changes to show All Q&A Pairs Screen
3. All Q&A pairs are displayed in a list
4. User can select a Q&A pair to view or delete Q&A pairs from this screen

### Authentication Interactions

#### Logging In
1. User enters email and password
2. User clicks Login button
3. Loading indicator appears on button
4. System attempts to authenticate user
5. If successful, user is redirected to main screen
6. If unsuccessful, error message is displayed

#### Signing Up
1. User enters email, password, and optional display name
2. User clicks Sign Up button
3. Loading indicator appears on button
4. System attempts to create account
5. If successful, verification email is sent and success message is displayed
6. If unsuccessful, error message is displayed

#### Deleting Account
1. User navigates to Settings screen
2. User clicks "Delete Account" button in Authentication section
3. Confirmation dialog appears with warning about permanent data loss
4. If user confirms, loading indicator appears
5. System attempts to delete account
6. If successful, user is logged out and redirected to login screen
7. If unsuccessful, error message is displayed
8. For Firestore permission issues, appropriate error message is shown with retry option
9. Detailed logs are generated for troubleshooting purposes
10. If the error is due to requiring recent login, user is prompted to sign out and sign in again

#### Google Sign-In
1. User clicks "Sign in with Google" or "Sign up with Google" button
2. Loading indicator appears on button
3. Google authentication popup opens
4. User selects Google account and grants permissions
5. Popup closes and system processes authentication
6. If successful, user is redirected to main screen
7. If unsuccessful, error message is displayed
8. If offline, system shows appropriate error message and retry options

#### Sign-Out Process
1. User clicks "Logout" button in Settings screen
2. Loading indicator appears on button
3. System attempts to sign out from Google (if applicable)
4. System signs out from Firebase Authentication
5. All local authentication state is cleared
6. User is redirected to login screen
7. If unsuccessful, error message is displayed with retry option
8. Detailed logs are generated for troubleshooting purposes

### Chat Interactions

#### Sending a Message
1. User types message in chat input
2. Send button becomes enabled
3. User clicks Send button (or presses Enter)
4. Message appears in chat as user message
5. Loading indicator appears
6. Assistant response appears when ready

#### Attaching a File
1. User clicks Attach File button
2. File picker dialog opens
3. User selects a file
4. File name appears in chat input
5. User can add optional message text
6. User sends message with file
7. File is processed by AI

#### Saving Q&A Pairs
1. User clicks "Save as Q&A" button on assistant message
2. System attempts to detect Q&A pairs
3. If pairs found: System saves and shows confirmation snackbar
4. If no pairs found: System shows dialog with manual creation option

### Q&A Interactions

#### Creating a Q&A Pair Manually
1. User clicks "Create Q&A Pair" button in search bar
2. Q&A Pair form dialog opens
3. User fills in question and answer fields
4. User adds optional tags
5. User clicks Save button
6. New Q&A pair appears in list

#### Searching Q&A Pairs
1. User types in search field
2. List filters in real-time to show matching pairs
3. If no matches, "No matches found" message appears

### Settings Interactions

#### Setting API Key
1. User enters API key in field
2. User clicks Save button
3. System validates API key format
4. If valid: System saves key and shows confirmation
5. If invalid: System shows validation error

#### Changing Language
1. User selects language from dropdown
2. System immediately applies language change
3. All UI text updates to selected language

#### Toggling Dark Mode
1. User clicks Dark Mode toggle
2. System immediately applies theme change
3. UI updates to show dark/light theme

## 5. User Flow Diagrams

### Chat Flow
```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Start App  │────▶│ Select Chat │────▶│ Type Message│
└─────────────┘     └─────────────┘     └──────┬──────┘
                          ▲                    │
                          │                    ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ View Response│◀────│ AI Processes│◀────│ Send Message│
└──────┬──────┘     └─────────────┘     └─────────────┘
       │
       ▼
┌─────────────┐     ┌─────────────┐
│ Save as Q&A │────▶│  Q&A Saved  │
└─────────────┘     └─────────────┘
```

### Improved Chat Creation Flow
```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Start App  │────▶│ Click "New  │────▶│ Empty Chat  │
└─────────────┘     │ Chat" Button│     │ Screen      │
                    └─────────────┘     └──────┬──────┘
                                                │
                                                ▼
                                        ┌─────────────┐     ┌─────────────┐
                                        │ Type Message│────▶│ Send Message│
                                        └─────────────┘     └──────┬──────┘
                                                                   │
                                                                   ▼
                                                           ┌─────────────┐
                                                           │ New Chat    │
                                                           │ Created     │
                                                           └──────┬──────┘
                                                                   │
                                                                   ▼
┌─────────────┐     ┌─────────────┐                        ┌─────────────┐
│ View Response│◀────│ AI Processes│◀───────────────────────│ Breadcrumb  │
└──────┬──────┘     └─────────────┘                        │ Updated     │
       │                                                    └─────────────┘
       ▼
┌─────────────┐     ┌─────────────┐
│ Save as Q&A │────▶│  Q&A Saved  │
└─────────────┘     └─────────────┘
```

### Sidebar Toggle Flow
```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  View App   │────▶│ Click Toggle│────▶│Sidebar Shows│
└─────────────┘     └─────────────┘     └──────┬──────┘
                                                │
                                                ▼
                                        ┌─────────────┐
                                        │Click Toggle │
                                        │ Again       │
                                        └──────┬──────┘
                                                │
                                                ▼
                                        ┌─────────────┐
                                        │Sidebar Hides│
                                        │App Title    │
                                        │Shows in Top │
                                        └─────────────┘
```

### API Key Setup Flow
```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Start App  │────▶│ Go to Settings│───▶│ Enter API Key│
└─────────────┘     └─────────────┘     └──────┬──────┘
                                                │
                                                ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ Start Chatting│◀───│Success Message│◀───│ Save API Key│
└─────────────┘     └─────────────┘     └─────────────┘
                                                │
                                                ▼
                                        ┌─────────────┐
                                        │ Invalid Key │
                                        │ Error Message│
                                        └─────────────┘
```

### Language Change Flow
```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ Go to Settings│───▶│Select Language│───▶│ UI Updates  │
└─────────────┘     └──────┬──────┘     └──────┬──────┘
                           │                    │
                           ▼                    ▼
                    ┌─────────────┐     ┌─────────────┐
                    │ Locale Saved │     │ AI Responses│
                    │ to Preferences│     │ in New Lang │
                    └─────────────┘     └─────────────┘
```

## 6. State Management Conventions

Eddie2 uses Riverpod for state management. The following conventions are used:

### Provider Types

#### State Notifier Providers
Used for complex state that requires multiple operations:
- `chatProvider`: Manages the list of chats
- `qaPairProvider`: Manages the list of Q&A pairs
- `settingsProvider`: Manages app settings
- `localeProvider`: Manages the app's locale
- `sidebarProvider`: Manages sidebar visibility state

#### State Providers
Used for simple state:
- `selectedChatIdProvider`: Tracks the currently selected chat
- `isDarkModeProvider`: Tracks the dark mode setting
- `isSidebarVisibleProvider`: Tracks whether the sidebar is visible

### State Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ User Action │────▶│State Provider│────▶│ UI Updates  │
└─────────────┘     └──────┬──────┘     └─────────────┘
                           │                    ▲
                           ▼                    │
                    ┌─────────────┐     ┌─────────────┐
                    │ Business    │────▶│ State       │
                    │ Logic       │     │ Changes     │
                    └─────────────┘     └─────────────┘
```

### State Update Patterns

#### UI-Triggered Updates
1. User interacts with UI (e.g., toggles dark mode)
2. UI calls state notifier method (e.g., `toggleDarkMode()`)
3. State notifier updates state
4. UI rebuilds with new state

#### API-Triggered Updates
1. API call is made (e.g., sending a message)
2. Response is received
3. State notifier updates state (e.g., adds new message to chat)
4. UI rebuilds with new state

## 7. API Integration Points

### OpenAI API Integration

#### Chat Messages
- **Endpoint**: OpenAI Chat Completions API
- **Method**: POST
- **Request Data**:
  ```json
  {
    "model": "[selected model]",
    "messages": [
      {"role": "system", "content": "You are a helpful assistant..."},
      {"role": "user", "content": "User message"},
      {"role": "assistant", "content": "Assistant response"}
    ],
    "temperature": 0.7
  }
  ```
- **Response Data**:
  ```json
  {
    "choices": [
      {
        "message": {
          "role": "assistant",
          "content": "AI response text"
        }
      }
    ]
  }
  ```
- **UI Components**: `ChatInput`, `MessageBubble`
- **Loading State**: Three bouncing dots in chat area
- **Error Handling**: Error message in chat as assistant message

#### File Uploads
- **Endpoint**: OpenAI Chat Completions API with file attachment
- **Method**: POST
- **Request Data**:
  ```json
  {
    "model": "[selected model]",
    "messages": [
      {"role": "system", "content": "You are a helpful assistant..."},
      {"role": "user", "content": "User message with file"},
      {"role": "assistant", "content": "Assistant response"}
    ],
    "temperature": 0.7
  }
  ```
- **File Data**: Base64-encoded file content
- **UI Components**: `ChatInput` with file attachment
- **Loading State**: Progress indicator in chat input
- **Error Handling**: Error message for file size or format issues

#### Q&A Pair Detection
- **Endpoint**: OpenAI Chat Completions API
- **Method**: POST
- **Request Data**:
  ```json
  {
    "model": "[selected model]",
    "messages": [
      {
        "role": "system", 
        "content": "Extract Q&A pairs from the following text..."
      },
      {
        "role": "user", 
        "content": "Assistant message content"
      }
    ],
    "temperature": 0.3
  }
  ```
- **Response Data**:
  ```json
  {
    "choices": [
      {
        "message": {
          "role": "assistant",
          "content": "{\"pairs\": [{\"question\": \"Q1\", \"answer\": \"A1\"}, ...]}"
        }
      }
    ]
  }
  ```
- **UI Components**: "Save as Q&A" button on `MessageBubble`
- **Loading State**: Progress indicator on button
- **Error Handling**: Dialog with manual creation option

### Local Storage Integration

#### Chat Storage
- **Storage Method**: SharedPreferences
- **Data Format**: JSON list of Chat objects
- **UI Components**: `ChatListItem`, `MessageBubble`

#### Q&A Pair Storage
- **Storage Method**: SharedPreferences
- **Data Format**: JSON list of QAPair objects
- **UI Components**: `QAPairItem`

#### Settings Storage
- **Storage Method**: SharedPreferences for general settings, SecureStorage for API key
- **Data Format**: JSON object with settings properties
- **UI Components**: Settings toggles and dropdowns

### Firebase Authentication Integration

#### Email Authentication
- **Endpoints**: Firebase Authentication API
- **Methods**: createUserWithEmailAndPassword, signInWithEmailAndPassword
- **UI Components**: `LoginScreen`, `SignupScreen`
- **Loading State**: Progress indicator on submit buttons
- **Error Handling**: Specific error messages for different authentication issues

#### Google Authentication
- **Endpoints**: Google Identity Services via Firebase Authentication
- **Methods**: signInWithCredential using GoogleAuthProvider
- **UI Components**: `GoogleSignInButton` on login and signup screens
- **Loading State**: Progress indicator on button
- **Error Handling**: 
  - Network errors: "Unable to connect to authentication service"
  - Permission errors: "Permission to access Google account was denied"
  - General errors: Specific Firebase error messages

### Firestore Integration

#### User Profile Data
- **Collection**: users
- **Document ID**: User's Firebase UID
- **Fields**:
  - uid: String - User's Firebase UID
  - email: String - User's email address
  - displayName: String - User's display name
  - photoURL: String - URL to user's profile picture
  - username: String - User's username (optional)
  - createdAt: Timestamp - When the account was created
  - lastLoginAt: Timestamp - When the user last logged in
- **UI Components**: Profile section in Settings screen
- **Loading State**: Progress indicators on profile components
- **Error Handling**: 
  - Offline errors: "Changes will be saved when you're back online"
  - Permission errors: "You don't have permission to update this profile"
  - Validation errors: Specific messages for invalid inputs

## 8. Localization Guidelines

### Text Guidelines
- Keep UI labels concise and clear
- Use sentence case for most UI elements
- Use imperative form for action buttons (e.g., "Save", not "Saving")
- Maintain consistent terminology across the application

### Localization Keys
- Format: camelCase descriptive names
- Examples: 
  - `newChatButton`
  - `sendMessageToStartChatting`
  - `apiKeySavedSuccess`
  - `createNew`
  - `qaPairs`
  - `settings`
- Context comments should be provided for translators
- Use placeholders for dynamic content: `qaPairsDetected(count)`

### Supported Languages
- English (en): Default language
- Korean (ko): Full support

## 9. Responsive Behavior

### Breakpoints
- **Mobile**: < 600px
- **Tablet**: 600px - 1200px
- **Desktop**: > 1200px

### Responsive Behavior
- **Mobile**:
  - Navigation Rail becomes Bottom Navigation
  - Sidebar is hidden by default, accessible via toggle button
  - Single column layout for all screens
  - App title and logo always visible in top bar
- **Tablet**:
  - Sidebar can be toggled on/off
  - Two column layout for Chat screen when sidebar is visible
  - App title and logo visible in top bar when sidebar is hidden
- **Desktop**:
  - Sidebar can be toggled on/off
  - Full width sidebar when visible
  - Two column layout with comfortable spacing
  - App title and logo visible in top bar when sidebar is hidden

## 10. Accessibility Standards

### Requirements
- All interactive elements must be keyboard accessible
- Minimum touch target size: 44x44px
- Color contrast ratio: 4.5:1 minimum
- All images must have alt text
- Screen reader support for all UI elements

### Semantic Structure
- Use appropriate heading levels (h1, h2, etc.)
- Ensure logical tab order
- Provide aria labels for non-text elements
- Use semantic HTML elements where appropriate

## 11. Error Handling

### Error Types
- **API Errors**: Issues communicating with OpenAI API
- **Validation Errors**: Invalid input from users
- **Network Errors**: Connection issues
- **File Errors**: Problems with file uploads
- **Authentication Errors**: Issues with user login, signup, or account management
- **Database Errors**: Problems with Firestore operations
- **Offline Errors**: Issues when the device is offline

### Error Display
- **Snackbars**: For transient errors that don't block workflow
- **Dialog Alerts**: For critical errors requiring acknowledgment
- **Inline Errors**: For form validation issues
- **Error Messages**: Should be clear, helpful, and suggest solutions
- **Retry Mechanisms**: For operations that can be retried (e.g., Firestore operations when offline)
- **Fallback Behavior**: Graceful degradation when services are unavailable

### Authentication Error Handling
- **Login Errors**:
  - Invalid credentials: "Email or password is incorrect"
  - User not found: "No account found with this email"
  - Too many attempts: "Too many login attempts. Please try again later"
- **Registration Errors**:
  - Email already in use: "An account with this email already exists"
  - Weak password: "Password must be at least 8 characters with a mix of letters, numbers, and symbols"
  - Invalid email: "Please enter a valid email address"
- **Account Deletion Errors**:
  - Requires recent login: "For security reasons, please sign out and sign in again before deleting your account"
  - Permission denied: "You don't have permission to delete this account"
  - Network error: "Unable to delete account due to network issues. Please try again"

### Firestore Error Handling
- **Permission Errors**:
  - Access denied: "You don't have permission to access this data"
  - Quota exceeded: "Database quota exceeded. Please try again later"
- **Network Errors**:
  - Offline: "Changes will be saved when you're back online"
  - Timeout: "Request timed out. Please try again"
- **Data Errors**:
  - Invalid data: "Unable to process data. Please check your input"
  - Document not found: "The requested data could not be found"

### Offline Support
- **Visual Indicators**: Banner at the top of the screen when offline
- **Queued Operations**: Changes are queued and applied when back online
- **Retry Buttons**: Allow users to manually retry failed operations
- **Sync Status**: Indicate which data is synced and which is pending upload
- **Graceful Degradation**: App remains functional with limited capabilities when offline

### Error Logging
- **Client-Side Logging**: Detailed logs for debugging purposes
- **Error Context**: Include relevant context with each error (user action, screen, etc.)
- **Stack Traces**: Capture stack traces for unexpected errors
- **User Feedback**: Option for users to report issues with context
- **Privacy Considerations**: Never log sensitive information like passwords or API keys

## 12. Empty States

### Chat Empty State
- **New User**: Shows welcome message and suggestion to start a chat
- **No Selected Chat**: Shows prompt to select a chat or create a new one
- **Empty Chat**: Shows large, bold welcome message "What can I help you learn?" centered in the chat area

### Q&A Empty State
- **No Q&A Pairs**: Shows message that no pairs exist yet
- **No Search Results**: Shows message that no pairs match search

## 13. Loading States

### Loading Indicators
- **Spinner**: For short operations (< 2 seconds)
- **Progress Bar**: For longer operations with known duration
- **Skeleton Screens**: For initial content loading
- **Chat Loading**: Three bouncing dots animation

### Loading Placement
- **Full Screen**: For initial app loading
- **In-Place**: Replace the component being loaded
- **Button Loading**: Replace button text with spinner during action

## 14. Animation & Transition Guidelines

### Timing
- **Quick Actions**: 150ms (e.g., button hover)
- **Standard Transitions**: 200ms (e.g., page transitions)
- **Complex Animations**: 300-500ms (e.g., dialog open/close)

### Easing Curves
- **Standard Easing**: ease-in-out (0.4, 0.0, 0.2, 1)
- **Acceleration**: ease-out (0.0, 0.0, 0.2, 1)
- **Deceleration**: ease-in (0.4, 0.0, 1.0, 1)

### Specific Animations
- **Navigation Transitions**: Slide from left/right, 200ms
- **Dialog Open/Close**: Fade and scale, 250ms
- **Message Bubble Appearance**: Fade in, slight scale up, 200ms
- **Loading Indicators**: Three bouncing dots, continuous animation
- **Button State Changes**: Quick fade, 150ms
- **Sidebar Toggle**: Slide animation, 250ms

## 15. Testing & QA Guidelines

### UI Testing Checklist
- **Responsive Testing**:
  - Test on mobile, tablet, and desktop breakpoints
  - Verify layout adjusts appropriately
  - Check touch targets are appropriate for each device
  - Test sidebar toggle functionality on all screen sizes

- **Accessibility Testing**:
  - Verify keyboard navigation works for all interactive elements
  - Test with screen readers
  - Check color contrast meets WCAG standards
  - Verify all images have alt text

- **Localization Testing**:
  - Switch between languages and verify all text is translated
  - Check for text overflow or truncation in different languages
  - Verify date and number formatting is appropriate for each locale

- **State Testing**:
  - Test all empty states
  - Test all loading states
  - Test all error states
  - Verify transitions between states are smooth

### QA Acceptance Criteria
For each UI component or feature, the following criteria should be met:
1. Matches design specifications (colors, typography, spacing)
2. Functions correctly across all supported devices and screen sizes
3. Handles all possible states (empty, loading, error)
4. Accessible via keyboard and screen readers
5. Properly localized in all supported languages
6. Animations and transitions are smooth and consistent

### Profile Management Components

#### Profile Picture Component
- **Location**: Top of Profile Section in Settings Screen
- **Description**: Circular avatar with upload functionality
- **Properties**:
  - Size: 100px diameter
  - Border: 2px solid primary color
  - Background: Light gray when no image
- **Elements**:
  - Avatar: Displays user's profile picture or default icon
  - Upload Button: Camera icon in a circular button at bottom-right of avatar
- **States**:
  - Default: Shows current profile picture or default icon
  - Loading: Shows loading indicator during upload
  - Error: Shows error indicator if upload fails
- **Component ID**: `ProfilePictureComponent`

#### Profile Form
- **Location**: Profile Section in Settings Screen
- **Description**: Form for editing profile information
- **Elements**:
  - Display Name Field: Input for user's display name
  - Username Field: Input for user's unique username
  - Helper Text: Explains username requirements
  - Save Changes Button: Primary button to submit changes
- **States**:
  - Default: Shows current profile information
  - Editing: Shows form with editable fields
  - Loading: Shows loading indicator during save
  - Error: Shows error messages for validation issues
- **Component ID**: `ProfileForm`

## 16. Admin Tools

### User Management Tools

#### Purpose
Admin tools provide administrative capabilities for managing user accounts and troubleshooting issues outside the normal application flow.

#### Tools Available

##### Delete User Tool
- **Description**: Command-line utility to delete user accounts from Firebase
- **Variants**:
  - Python Script: `tools/delete_user.py`
  - Shell Script: `tools/delete_user.sh`
  - Dart Script: `tools/delete_user.dart`
- **Usage**: 
  - Python: `python tools/delete_user.py <email>`
  - Shell: `./tools/delete_user.sh <email>`
  - Dart: `dart tools/delete_user.dart <email>`
- **Requirements**:
  - Service account key for Firebase Admin SDK (Python/Dart)
  - Firebase CLI and jq installed (Shell)
- **Process**:
  1. Authenticates with Firebase
  2. Finds user by email
  3. Deletes user data from Firestore (when possible)
  4. Deletes user from Firebase Authentication
  5. Logs the process for verification

##### User Data Management
- **Description**: Tools for managing user data in Firestore
- **Capabilities**:
  - View user data
  - Modify user permissions
  - Reset user state
  - Troubleshoot authentication issues
- **Access Control**: Limited to administrators with appropriate credentials

### Error Handling in Admin Tools
- **Validation**: Verify inputs before performing destructive operations
- **Confirmation**: Require explicit confirmation for account deletion
- **Logging**: Detailed logging of all administrative actions
- **Rollback**: Ability to restore from backups when possible
- **Security**: Strict access controls to prevent unauthorized use

### Admin Tool Documentation
- **README**: Comprehensive documentation in `tools/README.md`
- **Usage Examples**: Clear examples of how to use each tool
- **Security Guidelines**: Best practices for secure use of admin tools
- **Troubleshooting**: Common issues and their solutions 