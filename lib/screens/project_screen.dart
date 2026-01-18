import 'package:flutter/material.dart';

class ProjectPage extends StatelessWidget {
  const ProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
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
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: "Hinted search text",
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
          Container(
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

          const SizedBox(height: 10), // Reduced space to move grid up
          // Grid of Projects
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            children: List.generate(4, (index) => _buildProjectPlaceholder()),
          ),
          const SizedBox(height: 120), // Space for floating bottom nav
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

  Widget _buildProjectPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE5E1E6),
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Center(
        child: Icon(Icons.category, color: Colors.black38, size: 60),
      ),
    );
  }
}
