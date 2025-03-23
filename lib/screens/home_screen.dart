import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'make_payment_page.dart';
import 'check_balance_page.dart';
import 'add_bank_page.dart';
import 'history_page.dart';
import 'profile_page.dart';
import '../language_provider.dart';
import '../features/call_feature.dart';
import '../features/voice_assistant.dart';  // Import VoiceAssistant class
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String userName = "User";
  bool isFraudWarningEnabled = true; // Default enabled
  bool isVoiceAssistantEnabled = true; // Default enabled
  late CallFeature _callFeature;
  late VoiceAssistant _voiceAssistant;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _callFeature = CallFeature();
    _loadFraudWarningState();
    _loadVoiceAssistantState();

    // Initialize voice assistant
    _voiceAssistant = VoiceAssistant();
    if (isVoiceAssistantEnabled) {
      _voiceAssistant.initializeWakeword(_handleVoiceCommand);
    }
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? "User";
    });
  }

  Future<void> _loadFraudWarningState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isFraudWarningEnabled = prefs.getBool('call_warning_enabled') ?? true;
    });
  }

  Future<void> _loadVoiceAssistantState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isVoiceAssistantEnabled = prefs.getBool('voice_assistant_enabled') ?? true;
    });
  }

  Future<void> _toggleFraudWarning(bool value) async {
    await _callFeature.toggleWarning(value);
    setState(() {
      isFraudWarningEnabled = value;
    });
  }

  Future<void> _toggleVoiceAssistant(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('voice_assistant_enabled', value);
    setState(() {
      isVoiceAssistantEnabled = value;
    });

    if (value) {
      _voiceAssistant.initializeWakeword(_handleVoiceCommand);
      _voiceAssistant.startWakeWordDetection();
    } else {
      _voiceAssistant.stopWakeWordDetection();
      _voiceAssistant.stopListening();
    }
  }

  void _handleVoiceCommand(String command) async {
    print("Recognized Command: $command");

    // Send the command to the ML backend for intent detection
    final response = await http.post(
      Uri.parse("http://192.168.0.101:3000/analyze-transcript"), // Replace with your actual API URL
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"transcript": command}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String intent = data["intent"];
      String name = data["parameters"]["name"] ?? "";
      int amount = data["parameters"]["amount"] ?? 0;
      String clarification = data["clarification_message"] ?? "";

      print("Intent: $intent, Name: $name, Amount: $amount");

      // Handle navigation based on detected intent
      if (intent == "make_payment" && name.isNotEmpty && amount > 0) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MakePaymentPage(name: name, amount: amount)),
        );
      } else if (intent == "check_balance") {
        Navigator.push(context, MaterialPageRoute(builder: (context) => CheckBalancePage()));
      } else if (intent == "add_bank") {
        Navigator.push(context, MaterialPageRoute(builder: (context) => AddBankPage()));
      } else if (intent == "check_history") {
        Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryPage()));
      } else if (clarification.isNotEmpty) {
        print("Clarification Needed: $clarification");
        // Handle case where AI needs more input (e.g., missing amount)
      } else {
        print("Unknown command: $command");
      }
    } else {
      print("Failed to process command: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: Row(
          children: [
            Expanded(
              child: IconButton(
                icon: Icon(Icons.menu, size: 30),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
            ),
            Expanded(
              child: IconButton(
                icon: Icon(Icons.qr_code_scanner, size: 30),
                onPressed: () {
                  // QR scanner functionality
                },
              ),
            ),
          ],
        ),
        title: Text(
          'Voice Pay',
          style: TextStyle(color: Colors.transparent),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, size: 35),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
        ],
      ),

      // Drawer with Language Selection, Fraud Warning Toggle, and Voice Assistant Toggle
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                "Settings",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            ListTile(
              title: Text("English"),
              onTap: () {
                context.read<LanguageProvider>().changeLanguage('en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text("हिन्दी"),
              onTap: () {
                context.read<LanguageProvider>().changeLanguage('hi');
                Navigator.pop(context);
              },
            ),
            Divider(),
            SwitchListTile(
              title: Text("Fraud Call Warning"),
              value: isFraudWarningEnabled,
              onChanged: _toggleFraudWarning,
            ),
            SwitchListTile(
              title: Text("Voice Assistant"),
              value: isVoiceAssistantEnabled,
              onChanged: _toggleVoiceAssistant,
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 16),
              Text(
                '${AppLocalizations.of(context)!.welcome}, $userName 👋',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Image.asset(
                  'assets/voice_pay.jpg',
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Text(
                AppLocalizations.of(context)!.note,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              PaymentButton(
                label: AppLocalizations.of(context)!.make_payment,
                icon: Icons.payment,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MakePaymentPage()));
                },
              ),
              PaymentButton(
                label: AppLocalizations.of(context)!.check_balance,
                icon: Icons.account_balance_wallet,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CheckBalancePage()));
                },
              ),
              PaymentButton(
                label: AppLocalizations.of(context)!.add_bank,
                icon: Icons.account_balance,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddBankPage()));
                },
              ),
              PaymentButton(
                label: AppLocalizations.of(context)!.history,
                icon: Icons.history,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryPage()));
                },
              ),
            ],
          ),
        ),
      ),

      // Floating Voice Assistant Button
        floatingActionButton: isVoiceAssistantEnabled
            ? FloatingActionButton(
          onPressed: () {
            _voiceAssistant.startListening();
          },
          child: Icon(Icons.mic, size: 30),
          backgroundColor: Colors.blue,
        )
            : null,
    );
  }
}

// Reusable PaymentButton Widget
class PaymentButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const PaymentButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 24),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 50),
          textStyle: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}