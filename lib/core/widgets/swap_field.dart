import 'package:deus_mobile/service/ethereum_service.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/swap/crypto_currency.dart';
import '../../models/synthetics/stock.dart';
import '../../models/token.dart';
import '../../statics/old_my_colors.dart';
import 'svg.dart';
import 'token_selector/currency_selector_screen/currency_selector_screen.dart';
import 'token_selector/stock_selector_screen/stock_selector_screen.dart';

enum Direction { from, to }
enum TabPage { synthetics, swap }

//TODO (@CodingDavid8) use cubit instead of StatefulWidget
///Field where you can enter the amount of tokens and select another token.
// ignore: must_be_immutable
class SwapField<T extends Token> extends StatefulWidget {
  final Direction direction;
  void Function(T selectedToken) tokenSelected;
  final TextEditingController controller;
  final TabPage page;

  //TODO (@CodingDavid8): Replace with meta-class so it can be used for tokens and stocks.
  final T initialToken;

  SwapField({
    Key key,
    this.direction = Direction.from,
    this.controller,
    this.initialToken,
    this.tokenSelected,
    this.page,
  }) : super(key: key);

  @override
  _SwapFieldState createState() => new _SwapFieldState<T>();
}

class _SwapFieldState<T extends Token> extends State<SwapField> {
  T selectedToken;

  @override
  Widget build(BuildContext context) {
    selectedToken = widget.initialToken;

    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: MyStyles.darkWithBorderDecoration,
      child: Column(
        children: [
          _buildDirectionAndBalance(
              selectedToken != null ? selectedToken.balance : "0"),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTextField(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.direction == Direction.from)
                    _buildMaxButton(
                        selectedToken != null ? selectedToken.balance : "0"),
                  _buildTokenSelection()
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTokenSelection() {
    return GestureDetector(
        onTap: () async {
          MaterialPageRoute<Token> pushTo;
          if (widget.page != null && widget.page == TabPage.synthetics) {
            pushTo = MaterialPageRoute<Stock>(
                builder: (BuildContext _) => StockSelectorScreen());
          } else if (selectedToken == null) {
            pushTo = MaterialPageRoute<Stock>(
                builder: (BuildContext _) => StockSelectorScreen());
          } else if (selectedToken.runtimeType == Stock) {
            pushTo = MaterialPageRoute<Stock>(
                builder: (BuildContext _) => StockSelectorScreen());
          } else {
            pushTo = MaterialPageRoute<CryptoCurrency>(
                builder: (BuildContext _) => CurrencySelectorScreen());
          }
          //TODO (@CodingDavid8) Find agreement with @hookman2 on navigation service and improve routing
          final dynamic _selectedToken = await Navigator.push(context, pushTo);
          if (_selectedToken != null) {
            setState(() {
              selectedToken = _selectedToken;
              widget.tokenSelected(selectedToken);
            });
          } 
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            selectedToken != null
                ? selectedToken.logoPath.showCircleImage(radius: 15)
                : CircleAvatar(
                    radius: 15.0,
                    backgroundColor: Colors.white70,
                  ),
            const SizedBox(width: 5),
            Text(selectedToken != null ? selectedToken.symbol : "select asset",
                style: MyStyles.whiteMediumTextStyle),
            const SizedBox(width: 10),
            PlatformSvg.asset('images/icons/chevron_down.svg'),
          ],
        ));
  }

  Widget _buildMaxButton(String balance) {
    return Flexible(
      child: InkWell(
        onTap: () {
          setState(() {
            widget.controller.text = balance;
          });
        },
        child: Container(
          width: 40,
          height: 25,
          margin: EdgeInsets.only(right: MyStyles.mainPadding),
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                const Color(0xFF5BCCBD).withOpacity(0.149),
                const Color(0xFF61C0BF).withOpacity(0.149),
                const Color(0xFF55BCC8).withOpacity(0.149),
                const Color(0xFF69CFB8).withOpacity(0.149)
              ]),
              border: Border.all(color: MyColors.primary),
              borderRadius: BorderRadius.circular(6)),
          child: Align(
              alignment: Alignment.center,
              child: Text(
                "MAX",
                style: MyStyles.whiteSmallTextStyle,
              )),
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return Flexible(
        child: Container(
//            height: 30,
            child: TextFormField(
                autofocus: false,
                maxLines: 1,
//                onChanged: widget.onValueChange,
                decoration: InputDecoration(
                  hintText: "0.0",
                  hintStyle: MyStyles.lightWhiteMediumTextStyle,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
                inputFormatters: [
                  WhitelistingTextInputFormatter(
                      new RegExp(r'([0-9]+([.][0-9]*)?|[.][0-9]+)'))
                ],
                controller: widget.controller,
                keyboardType: TextInputType.number,
                style: MyStyles.whiteMediumTextStyle)));
  }

  Widget _buildDirectionAndBalance(String balance) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.direction.toString().replaceAll('Direction.', ''),
          style: MyStyles.lightWhiteSmallTextStyle,
        ),
        Text(
//          'Balance: ${balance % 1 == 0 ? balance.round() : balance}',
          'Balance: ${EthereumService.formatDouble(balance)}',
          style: MyStyles.lightWhiteSmallTextStyle,
        ),
      ],
    );
  }
}
