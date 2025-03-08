import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text('Typing...'),
          SizedBox(width: 8),
          CircularProgressIndicator(),
        ],
      ),
    );
  }
}
