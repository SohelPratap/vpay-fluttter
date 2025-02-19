import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CheckBalancePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.check_balance),
      ),
      body: Center(
        child: Text(
          AppLocalizations.of(context)!.inside_check_balance,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
