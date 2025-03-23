import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MakePaymentPage extends StatelessWidget {
  final String? name;
  final int? amount;

  const MakePaymentPage({Key? key, this.name, this.amount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.make_payment),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.inside_make_payment,
              style: TextStyle(fontSize: 18),
            ),
            if (name != null) Text("Recipient: $name", style: TextStyle(fontSize: 16)),
            if (amount != null) Text("Amount: ₹$amount", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
