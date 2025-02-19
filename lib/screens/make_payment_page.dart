import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MakePaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.make_payment),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          AppLocalizations.of(context)!.inside_make_payment,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
