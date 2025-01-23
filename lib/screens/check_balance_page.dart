import 'package:flutter/material.dart';

class CheckBalancePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check Balance'),
      ),
      body: Center(
        child: Text(
          'This is the Check Balance page.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
