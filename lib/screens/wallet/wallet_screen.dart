import 'package:deus_mobile/core/widgets/default_screen/default_screen.dart';
import 'package:deus_mobile/statics/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/wallet_cubit.dart';
import 'cubit/wallet_state.dart';

class WalletScreen extends StatefulWidget {
  static const route = "/wallet";

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletCubit, WalletState>(builder: (context, state) {
      if (state is WalletLoadingState) {
        return DefaultScreen(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      } else if (state is WalletErrorState) {
        return DefaultScreen(
          child: Center(
            child: Icon(Icons.refresh, color: MyColors.White),
          ),
        );
      } else {
        return DefaultScreen(child: _buildBody(state));
      }
    });
  }

  Widget _buildBody(WalletState state) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _navbar(),
          _diagram(),
          _assets()
        ],
      ),
    );
  }

  Widget _navbar() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Portfilio"),
          Text("Manage Transactions")
        ],
      ),
    );
  }

  Widget _diagram() {
    return Container();
  }

  Widget _assets() {
    return Container();
  }
}
