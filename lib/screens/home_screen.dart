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
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    _voiceAssistant = VoiceAssistant(context);
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
    } else {
      _voiceAssistant.stopWakeWordDetection();
    }
  }

  void _handleVoiceCommand(String command) async {
    print("Received Voice Command: $command");
    final String backendUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:5000';

    try {
      final response = await http.post(
        Uri.parse("$backendUrl/analyze-transcript"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"transcript": command}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String intent = data["intent"];
        String clarificationMessage = data["clarification_message"] ?? "";

        if (clarificationMessage.isNotEmpty) {
          await _voiceAssistant.speak(clarificationMessage);
          return;
        }

        // Navigate based on intent
        if (intent == "make_payment") {
          String name = data["parameters"]["name"] ?? "";
          double? amount = data["parameters"]["amount"]?.toDouble();
          await _voiceAssistant.speak("You will send ₹${amount ?? 0} to ${name}.");
          Navigator.push(context, MaterialPageRoute(builder: (context) => MakePaymentPage(name: name, amount: amount!.toInt())));
        } else if (intent == "check_balance") {
          await _voiceAssistant.speak("Now proceeding to check balance.");
          Navigator.push(context, MaterialPageRoute(builder: (context) => CheckBalancePage()));
        } else if (intent == "check_history") {
          await _voiceAssistant.speak("Now proceeding to view history.");
          Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryPage()));
        } else {
          await _voiceAssistant.speak("I didn't understand that command.");
        }
      } else {
        print("Error: ${response.body}");
        await _voiceAssistant.speak("Sorry, I couldn't process your request.");
      }
    } catch (e) {
      print("Request Error: $e");
      await _voiceAssistant.speak("There was an issue processing your request.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MakePaymentPage(name: "", amount: 0)));
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

          // Floating Action Button for QR Scanner and Voice Assistant
          floatingActionButton: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // QR Scanner in the bottom center
              Positioned(
                bottom: 16,
                left: MediaQuery.of(context).size.width / 2 - 28, // Centered
                child: FloatingActionButton(
                  onPressed: () {
                    // QR scanner functionality
                  },
                  child: Icon(Icons.qr_code_scanner, size: 30),
                  backgroundColor: Colors.green,
                ),
              ),

              // Voice Assistant Mic Button moved to the right bottom
              if (isVoiceAssistantEnabled)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: () {
                      _voiceAssistant.startListening();
                    },
                    child: Icon(Icons.mic, size: 30),
                    backgroundColor: Colors.blue,
                  ),
                ),
            ],
          ),

          // Floating Action Button Location
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        ),
      ],
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