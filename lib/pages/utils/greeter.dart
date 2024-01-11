String greeter() {
  final int hour = DateTime.now().hour;

  if (hour >= 0 && hour < 5) {
    return 'Good night';
  } else if (hour >= 5 && hour < 12) {
    return 'Good morning';
  } else if (hour >= 12 && hour < 16) {
    return 'Good afternoon';
  } else if (hour >= 16 && hour < 19) {
    return 'Good Evening';
  } else if (hour >= 19) {
    return 'Good night';
  } else {
    return 'Hello';
  }
}
