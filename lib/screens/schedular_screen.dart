import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SchedulerPage extends StatefulWidget {
  const SchedulerPage({super.key});

  @override
  State<SchedulerPage> createState() => _SchedulerPageState();
}

class _SchedulerPageState extends State<SchedulerPage> {
  int _selectedDayIndex = 0;
  final ScrollController _taskScrollController = ScrollController();

  @override
  void dispose() {
    _taskScrollController.dispose();
    super.dispose();
  }

  // Helper to get the formatted string for the header based on selection
  String _getSelectedDateString() {
    DateTime selectedDate = DateTime.now().add(
      Duration(days: _selectedDayIndex),
    );
    return DateFormat('EEEE d').format(selectedDate) +
        _getDaySuffix(selectedDate.day);
  }

  // Helper for "st", "nd", "rd", "th" suffixes
  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 100),

            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const Text(
              "Scheduler",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Urbanist',
              ),
            ),
            const SizedBox(height: 20),

            // To-Do Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "To Do",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                      // FIXED: This now updates based on the selected horizontal date
                      Text(
                        _getSelectedDateString(),
                        style: const TextStyle(
                          color: Color(0xFF00E5BC),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  SizedBox(
                    height: 250,
                    child: ListView(
                      controller: _taskScrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.zero,
                      children: [
                        _buildTaskItem("Work 01"),
                        _buildTaskItem("Work Todo List 01"),
                        _buildTaskItem("Sample work 03"),
                        _buildTaskItem("Sample work 04"),
                        _buildTaskItem("Sample work 05"),
                        _buildTaskItem("Sample work 06"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 10),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOutSine,
                    builder: (context, double value, child) {
                      return Padding(
                        padding: EdgeInsets.only(top: value),
                        child: child,
                      );
                    },
                    child: GestureDetector(
                      onTap: () {
                        _taskScrollController.animateTo(
                          _taskScrollController.offset + 80,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                        );
                      },
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: const BoxDecoration(
                          color: Color(0xFFC4C4C4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_downward,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // REAL Horizontal Date Picker
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 14,
                itemBuilder: (context, index) {
                  DateTime date = DateTime.now().add(Duration(days: index));
                  String dayLabel = DateFormat(
                    'EEEE',
                  ).format(date).toUpperCase();
                  String dateLabel = DateFormat('d').format(date);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDayIndex =
                            index; // Updates the header text automatically
                      });
                    },
                    child: _buildDateCard(
                      dayLabel,
                      dateLabel,
                      _selectedDayIndex == index,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  //Task Item Widget
  Widget _buildTaskItem(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'Urbanist',
        ),
      ),
    );
  }

  // Date Card Widget

  Widget _buildDateCard(String day, String date, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
        border: isSelected
            ? Border.all(color: const Color(0xFF00E5BC), width: 1)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day.substring(0, 3),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontFamily: 'Urbanist',
            ),
          ),
          const SizedBox(height: 5),
          Text(
            date,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontFamily: 'Urbanist',
            ),
          ),
          const SizedBox(height: 5),
          Container(
            height: 3,
            width: 20,
            color: isSelected ? const Color(0xFF00E5BC) : Colors.transparent,
          ),
        ],
      ),
    );
  }
}
