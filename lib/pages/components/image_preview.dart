import 'dart:io';

import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  const ImagePreview({required this.file, required this.menuName, super.key});

  final File file;
  final String menuName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(menuName),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Hero(
            tag: menuName,
            child: Image.file(file),
          ),
        ),
      ),
    );
  }
}
