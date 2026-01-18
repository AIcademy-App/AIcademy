import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/project.dart';
import '../models/project_file.dart';
import '../services/file_service.dart';
import '../services/storage_service.dart';

class AddFilesScreen extends StatefulWidget {
  final Project project;

  const AddFilesScreen({
    super.key,
    required this.project,
  });

  @override
  State<AddFilesScreen> createState() => _AddFilesScreenState();
}

class _AddFilesScreenState extends State<AddFilesScreen> {
  final fileService = FileService();
  final storageService = StorageService();
  bool isUploading = false;
  double uploadProgress = 0.0;
  String? uploadingFileName;
  List<Map<String, dynamic>> selectedFiles = []; // {name, size, file}

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Not authenticated')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.project.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Urbanist',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Empty State or File List
            if (selectedFiles.isEmpty && !isUploading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 60.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder_open,
                      size: 80,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Add PDF files to get started',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              )
            else if (selectedFiles.isNotEmpty && !isUploading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Files to Upload',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...selectedFiles.map((fileData) {
                      final fileName = fileData['name'] as String;
                      final fileSize = fileData['size'] as int;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.picture_as_pdf,
                              color: Colors.red.shade400,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fileName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Urbanist',
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontFamily: 'Urbanist',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedFiles.removeWhere(
                                    (f) => f['name'] == fileName,
                                  );
                                });
                              },
                              child: Icon(
                                Icons.close,
                                color: Colors.grey.shade600,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),

            // Upload Progress
            if (isUploading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 60.0),
                child: Column(
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF00E5BC),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (uploadingFileName != null)
                      Text(
                        'Uploading: $uploadingFileName',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Urbanist',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: uploadProgress,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade800,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF00E5BC),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(uploadProgress * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                  ],
                ),
              ),

            // Action Buttons
            if (!isUploading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 40.0),
                child: Column(
                  children: [
                    // Pick Files Button
                    GestureDetector(
                      onTap: _pickFiles,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xFF23C174), Color(0xFF00C9E0)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text(
                            'Choose Files',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Urbanist',
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Upload Button (if files selected)
                    if (selectedFiles.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: GestureDetector(
                          onTap: () => _uploadFiles(user.uid),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [Color(0xFF00E5BC), Color(0xFF00C9E0)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: Text(
                                'Upload Files',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Urbanist',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFiles() async {
    // For web, show a dialog for demo purposes
    // In production, use package like universal_html or html for file picker
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Add PDF Files',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'In a production app, this would open a file picker. For demo purposes, add files through the API.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadFiles(String uid) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => isUploading = true);

    try {
      for (var fileData in selectedFiles) {
        final fileName = fileData['name'] as String;
        final file = fileData['file'] as File;

        setState(() {
          uploadingFileName = fileName;
          uploadProgress = 0.0;
        });

        // Upload to storage
        final fileUrl = await storageService.uploadFile(
          uid: uid,
          projectId: widget.project.id,
          file: file,
          onProgress: (progress) {
            setState(() => uploadProgress = progress);
          },
        );

        // Create file record in Firestore
        await fileService.createFile(
          uid: uid,
          projectId: widget.project.id,
          fileName: fileName,
          fileUrl: fileUrl,
          fileSize: file.lengthSync(),
        );
      }

      setState(() {
        isUploading = false;
        uploadProgress = 0.0;
        uploadingFileName = null;
        selectedFiles.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Files uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        isUploading = false;
        uploadProgress = 0.0;
        uploadingFileName = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
