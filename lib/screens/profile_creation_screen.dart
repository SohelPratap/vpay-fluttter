import 'dart:convert';  // For converting response to JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfileCreationScreen extends StatelessWidget {
  final String phoneNumber;

  const ProfileCreationScreen({Key? key, required this.phoneNumber}) : super(key: key);

  // Function to save profile via HTTP request
  Future<void> saveProfile(String name, String email, String phoneNumber, BuildContext context) async {
    final url = Uri.parse('http://192.168.0.102:3000/save-profile');  // Replace with your server URL

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "phoneNumber": phoneNumber,
        "name": name,
        "email": email,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['message'] == 'Profile saved and authenticated successfully!') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile saved and authenticated successfully!")),
        );
      }
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save profile. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Profile"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Profile Picture
              GestureDetector(
                onTap: () {
                  // Logic for adding or changing profile picture
                  // Implement if required
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: const AssetImage("assets/profile_picture.jpg"),
                ),
              ),
              const SizedBox(height: 20),
              // Name TextField
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Phone Number (Non-editable)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  phoneNumber,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              // Email TextField (Optional)
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email (optional)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final email = emailController.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Name cannot be empty")),
                      );
                      return;
                    }

                    // Call saveProfile function to make API request
                    saveProfile(name, email, phoneNumber, context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Save Profile",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}