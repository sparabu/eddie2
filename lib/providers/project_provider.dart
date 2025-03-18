import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project.dart';

// Provider for the selected project ID
final selectedProjectIdProvider = StateProvider<String?>((ref) => null);

// Provider for projects
final projectProvider = StateNotifierProvider<ProjectNotifier, List<Project>>((ref) {
  return ProjectNotifier();
});

class ProjectNotifier extends StateNotifier<List<Project>> {
  ProjectNotifier() : super([]) {
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final projectsJson = prefs.getStringList('projects') ?? [];
      
      state = projectsJson
          .map((json) => Project.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      debugPrint('Error loading projects: $e');
    }
  }

  Future<void> _saveProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final projectsJson = state
          .map((project) => jsonEncode(project.toJson()))
          .toList();
      
      await prefs.setStringList('projects', projectsJson);
    } catch (e) {
      debugPrint('Error saving projects: $e');
    }
  }

  // Create a new project
  Future<Project> createProject({
    required String title,
    String description = '',
    String? imageUrl,
  }) async {
    final project = Project(
      title: title,
      description: description,
      imageUrl: imageUrl,
    );
    
    state = [project, ...state]; // Add new project at the top
    await _saveProjects();
    return project;
  }

  // Update a project
  Future<void> updateProject(Project updatedProject) async {
    state = state.map((project) {
      if (project.id == updatedProject.id) {
        return updatedProject;
      }
      return project;
    }).toList();
    
    await _saveProjects();
  }

  // Delete a project
  Future<void> deleteProject(String projectId) async {
    state = state.where((project) => project.id != projectId).toList();
    await _saveProjects();
  }

  // Get a project by ID
  Project? getProject(String? projectId) {
    if (projectId == null) return null;
    try {
      return state.firstWhere((project) => project.id == projectId);
    } catch (e) {
      return null;
    }
  }

  // Add a chat to a project
  Future<void> addChatToProject(String projectId, String chatId) async {
    state = state.map((project) {
      if (project.id == projectId) {
        return project.addChat(chatId);
      }
      return project;
    }).toList();
    
    await _saveProjects();
  }

  // Remove a chat from a project
  Future<void> removeChatFromProject(String projectId, String chatId) async {
    state = state.map((project) {
      if (project.id == projectId) {
        return project.removeChat(chatId);
      }
      return project;
    }).toList();
    
    await _saveProjects();
  }

  // Update project title
  Future<void> updateProjectTitle(String projectId, String newTitle) async {
    state = state.map((project) {
      if (project.id == projectId) {
        return project.copyWith(
          title: newTitle,
          updatedAt: DateTime.now(),
        );
      }
      return project;
    }).toList();
    
    await _saveProjects();
  }

  // Update project description
  Future<void> updateProjectDescription(String projectId, String newDescription) async {
    state = state.map((project) {
      if (project.id == projectId) {
        return project.copyWith(
          description: newDescription,
          updatedAt: DateTime.now(),
        );
      }
      return project;
    }).toList();
    
    await _saveProjects();
  }

  // Update project image
  Future<void> updateProjectImage(String projectId, String? newImageUrl, {Uint8List? imageBytes}) async {
    state = state.map((project) {
      if (project.id == projectId) {
        return project.copyWith(
          imageUrl: newImageUrl,
          imageBytes: imageBytes,
          updatedAt: DateTime.now(),
        );
      }
      return project;
    }).toList();
    
    await _saveProjects();
  }

  // Get the next untitled project number
  int getNextUntitledNumber() {
    final untitledProjects = state.where((p) => 
      p.title.startsWith('Untitled Project ')).toList();
    
    if (untitledProjects.isEmpty) return 1;
    
    final numbers = untitledProjects.map((p) {
      final match = RegExp(r'Untitled Project (\d+)').firstMatch(p.title);
      if (match != null && match.group(1) != null) {
        return int.tryParse(match.group(1)!) ?? 0;
      }
      return 0;
    }).toList();
    
    numbers.sort();
    return numbers.isEmpty ? 1 : (numbers.last + 1);
  }
  
  // Generate untitled project name
  String generateUntitledName() {
    if (state.any((p) => p.title == 'Untitled')) {
      final nextNum = getNextUntitledNumber();
      return 'Untitled Project $nextNum';
    }
    return 'Untitled';
  }

  // Create a new project with initialization flow
  Future<Project> createProjectWithSetupFlow() async {
    // Create untitled project first
    final untitledName = generateUntitledName();
    final project = await createProject(title: untitledName);
    
    return project;
  }

  // Update project title from AI conversation
  Future<void> setProjectTitleFromMessage(String projectId, String message) async {
    // Only update if this isn't an "untitled" placeholder
    if (message.trim().isNotEmpty && 
        !message.toLowerCase().contains('untitled')) {
      
      // Extract a reasonable title from the message
      // In a real implementation, this could use a more sophisticated
      // algorithm or even call the OpenAI API to generate a title
      String title = message.trim();
      
      // Limit length for UI purposes
      if (title.length > 50) {
        title = title.substring(0, 47) + '...';
      }
      
      await updateProjectTitle(projectId, title);
    }
  }

  // Update project description from AI conversation
  Future<void> setProjectDescriptionFromMessage(String projectId, String message) async {
    if (message.trim().isNotEmpty) {
      // Clean up the description
      final description = message.trim();
      
      await updateProjectDescription(projectId, description);
    }
  }
} 