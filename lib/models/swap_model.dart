

import 'package:deus/models/token.dart';

class SwapModel{
  Token from;
  Token to;
  double fromValue = 0;
  double toValue = 0;
  double slippage;
  bool approved;


  SwapModel(from ,to){
    this.slippage = 0.5;
    this.approved = false;
    this.from = from;
    this.to = to;
  }


}