---
title: Eddie2 Changelog
version: 1.1.0
last_updated: 2025-03-18
status: active
---

![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)
![Status](https://img.shields.io/badge/status-active-green.svg)
![Last Updated](https://img.shields.io/badge/last%20updated-2025--03--18-lightgrey.svg)

# Eddie2 Changelog

## [1.1.0] - 2025-03-18

### Added
- Image attachment support for chat messages
- Preview of attached images in the chat interface
- Persistence of image attachments across browser sessions for web platform
- Enhanced error handling for image files
- Web file data persistence using localStorage
- Improved image loading with retry mechanism

### Changed
- Updated FileService to implement singleton pattern for better data persistence
- Enhanced MessageBubble widget to display images and handle errors gracefully
- Updated OpenAIService to better handle image processing and data extraction
- Added additional debug logging to help troubleshoot attachment issues

### Fixed
- Issue with image attachments not displaying after sending messages
- Bug where image data would be lost after browser refresh
- Context error in MessageBubble widget
- Improved error messaging for failed image loads

## [1.0.0] - 2024-03-15

### Added
- Complete documentation structure with organized folders
- Product Requirements Documentation (PRD)
  - Main PRD with core requirements
  - Features specification
  - Version history
  - Authentication details
- UI/UX Documentation
  - Main UI/UX specifications
  - Design system guidelines
  - Interaction patterns
- Supporting Documentation
  - Contributing guide
  - Glossary
  - FAQ
  - Feedback form
  - Roadmap
  - Maintenance guide
  - Quality checklist
  - Changelog

### Changed
- Reorganized documentation into a clear hierarchical structure
- Added version badges to all documentation files
- Added frontmatter with metadata to all documents
- Added navigation breadcrumbs and related documents sections
- Added comprehensive tables of contents
- Enhanced cross-referencing between documents

### Improved
- Documentation navigation and discoverability
- Version tracking and status indicators
- Content organization and structure
- Cross-referencing between related documents
- Accessibility of documentation

### Fixed
- Inconsistent document formatting
- Missing navigation elements
- Incomplete cross-references
- Version tracking issues

## [0.1.0] - 2024-03-14

### Added
- Initial documentation setup
- Basic README
- Core PRD and UI/UX specifications

### Changed
- Migrated existing documentation to new structure

### Fixed
- Basic formatting issues
- Missing sections in documentation 