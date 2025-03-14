import 'package:flutter/material.dart';

class GifScreen extends StatefulWidget {
  const GifScreen({super.key});

  @override
  _GifScreenState createState() => _GifScreenState();
}

class _GifScreenState extends State<GifScreen> {
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _opacity = 0.0;
      });
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 1),
          child: Image.asset('assets/gifs/thumbs_up.gif', width: 200, height: 200),
        ),
      ),
    );
  }
}
