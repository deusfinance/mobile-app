import 'package:deus_mobile/core/util/clipboard.dart';
import 'package:deus_mobile/core/widgets/grey_outline_button.dart';
import 'package:deus_mobile/core/widgets/raised_gradient_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class DisplayMnemonic extends HookWidget {
  DisplayMnemonic({this.mnemonic, this.onNext});

  final String mnemonic;
  final Function onNext;
  final darkGrey = Color(0xFF1C1C1C);
  final borderColor = Color(0xFF282828);

  final LinearGradient button_gradient = LinearGradient(colors: [Color(0xFF0779E4), Color(0xFF1DD3BD)]);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Stack(
        children: [
          _buildHeader(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 15, bottom: 5),
                child: Text(
                  'Seed Phrase',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              _buildSeedPhraseContainer(),
              SizedBox(
                height: 15,
              ),
              _buildButtons()
            ],
          ),
        ],
      ),
    );
  }

  Container _buildSeedPhraseContainer() {
    return Container(
      padding: EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 30),
      decoration: BoxDecoration(
          border: Border.all(color: borderColor), borderRadius: BorderRadius.circular(10), color: darkGrey),
      child: Text(
        this.mnemonic,
        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 15),
      ),
    );
  }

  Row _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        RaisedGradientButton(
          label: 'COPY',
          onPressed: () async {
            print("copy...");
            await copyToClipBoard(this.mnemonic);
            print("copied :)");
          },
          gradient: button_gradient,
        ),
        SizedBox(width: 10),
        GreyOutlineButton(
          label: 'NEXT',
          onPressed: this.onNext,
        ),
      ],
    );
  }

  Column _buildHeader() {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Text(
            "write down your seed phrase on a piece of paper and keep it safe. This is the only way to recover your funds.",
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
