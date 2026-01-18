import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/project_service.dart';

class AddEditProjectDialog extends StatefulWidget {
  final Project? project; // null = create mode, not null = edit mode
  final String uid;
  final VoidCallback onSuccess;

  const AddEditProjectDialog({
    super.key,
    this.project,
    required this.uid,
    required this.onSuccess,
  });

  @override
  State<AddEditProjectDialog> createState() => _AddEditProjectDialogState();
}

class _AddEditProjectDialogState extends State<AddEditProjectDialog> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  final projectService = ProjectService();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.project?.name ?? '');
    descriptionController =
        TextEditingController(text: widget.project?.description ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project name cannot be empty')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      if (widget.project == null) {
        // Create new project
        await projectService.createProject(
          uid: widget.uid,
          name: nameController.text.trim(),
          description: descriptionController.text.trim(),
        );
      } else {
        // Edit existing project
        await projectService.updateProject(
          uid: widget.uid,
          projectId: widget.project!.id,
          name: nameController.text.trim(),
          description: descriptionController.text.trim(),
        );
      }

      if (mounted) {
        widget.onSuccess();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.project == null
                  ? 'Project created successfully!'
                  : 'Project updated successfully!',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.project != null;

    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditMode ? 'Edit Project' : 'Create New Project',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Urbanist',
                ),
              ),
              const SizedBox(height: 20),

              // Project Name Field
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Project Name',
                  labelStyle: const TextStyle(color: Colors.grey),
                  hintText: 'e.g., Mathematics, History',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF2A2A2A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00E5BC)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00E5BC)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF00E5BC),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description Field
              TextField(
                controller: descriptionController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  labelStyle: const TextStyle(color: Colors.grey),
                  hintText: 'What is this project about?',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF2A2A2A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00E5BC)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00E5BC)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF00E5BC),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        isLoading ? null : () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: isLoading ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5BC),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          )
                        : Text(
                            isEditMode ? 'Update' : 'Create',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Urbanist',
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
