import 'package:flutter/material.dart';
import '../models/project_file.dart';

class FileViewerScreen extends StatelessWidget {
  final ProjectFile file;

  const FileViewerScreen({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          file.fileName,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          file.content.isEmpty ? "No text content available." : file.content,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.5,
            fontFamily: 'Urbanist',
          ),
        ),
      ),
    );
  }
}