

import 'package:deus_mobile/models/token.dart';

class SwapModel{
  Token from;
  Token to;
  double slippage;
  bool approved;


  SwapModel(from ,to){
    this.slippage = 0.5;
    this.approved = true;
    this.from = from;
    this.to = to;
  }


}