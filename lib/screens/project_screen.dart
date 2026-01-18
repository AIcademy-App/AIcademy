import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/project.dart';
import '../services/project_service.dart';
import '../widgets/add_edit_project_dialog.dart';
import 'project_details_screen.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  final projectService = ProjectService();
  final searchController = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _showAddProjectDialog() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (_) => AddEditProjectDialog(
        uid: user.uid,
        onSuccess: () => setState(() {}),
      ),
    );
  }

  void _showEditProjectDialog(Project project) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (_) => AddEditProjectDialog(
        project: project,
        uid: user.uid,
        onSuccess: () => setState(() {}),
      ),
    );
  }

  Future<void> _deleteProject(Project project) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Delete Project',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${project.name}"?',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await projectService.deleteProject(
                  uid: user.uid,
                  projectId: project.id,
                );
                if (mounted) {
                  Navigator.pop(dialogContext);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Project deleted successfully'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 80),

          // Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Pickachu",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Urbanist',
                ),
              ),
              _buildLabel(),
            ],
          ),

          const SizedBox(height: 30),

          // 3D Action Cards
          Row(
            children: [
              _buildMainCard(
                "Pomodoro\nTimer",
                "assets/images/pomodoro.png",
                imageScale: 1.0,
              ),
              const SizedBox(width: 15),
              _buildMainCard(
                "Scheduler",
                "assets/images/calander.png",
                imageScale: 0.8,
              ),
            ],
          ),

          const SizedBox(height: 25),

          // Search Bar with Suffix Icon
          TextField(
            controller: searchController,
            onChanged: (value) => setState(() => searchQuery = value),
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: "Search projects...",
              hintStyle: const TextStyle(
                color: Colors.black45,
                fontFamily: 'Urbanist',
              ),
              fillColor: Colors.white,
              filled: true,
              suffixIcon: const Icon(Icons.search, color: Colors.black),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // + New Project Button with Vibrant Gradient
          GestureDetector(
            onTap: _showAddProjectDialog,
            child: Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF23C174), Color(0xFF00C9E0)],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Center(
                child: Text(
                  "+ New Project",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    fontFamily: 'Urbanist',
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),
          // Grid of Projects - Real Data from Firestore
          if (user != null)
            StreamBuilder<List<Project>>(
              stream: searchQuery.isEmpty
                  ? projectService.getProjectsStream(user.uid)
                  : projectService.searchProjects(
                      uid: user.uid,
                      query: searchQuery,
                    ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    children: List.generate(
                      4,
                      (index) => Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E1E6),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading projects',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                final projects = snapshot.data ?? [];

                if (projects.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(Icons.folder_open, size: 60, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'No projects yet',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Create your first project to get started',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  children: projects
                      .map((project) =>
                          _buildProjectCard(project, user.uid))
                      .toList(),
                );
              },
            ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  //label

  Widget _buildLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: const Row(
        children: [
          Icon(Icons.stars, color: Colors.white, size: 16),
          SizedBox(width: 5),
          Text(
            "Label",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'Urbanist',
            ),
          ),
        ],
      ),
    );
  }

  // Card Helper with Image Scaling logic
  Widget _buildMainCard(
    String title,
    String imagePath, {
    double imageScale = 1.0,
  }) {
    return Expanded(
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(
              child: SizedBox(
                height: 100,
                child: Transform.scale(
                  scale: imageScale, // Controls individual asset size
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image_not_supported,
                        color: Colors.white24,
                        size: 50,
                      );
                    },
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    fontFamily: 'Urbanist',
                  ),
                ),
                const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(Project project, String uid) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetailsScreen(project: project),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE5E1E6),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Stack(
          children: [
            // Project Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.folder, size: 40, color: Colors.black38),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Urbanist',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (project.description != null &&
                          project.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            project.description!,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                              fontFamily: 'Urbanist',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Edit & Delete Buttons (Top Right)
            Positioned(
              top: 8,
              right: 8,
              child: PopupMenuButton(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditProjectDialog(project);
                  } else if (value == 'delete') {
                    _deleteProject(project);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.more_vert,
                      size: 18, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
