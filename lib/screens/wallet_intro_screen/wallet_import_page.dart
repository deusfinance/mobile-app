import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../core/widgets/back_button.dart';
import '../../infrastructure/wallet_setup/wallet_setup_provider.dart';
import '../../models/wallet/wallet_setup.dart';
import 'widgets/wallet/import_wallet_form.dart';

class WalletImportPage extends HookWidget {
  WalletImportPage(this.title);

  final String title;

  Widget build(BuildContext context) {
    final store = useWalletSetup(context);
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: BackButtonWithText(
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          title,
          style: TextStyle(fontSize: 25),
        ),
      ),
      body: ImportWalletForm(
        errors: store.state.errors.toList(),
        onImport: !store.state.loading
            ? (type, value) async {
                switch (type) {
                  case WalletImportType.mnemonic:
                    if (!await store.importFromMnemonic(value)) return;
                    break;
                  case WalletImportType.privateKey:
                    if (!await store.importFromPrivateKey(value)) return;
                    break;
                  default:
                    break;
                }
                Navigator.of(context).popAndPushNamed("/");
              }
            : null,
      ),
    );
  }
}
