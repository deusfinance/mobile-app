import 'package:deus/data_source/currency_data.dart';
import 'package:deus/models/crypto_currency.dart';
import 'package:flutter/material.dart';

import '../../statics/old_my_colors.dart';
import 'svg.dart';

enum Direction { from, to }

//TODO (@CodingDavid8) use cubit instead of StatefulWidget
class SwapField extends StatefulWidget {
  final Direction direction;
  final double balance;

  //TODO (@CodingDavid8): Replace with meta-class so it can be used for tokens and stocks.
  final CryptoCurrency initialCurrency;
  const SwapField({
    Key key,
    this.direction,
    this.balance,
    this.initialCurrency,
  }) : super(key: key);

  @override
  _SwapFieldState createState() => _SwapFieldState();
}

class _SwapFieldState extends State<SwapField> {
  final controller = TextEditingController(text: '150');
  CryptoCurrency selectedCurrency;

  @override
  void initState() {
    super.initState();
    selectedCurrency = widget.initialCurrency;
  }

  @override
  Widget build(BuildContext context) {
    const _kPadding = 12.0;

    final balance = widget.balance;
    return Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Colors.black, width: 1)),
        color: const Color(0xFF242424),
        child: Padding(
          padding: const EdgeInsets.only(left: _kPadding, right: _kPadding, bottom: _kPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _buildDirectionAndBalance(balance),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _buildTextField(),
                  if (widget.direction == Direction.from) _buildMaxButton(balance),
                  // Spacer(),
                  Container(
                    height: 50,
                    width: 120,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                          icon: PlatformSvg.asset('images/icons/chevron_down.svg'),
                          value: selectedCurrency,
                          items: CurrencyData.all
                              .map((currency) => DropdownMenuItem<CryptoCurrency>(
                                  value: currency,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      currency.logoPath.showImage(size: 25),
                                      const SizedBox(width: 5),
                                      Text(currency.shortName, style: const TextStyle(fontSize: 25, height: 1.5))
                                    ],
                                  )))
                              .toList(),
                          onChanged: (c) => selectedCurrency = c),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              const Color(0xFF5BCCBD).withOpacity(0.149),
              const Color(0xFF61C0BF).withOpacity(0.149),
              const Color(0xFF55BCC8).withOpacity(0.149),
              const Color(0xFF69CFB8).withOpacity(0.149)
            ]),
            border: Border.all(color: MyColors.primary),
            borderRadius: BorderRadius.circular(6)),
        child: const Text(
          'MAX',
          textAlign: TextAlign.center,
          style: TextStyle(height: 1.5),
        ),
      ),
    ));
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
                style: const TextStyle(fontSize: 30, height: 0.8))));
  }

  Widget _buildDirectionAndBalance(double balance) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
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
