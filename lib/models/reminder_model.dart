class Reminder {
  final int reminderId;
  String title;
  DateTime time;

  Reminder({
    required this.reminderId,
    required this.title,
    required this.time,
  });

  void createReminder(String newTitle, DateTime newTime) {
    title = newTitle;
    time = newTime;
  }

  void editReminder(String updatedTitle, DateTime updatedTime) {
    title = updatedTitle;
    time = updatedTime;
  }

  void deleteReminder() {
    title = "";
    print("Reminder $reminderId deleted.");
  }
}
