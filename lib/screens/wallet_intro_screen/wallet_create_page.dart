import 'package:deus_mobile/statics/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../core/widgets/back_button.dart';
import '../../infrastructure/wallet_setup/wallet_setup_provider.dart';
import '../../models/wallet/wallet_setup.dart';
import 'widgets/confirm_mnemonic.dart';
import 'widgets/display_mnemonic.dart';

class WalletCreatePage extends HookWidget {

  static const String url = '/createWallet';

  WalletCreatePage(this.title);

  final String title;

  Widget build(BuildContext context) {
    var store = useWalletSetup(context);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: BackButtonWithText(
          onPressed: store.state.step == WalletCreateSteps.display
              ? () => Navigator.pop(context)
              : () => store.goto(WalletCreateSteps.display),
        ),
        backgroundColor: Color(MyColors.Background),
        centerTitle: true,
        title: Text(
          title,
          style: TextStyle(fontSize: 25),
        ),
      ),
      body: store.state.step == WalletCreateSteps.display
          ? DisplayMnemonic(
              mnemonic: store.state.mnemonic,
              onNext: () async {
                store.goto(WalletCreateSteps.confirm);
              },
            )
          : ConfirmMnemonic(
              mnemonic: store.state.mnemonic,
              errors: store.state.errors.toList(),
              onConfirm: !store.state.loading
                  ? (confirmedMnemonic) async {
                      if (await store.confirmMnemonic(confirmedMnemonic)) {
                        Navigator.of(context).popAndPushNamed("/");
                      }
                    }
                  : null,
              onGenerateNew: !store.state.loading
                  ? () async {
                      store.generateMnemonic();
                      store.goto(WalletCreateSteps.display);
                    }
                  : null,
            ),
    );
  }
}
