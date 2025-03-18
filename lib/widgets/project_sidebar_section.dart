import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/project.dart';
import '../providers/project_provider.dart';
import '../providers/chat_provider.dart';
import '../theme/eddie_colors.dart';
import '../theme/eddie_text_styles.dart';
import 'sidebar_item.dart';

class ProjectSidebarSection extends ConsumerWidget {
  final Function(String) onSelectProject;
  final String? selectedProjectId;

  const ProjectSidebarSection({
    Key? key,
    required this.onSelectProject,
    this.selectedProjectId,
  }) : super(key: key);

  void _createNewProject(BuildContext context, WidgetRef ref) async {
    final projectNotifier = ref.read(projectProvider.notifier);
    
    // Create the project with setup flow
    final newProject = await projectNotifier.createProjectWithSetupFlow();
    
    // Select the new project
    onSelectProject(newProject.id);
  }
  
  void _renameProject(BuildContext context, WidgetRef ref, String projectId, String newTitle) async {
    await ref.read(projectProvider.notifier).updateProjectTitle(projectId, newTitle);
  }
  
  void _deleteProject(BuildContext context, WidgetRef ref, String projectId) async {
    // Delete all chats associated with this project
    await ref.read(chatProvider.notifier).deleteProjectChats(projectId);
    
    // Delete the project
    await ref.read(projectProvider.notifier).deleteProject(projectId);
    
    // If the deleted project was selected, clear the selection
    if (selectedProjectId == projectId) {
      ref.read(selectedProjectIdProvider.notifier).state = null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final projects = ref.watch(projectProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.projects,
              style: EddieTextStyles.body2(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.add,
                size: 18,
                color: EddieColors.getTextSecondary(context),
              ),
              onPressed: () => _createNewProject(context, ref),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: l10n.createNewProject,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (projects.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l10n.noProjectsYet,
              style: EddieTextStyles.caption(context),
            ),
          )
        else
          ...projects.map((project) {
            return SidebarItem(
              id: project.id,
              title: project.title,
              icon: Icons.folder_outlined,
              isSelected: project.id == selectedProjectId,
              onTap: () => onSelectProject(project.id),
              onDelete: () => _deleteProject(context, ref, project.id),
              onRename: (newTitle) => _renameProject(context, ref, project.id, newTitle),
            );
          }).toList(),
      ],
    );
  }
} 