import 'dart:io';

import 'package:flutter/material.dart';

class PhotoPreview extends StatelessWidget {
  const PhotoPreview({super.key, required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your photo'),
      ),
      body: SizedBox.expand(
        child: Image.file(
          File(image),
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
