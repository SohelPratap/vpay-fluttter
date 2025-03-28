import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddBankPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.add_bank),
      ),
      body: Center(
        child: Text(
          AppLocalizations.of(context)!.inside_add_bank,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
