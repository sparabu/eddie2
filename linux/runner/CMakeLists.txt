cmake_minimum_required(VERSION 3.10)
set(PROJECT_NAME "eddie2")
set(APPLICATION_ID "com.eddie.eddie2")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "eddie2_plugin")

add_definitions(-DAPPLICATION_ID="${APPLICATION_ID}")

# Any new source files that you add to the plugin should be added here.
list(APPEND PLUGIN_SOURCES
  "my_application.cc"
  "my_application.h"
)

# Define the plugin library target. Its name must not be changed (see comment
# on PLUGIN_NAME above).
add_library(${PLUGIN_NAME} SHARED
  "flutter_window.cc"
  "flutter_window.h"
  "main.cc"
  "utils.cc"
  "utils.h"
  ${PLUGIN_SOURCES}
)

# Apply a standard set of build settings that are configured in the
# application-level CMakeLists.txt. This can be removed for plugins that want
# full control over build settings.
apply_standard_settings(${PLUGIN_NAME})

# Symbols are hidden by default to reduce the chance of accidental conflicts
# between plugins. This should not be removed; any symbols that should be
# exported should be explicitly exported with the FLUTTER_PLUGIN_EXPORT macro.
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)

# Source include directories and library dependencies. Add any plugin-specific
# dependencies here.
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::GTK)

# List of absolute paths to libraries that should be bundled with the plugin.
# This list could contain prebuilt libraries, or libraries created by an
# external build triggered from this build file.
set(eddie2_bundled_libraries
  ""
  PARENT_SCOPE
)

# === Tests ===

if(${include_${PROJECT_NAME}_tests})
if(${CMAKE_VERSION} VERSION_LESS "3.11.0")
  message(WARNING "Unit tests require CMake 3.11.0 or later")
else()
  set(TEST_RUNNER "${PROJECT_NAME}_test_runner")
  enable_testing()
  # TODO: Add other unit tests here.
endif()
endif()
