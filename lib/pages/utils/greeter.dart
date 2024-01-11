import 'dart:math';

String timeGreeter() {
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

String greeter() {
  final List<String> quotes = <String>[
    'Wishing you a day filled with joy and positivity.',
    'May your day be as bright as your smile.',
    'Hope your day is as amazing as you are.',
    'May today bring you happiness and success.',
    'Wishing you a wonderful day filled with laughter and love.',
    "Wishing you a day that's as awesome as you are.",
    'May your day be as fantastic as your dreams.',
  ];

  final Random random = Random();

  // on rare occasion, lets return an easter egg :)
  if (random.nextInt(100) == 42) return 'These quotes are computer generated!';

  final int randomNumber = random.nextInt(quotes.length);
  return quotes[randomNumber];
}
