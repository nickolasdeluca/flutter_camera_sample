import 'package:flutter/material.dart';

class Dialogs {
  static confirm(BuildContext context, String title, String message) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
      ),
    );
  }
}
