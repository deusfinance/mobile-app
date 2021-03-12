import 'dart:ui';

import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'form/paper_form.dart';
import 'form/paper_input.dart';
import 'form/paper_validation_summary.dart';
import '../../../core/widgets/raised_gradient_button.dart';
import '../../../models/wallet/wallet_setup.dart';

class ImportWalletForm extends HookWidget {
  ImportWalletForm({this.onImport, this.errors});

  final Function(WalletImportType type, String value) onImport;
  final List<String> errors;
  static const indexMap = {0: WalletImportType.mnemonic, 1: WalletImportType.privateKey};

  @override
  Widget build(BuildContext context) {
    final importType = useState(WalletImportType.mnemonic);
    final inputController = useTextEditingController();

    final LinearGradient buttonGradient = LinearGradient(colors: [Color(0xFF0779E4), Color(0xFF1DD3BD)]);

    void changeSelections(int index) {
      importType.value = indexMap[index];
    }

    return Center(
      child: Container(
        margin: EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: PaperForm(
            actionButtons: <Widget>[
              RaisedGradientButton(
                gradient: buttonGradient,
                label: 'IMPORT',
                onPressed:
                    this.onImport != null ? () => this.onImport(importType.value, inputController.value.text) : null,
              )
            ],
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ToggleButtons(
                    borderColor: Color(MyColors.Background),
                    selectedBorderColor: Color(MyColors.Background),
                    fillColor: Colors.transparent,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: _buildImportOption('Seed', WalletImportType.mnemonic, importType.value)),
                      _buildImportOption('Private key', WalletImportType.privateKey, importType.value)
                    ],
                    isSelected: [
                      importType.value == WalletImportType.mnemonic,
                      importType.value == WalletImportType.privateKey
                    ],
                    onPressed: changeSelections,
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 15, bottom: 5),
                    child: Text(
                      importType.value == WalletImportType.privateKey ? 'Private Key' : 'Seed Phrase',
                      style: TextStyle(color: Colors.white.withOpacity(0.5)),
                    ),
                  ),
                  Visibility(
                      child: fieldForm(
                          label: 'Private Key', hintText: 'Type your private key', controller: inputController),
                      visible: importType.value == WalletImportType.privateKey),
                  Visibility(
                      child: fieldForm(
                          label: 'Seed phrase', hintText: 'Type your seed phrase', controller: inputController),
                      visible: importType.value == WalletImportType.mnemonic),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Text _buildImportOption(String label, WalletImportType type, WalletImportType currentType) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 15,
        color: Colors.transparent,
        decoration: currentType == type ? TextDecoration.underline : null,
        decorationColor: Colors.white,
        shadows: [Shadow(color: Colors.white, offset: Offset(0, -5))],
      ),
    );
  }

  final darkGrey = Color(0xFF1C1C1C);

  Widget fieldForm({
    String label,
    String hintText,
    TextEditingController controller,
  }) {
    return Column(
      children: <Widget>[
        PaperValidationSummary(errors),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MyStyles.cardRadiusSize),
            color: darkGrey,
          ),
          child: PaperInput(
            hintText: hintText,
            maxLines: 3,
            controller: controller,
          ),
        ),
      ],
    );
  }
}
