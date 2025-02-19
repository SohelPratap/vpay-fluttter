import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.history),
      ),
      body: Center(
        child: Text(
          AppLocalizations.of(context)!.inside_history,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
