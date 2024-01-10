String greeter() {
  final int hour = DateTime.now().hour;
  if (hour > 5 && hour < 11) {
    return 'Good morning';
  } else if (hour < 15) {
    return 'Good afternoon';
  } else if (hour < 18) {
    return 'Good evening';
  } else {
    return 'Good night';
  }
}
