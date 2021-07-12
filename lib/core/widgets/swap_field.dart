import 'package:deus_mobile/core/widgets/svg.dart';
import 'package:deus_mobile/data_source/sync_data/sync_data.dart';
import 'package:deus_mobile/locator.dart';
import 'package:deus_mobile/models/swap/crypto_currency.dart';
import 'package:deus_mobile/models/synthetics/stock.dart';
import 'package:deus_mobile/models/token.dart';
import 'package:deus_mobile/routes/navigation_service.dart';
import 'package:deus_mobile/screens/synthetics/synthetics_state.dart';
import 'package:deus_mobile/service/address_service.dart';
import 'package:deus_mobile/service/ethereum_service.dart';
import 'package:deus_mobile/statics/my_colors.dart';
import 'package:deus_mobile/statics/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum Direction { from, to }
enum TabPage { synthetics, swap }

//TODO (@CodingDavid8) use cubit instead of StatefulWidget

///Field where you can enter the amount of tokens and select another token.
// ignore: must_be_immutable
class SwapField<T extends Token> extends StatefulWidget {
  final Direction direction;
  void Function(T selectedToken)? tokenSelected;
  final TextEditingController? controller;
  String? selectAssetRoute;
  SyncData? syncData;
  final T? initialToken;

  SwapField(
      {Key? key,
      this.direction = Direction.from,
      this.controller,
      this.initialToken,
      this.tokenSelected,
      this.selectAssetRoute,
      this.syncData})
      : super(key: key);

  @override
  _SwapFieldState createState() => new _SwapFieldState<T>();
}

class _SwapFieldState<T extends Token> extends State<SwapField> {
  T? selectedToken;

  @override
  Widget build(BuildContext context) {
    selectedToken = widget.initialToken as T?;

    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: MyStyles.darkWithBorderDecoration,
      child: Column(
        children: [
          _buildDirectionAndBalance(),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTextField(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [if (widget.direction == Direction.from) _buildMaxButton(), _buildTokenSelection()],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTokenSelection() {
    return InkWell(
        onTap: () async {
          final _selectedToken = await locator<NavigationService>().navigateTo(widget.selectAssetRoute!, context, arguments: {"data": widget.syncData});
          if (_selectedToken != null) {
            setState(() {
              selectedToken = _selectedToken as T?;
              widget.tokenSelected!(selectedToken!);
            });
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            selectedToken != null
                ? selectedToken!.logoPath.showCircleImage(radius: 15)
                : CircleAvatar(radius: 15.0, backgroundColor: Colors.white70),
            const SizedBox(width: 5),
            _buildTokenName(),
            const SizedBox(width: 10),
            PlatformSvg.asset('images/icons/chevron_down.svg'),
          ],
        ));
  }

  Widget _buildMaxButton() {
    String balance = "0.0";
    if (selectedToken != null) {
      if (selectedToken is CryptoCurrency) {
        balance = (selectedToken as CryptoCurrency).balance;
      } else if (selectedToken is Stock) {
        Stock stock = selectedToken as Stock;
        balance = stock.mode == Mode.SHORT ? stock.shortBalance : stock.longBalance;
      }
    }
    return Flexible(
      child: InkWell(
        onTap: () async {
          setState(() {
            widget.controller!.text = balance;
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
              border: Border.all(color: MyColors.White),
              borderRadius: BorderRadius.circular(8)),
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
            // height: 50,
            child: TextFormField(
                autofocus: false,
                maxLines: 1,
                decoration: InputDecoration(
                  hintText: "0.0",
                  hintStyle: MyStyles.lightWhiteMediumTextStyle,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
                inputFormatters: [WhitelistingTextInputFormatter(new RegExp(r'([0-9]+([.][0-9]*)?|[.][0-9]+)'))],
                controller: widget.controller,
                keyboardType: TextInputType.number,
                style: MyStyles.whiteMediumTextStyle)));
  }

  Widget _buildDirectionAndBalance() {
    String balance = "0.0";
    if (selectedToken != null) {
      if (selectedToken is CryptoCurrency) {
        balance = (selectedToken as CryptoCurrency).balance;
      } else if (selectedToken is Stock) {
        Stock stock = selectedToken as Stock;
        if (stock.mode == Mode.SHORT) {
          balance = stock.shortBalance;
        } else {
          balance = stock.longBalance;
        }
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.direction.toString().replaceAll('Direction.', ''),
          style: MyStyles.lightWhiteSmallTextStyle,
        ),
        Text(
          'Balance: ${EthereumService.formatDouble(balance)}',
          style: MyStyles.lightWhiteSmallTextStyle,
        ),
      ],
    );
  }

  Widget _buildTokenName() {
    if (selectedToken != null) {
      if (selectedToken is CryptoCurrency) {
        return Text(selectedToken!.symbol, style: MyStyles.whiteMediumTextStyle);
      } else if (selectedToken is Stock) {
        Stock stock = selectedToken as Stock;
        if (stock.mode == Mode.SHORT) {
          return Text(stock.shortSymbol, style: MyStyles.whiteMediumTextStyle);
        } else {
          return Text(stock.longSymbol, style: MyStyles.whiteMediumTextStyle);
        }
      } else {
        return Text("---", style: MyStyles.whiteMediumTextStyle);
      }
    } else {
      return Text("select asset", style: MyStyles.whiteMediumTextStyle);
    }
  }
}
