import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 120, // Larger size for the profile picture
              backgroundImage: AssetImage('assets/profile_picture.jpg'), // Replace with your image path
            ),
            SizedBox(height: 24), // Adjust spacing for better layout
            Text(
              'Shrawan Kumar Bhagat',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'shrawan23101@iiitnr.edu.in',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 12), // Spacing between email and mobile number
            Text(
              '+91 1111111111', // Replace with your mobile number
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Add functionality for "Back" button
                Navigator.pop(context); // Example: Return to the previous page
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
