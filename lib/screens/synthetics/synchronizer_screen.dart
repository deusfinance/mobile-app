import 'dart:ui';

import 'package:deus/core/util/responsive.dart';
import 'package:deus/data_source/currency_data.dart';
import 'package:deus/data_source/stock_data.dart';
import 'package:flutter/material.dart';

import '../../core/widgets/filled_gradient_selection_button.dart';
import '../../core/widgets/selection_button.dart';
import '../../core/widgets/unicorn_outline_container.dart';
import '../../core/widgets/svg.dart';
import '../../core/widgets/key_value_string.dart';
import '../../core/widgets/swap_field.dart';
import '../../statics/old_my_colors.dart';
import 'market_timer.dart';

//TODO (@CodingDavid8) use Cubit instead of StatefulWidget
enum SynchronizerStates { closedMarket, openMarket, loading, timeRequired }
enum SelectionMode { none, long, short }

class SynchronizerScreen extends StatefulWidget {
  static const String url = '/synchronizer';

  static const kPadding = 8.0;
  static const kGradient = LinearGradient(colors: [Color(0xFF0779E4), Color(0xFFEA2C62)]);

  @override
  _SynchronizerScreenState createState() => _SynchronizerScreenState();
}

class _SynchronizerScreenState extends State<SynchronizerScreen> {
  SynchronizerStates _sychronizerState = SynchronizerStates.closedMarket;
  SelectionMode selectionState = SelectionMode.none;

  @override
  Widget build(BuildContext context) {
    return _sychronizerState != SynchronizerStates.loading
        ? _buildBody(context)
        : const Center(child: CircularProgressIndicator());
    // Scaffold(
    //     backgroundColor: Theme.of(context).backgroundColor,
    //     // appBar: MyAppbar(),
    //     body: _sychronizerState != SynchronizerStates.loading
    //         ? _buildBody(context)
    //         : const Center(
    //             child: CircularProgressIndicator(),
    //           ));
  }

  SingleChildScrollView _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: SynchronizerScreen.kPadding),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 30),
              _buildUserInput(context),
              _buildSynchronizerCap(),
              _buildMarketTimer()
            ],
          )),
    );
  }

  Widget _buildSynchronizerCap() {
    return UnicornOutlineContainer(
      radius: 10,
      strokeWidth: 1,
      gradient: SynchronizerScreen.kGradient,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: SynchronizerScreen.kPadding * 2, vertical: SynchronizerScreen.kPadding * 2),
        width: getScreenWidth(context) - (SynchronizerScreen.kPadding * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Personal Synchronizer Cap', style: TextStyle(fontSize: 12, height: 1)),
            const SizedBox(height: 13),
            Container(
                width: getScreenWidth(context) - (SynchronizerScreen.kPadding * 4),
                child: _buildLinearGradientProgressIndicator(0.3)),
            const SizedBox(height: 13),
            Text('245.24 / 2535.53', style: TextStyle(fontSize: 15, height: 1))
          ],
        ),
      ),
    );
  }

  Widget _buildLinearGradientProgressIndicator(value) {
    return Container(
      width: getScreenWidth(context) - (SynchronizerScreen.kPadding * 4),
      height: 10,
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF464646))),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: (getScreenWidth(context) - (SynchronizerScreen.kPadding * 4)) * value,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(colors: [Color(0xFFEA2C62), Color(0xFF0779E4)])),
        ),
      ),
    );
  }

  Widget _buildMarketTimer() {
    return SizedBox(
      width: getScreenWidth(context) - (SynchronizerScreen.kPadding * 2),
      child: MarketTimer(
        timerColor:
            //TODO: add colors to my_colors.dart (.red and .green)
            _sychronizerState == SynchronizerStates.openMarket ? const Color(0xFF00D16C) : const Color(0xFFD40000),
        onEnd: () {
          setState(() {
            _sychronizerState == SynchronizerStates.openMarket
                ? _sychronizerState = SynchronizerStates.closedMarket
                : _sychronizerState = SynchronizerStates.closedMarket;
          });
        },
        label: _sychronizerState == SynchronizerStates.closedMarket ? 'UNTIL TRADING OPENS' : 'UNTIL TRADING CLOSES',
      ),
    );
  }

  Widget _buildUserInput(BuildContext context) {
    return UnicornOutlineContainer(
      strokeWidth: 1,
      radius: 10,
      gradient: SynchronizerScreen.kGradient,
      child: Container(
        width: getScreenWidth(context) - (SynchronizerScreen.kPadding * 2),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            children: [
              const SwapField(direction: Direction.from, balance: 999, initialToken: CurrencyData.eth),
              const SizedBox(height: 12),
              Center(child: PlatformSvg.asset('images/icons/arrow_down.svg')),
              const SizedBox(height: 12),
              SwapField(direction: Direction.to, balance: 0, initialToken: StockData.tesla),
              const SizedBox(height: 18),
              _buildModeButtons(),
              const SizedBox(height: 16),
              KeyValueString('Price', '0.0038 ETH per DEUS ',
                  keyColor: MyColors.primary.withOpacity(0.75),
                  valueColor: MyColors.primary.withOpacity(0.75),
                  valueSuffix: PlatformSvg.asset('images/icons/exchange.svg', height: 16, width: 16)),
              const SizedBox(
                height: 16,
              ),
              _sychronizerState == SynchronizerStates.openMarket && selectionState != SelectionMode.none
                  //TODO (@CodingDavid8): Check for amount entered
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: SynchronizerScreen.kPadding / 2),
                      child: FilledGradientSelectionButton(
                        label: selectionState == SelectionMode.long ? 'Sync' : 'Sync (Sell)',
                        onPressed: () {},
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: SynchronizerScreen.kPadding / 2),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: SynchronizerScreen.kPadding * 2,
                        ),
                        width: double.infinity,
                        decoration:
                            BoxDecoration(borderRadius: BorderRadius.circular(10), color: const Color(0xFF242424)),
                        child: Text(
                          _sychronizerState == SynchronizerStates.closedMarket
                              ? 'MARKETS ARE CLOSED'
                              : _sychronizerState == SynchronizerStates.timeRequired
                                  ? 'YOU NEED TIME TOKENS'
                                  : 'ENTER AN AMOUNT',
                          style: TextStyle(fontSize: 25, color: MyColors.background.withOpacity(0.5), height: 1),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }

  Container _buildModeButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SynchronizerScreen.kPadding / 2),
      child: Row(children: [
        Expanded(child: _buildLongButton()),
        const SizedBox(width: 8),
        Expanded(child: _buildShortButton()),
      ]),
    );
  }

  Widget _buildShortButton() {
    return SelectionButton(
      label: 'SHORT',
      onPressed: (bool selected) {
        setState(() {
          selected ? selectionState = SelectionMode.none : selectionState = SelectionMode.short;
        });
      },
      selected: selectionState == SelectionMode.short,
    );
  }

  Widget _buildLongButton() {
    return SelectionButton(
      label: 'LONG',
      onPressed: (bool selected) {
        setState(() {
          selected ? selectionState = SelectionMode.none : selectionState = SelectionMode.long;
        });
      },
      selected: selectionState == SelectionMode.long,
    );
  }
}
