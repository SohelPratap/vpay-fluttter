import 'package:flutter/material.dart';

class MicOverlay extends StatefulWidget {
  final bool isListening;

  const MicOverlay({Key? key, required this.isListening}) : super(key: key);

  @override
  _MicOverlayState createState() => _MicOverlayState();
}

class _MicOverlayState extends State<MicOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
      lowerBound: 0.8,
      upperBound: 1.2,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isListening
        ? Center(
      child: ScaleTransition(
        scale: _animation,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.7),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.mic, color: Colors.white, size: 50),
        ),
      ),
    )
        : SizedBox.shrink();
  }
}