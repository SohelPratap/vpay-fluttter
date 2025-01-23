import 'package:flutter/material.dart';

class MakePaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make Payment'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'This is the Make Payment page.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
