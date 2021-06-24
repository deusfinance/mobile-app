

import 'package:equatable/equatable.dart';

enum WalletSelectedTab {PORTFILIO, MANAGE_TRANSACTIONS}
abstract class WalletState extends Equatable {
  var database;

  @override
  List<Object> get props => [];
}

class WalletInitialState extends WalletState{

}

class WalletLoadingState extends WalletState{

}

class WalletErrorState extends WalletState{

}