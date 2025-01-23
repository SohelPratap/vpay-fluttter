import 'package:flutter/material.dart';

class AddBankPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Bank'),
      ),
      body: Center(
        child: Text(
          'This is the Add Bank page.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
