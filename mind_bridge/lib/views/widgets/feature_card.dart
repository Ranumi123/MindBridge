import 'package:flutter/material.dart';

class FeatureCard extends StatelessWidget {
  // Title removed as per request
  final String cardImagePath;
  final String route;

  const FeatureCard(
      {super.key,
      // Title parameter removed
      required this.cardImagePath,
      required this.route});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        width: 150,
        height: 170,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Image.asset(
                cardImagePath,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
