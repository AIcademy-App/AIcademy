import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project.dart';
import '../services/file_service.dart';
import '../services/pdf_service.dart';

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
  final pdfService = PdfService();
  
  bool isUploading = false;
  double uploadProgress = 0.0;
  String? uploadingFileName;
  List<Map<String, dynamic>> selectedFiles = []; 

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
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.project.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // File List or Empty State
            if (selectedFiles.isEmpty && !isUploading)
              _buildEmptyState()
            else if (isUploading)
              _buildProgressUI()
            else
              _buildSelectedFilesList(),

            // Action Buttons
            if (!isUploading) _buildActionButtons(user.uid),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60.0),
      child: Column(
        children: [
          Icon(Icons.folder_open, size: 80, color: Colors.grey.shade700),
          const SizedBox(height: 24),
          const Text('Add PDF files to get started', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSelectedFilesList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Files to Upload', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...selectedFiles.map((fileData) => _buildFileItem(fileData)).toList(),
        ],
      ),
    );
  }

  Widget _buildFileItem(Map<String, dynamic> fileData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.picture_as_pdf, color: Colors.red.shade400, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text(fileData['name'], style: const TextStyle(color: Colors.white)),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey, size: 20),
            onPressed: () => setState(() => selectedFiles.remove(fileData)),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressUI() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        children: [
          const CircularProgressIndicator(color: Color(0xFF00E5BC)),
          const SizedBox(height: 24),
          Text('Extracting Text: $uploadingFileName', style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(String uid) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        children: [
          _customButton('Choose Files', const [Color(0xFF23C174), Color(0xFF00C9E0)], _pickFiles),
          if (selectedFiles.isNotEmpty) ...[
            const SizedBox(height: 12),
            _customButton('Extract & Save', const [Color(0xFF00E5BC), Color(0xFF00C9E0)], () => _processAndSave(uid)),
          ]
        ],
      ),
    );
  }

  Widget _customButton(String text, List<Color> colors, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold))),
      ),
    );
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        for (var path in result.paths) {
          if (path != null) {
            final file = File(path);
            final name = path.split('/').last;
            selectedFiles.add({'name': name, 'file': file});
          }
        }
      });
    }
  }

  Future<void> _processAndSave(String uid) async {
    setState(() => isUploading = true);

    try {
      for (var fileData in selectedFiles) {
        final file = fileData['file'] as File;
        final name = fileData['name'] as String;

        setState(() => uploadingFileName = name);

        // 1. Extract Text Locally
        String text = await pdfService.extractTextFromPdf(file);

        // 2. Save to Firestore (No Storage Needed)
        await fileService.createFile(
          uid: uid,
          projectId: widget.project.id,
          fileName: name,
          fileSize: file.lengthSync(),
          content: text,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Files processed successfully!')),
        );
      }
    } catch (e) {
      setState(() => isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}