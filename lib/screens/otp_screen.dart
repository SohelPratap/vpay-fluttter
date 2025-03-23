import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/auth_service.dart';
import 'profile_creation_screen.dart';
import 'home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OtpScreen({
    Key? key,
    required this.verificationId,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otpController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Enter OTP",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter OTP',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: verifyOtp,
                    child: const Text(
                      "Verify OTP",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void verifyOtp() async {
    try {
      // Verify OTP with Firebase
      await _authService.verifyOtp(widget.verificationId, otpController.text);

      // Get API base URL from .env
      final String apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';

      // Encode phone number for URL to handle special characters like +
      String encodedPhoneNumber = Uri.encodeComponent(widget.phoneNumber);

      // Check if the user exists in the database
      final response = await http.get(Uri.parse('$apiBaseUrl/check-auth/$encodedPhoneNumber'));

      if (response.statusCode == 200) {
        // User exists, navigate to HomeScreen
        final data = json.decode(response.body);
        if (data['auth'] == 'yes') {
          // Fetch profile details from the server
          final profileResponse = await http.get(Uri.parse('$apiBaseUrl/fetch-profile/$encodedPhoneNumber'));

          if (profileResponse.statusCode == 200) {
            final profileData = json.decode(profileResponse.body);

            // Store user info in SharedPreferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool('is_logged_in', true);
            await prefs.setString('user_phone', widget.phoneNumber);
            await prefs.setString('user_name', profileData['name'] ?? '');
            await prefs.setString('user_email', profileData['email'] ?? '');

            // Navigate to HomeScreen
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error fetching profile")));
          }
        } else {
          // User exists but not authenticated, go to Profile Creation
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ProfileCreationScreen(phoneNumber: widget.phoneNumber)),
          );
        }
      } else {
        // User doesn't exist, go to Profile Creation
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfileCreationScreen(phoneNumber: widget.phoneNumber)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid OTP")));
    }
  }
}