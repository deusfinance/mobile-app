

import 'package:deus_mobile/models/token.dart';

class SwapModel{
  Token from;
  Token to;
  double slippage;

  SwapModel(from ,to){
    this.slippage = 0.5;
    this.from = from;
    this.to = to;
  }


}