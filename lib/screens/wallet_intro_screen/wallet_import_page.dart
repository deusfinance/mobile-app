import 'package:deus_mobile/statics/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../core/widgets/back_button.dart';
import '../../infrastructure/wallet_setup/wallet_setup_provider.dart';
import '../../models/wallet/wallet_setup.dart';
import 'widgets/import_wallet_form.dart';

class WalletImportPage extends HookWidget {
  static const String url = '/importWallet';

  WalletImportPage(this.title);

  final String title;

  Widget build(BuildContext context) {
    final store = useWalletSetup(context);
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: BackButtonWithText(),
        backgroundColor: Color(MyColors.Background).withOpacity(1),
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
