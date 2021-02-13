import 'package:deus/statics/styles.dart';
import 'package:flutter/material.dart';

import '../../models/crypto_currency.dart';
import '../../models/stock.dart';
import '../../models/token.dart';
import '../../statics/old_my_colors.dart';
import 'svg.dart';
import 'token_selector/currency_selector_screen/currency_selector_screen.dart';
import 'token_selector/stock_selector_screen/stock_selector_screen.dart';

enum Direction { from, to }

//TODO (@CodingDavid8) use cubit instead of StatefulWidget
///Field where you can enter the amount of tokens and select another token.
class SwapField<T extends Token> extends StatefulWidget {
  final Direction direction;
  final double balance;

  //TODO (@CodingDavid8): Replace with meta-class so it can be used for tokens and stocks.
  final T initialToken;

  const SwapField({
    Key key,
    this.direction,
    this.balance,
    this.initialToken,
  }) : super(key: key);

  @override
  _SwapFieldState createState() => _SwapFieldState<T>();
}

class _SwapFieldState<T extends Token> extends State<SwapField> {
  final controller = TextEditingController(text: '0.0');
  T selectedToken;

  @override
  void initState() {
    super.initState();
    selectedToken = widget.initialToken;
  }

  @override
  Widget build(BuildContext context) {
    final balance = widget.balance;
//    return Card(
//        shape: RoundedRectangleBorder(
//            borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Colors.black, width: 1)),
//        color: const Color(0xFF242424),
//        child: Padding(
//          padding: const EdgeInsets.only(left: _kPadding, right: _kPadding, bottom: _kPadding),
//          child: Column(
//            crossAxisAlignment: CrossAxisAlignment.start,
//            mainAxisAlignment: MainAxisAlignment.start,
//            children: <Widget>[
//              _buildDirectionAndBalance(balance),
//              Row(
//                mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                children: <Widget>[
//                  _buildTextField(),
//                  if (widget.direction == Direction.from) _buildMaxButton(balance),
//                  // Spacer(),
//                  Container(height: 50, width: 120, child: _buildTokenSelection()),
//                ],
//              ),
//            ],
//          ),
//        ));

    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: MyStyles.darkWithBorderDecoration,
      child: Column(
        children: [
          _buildDirectionAndBalance(balance),
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
                    _buildMaxButton(balance),
                  _buildTokenSelection()
//                  Container(
//                    decoration: BoxDecoration(
//                        borderRadius: BorderRadius.circular(12.0),
//                        color: Color(MyColors.Cyan),
//                        border: Border.all(
//                            color: Color(MyColors.White), width: 1.0)),
//                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                    margin: EdgeInsets.only(right: 8.0),
//                    child: Text("MAX", style: MyStyles.whiteSmallTextStyle),
//                  ),
//                  Container(
//                    margin: EdgeInsets.only(right: 8),
//                    child: CircleAvatar(
//                      radius: 15.0,
//                      backgroundColor: Colors.amber,
//                    ),
//                  ),
//                  Text(
//                    "DAI",
//                    style: MyStyles.whiteMediumTextStyle,
//                  ),
//                  Icon(
//                    Icons.keyboard_arrow_down,
//                    color: Color(MyColors.White),
//                    size: 35.0,
//                  )
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
          if (selectedToken == null) {
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
          if (_selectedToken != null)
            setState(() {
              selectedToken = _selectedToken;
            });
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
            Text(
                selectedToken != null
                    ? selectedToken.shortName
                    : "select asset",
                style: MyStyles.whiteMediumTextStyle),
            const SizedBox(width: 10),
            PlatformSvg.asset('images/icons/chevron_down.svg'),
          ],
        ));
  }

  Widget _buildMaxButton(double balance) {
    return Flexible(
      child: InkWell(
        onTap: () {
          setState(() {
            controller.text = balance.toString();
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
            height: 30,
            child: TextFormField(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
                controller: controller,
                keyboardType: TextInputType.number,
                style: MyStyles.lightWhiteMediumTextStyle)));
  }

  Widget _buildDirectionAndBalance(double balance) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.direction.toString().replaceAll('Direction.', ''),
          style: MyStyles.lightWhiteSmallTextStyle,
        ),
        Text(
          'Balance: ${balance % 1 == 0 ? balance.round() : balance}',
          style: MyStyles.lightWhiteSmallTextStyle,
        ),
      ],
    );
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            widget.direction.toString().replaceAll('Direction.', ''),
            style: TextStyle(color: MyColors.primary.withOpacity(0.75)),
          ),
          Text(
            'Balance: ${balance % 1 == 0 ? balance.round() : balance}',
            style: TextStyle(color: MyColors.primary.withOpacity(0.75)),
          )
        ]);
  }
}
