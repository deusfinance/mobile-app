
import 'package:deus/models/stock.dart';

class SyntheticModel{
  static final String LONG = "LONG";
  static final String SHORT = "SHORT";
  dynamic from;
  dynamic to;
  String type;
  bool isMaxSelected;


  SyntheticModel(){
    this.from = "DAI";
    this.type = "";
  }

  setFrom(dynamic from){
    this.from = from;
    if(from is Stock){
      this.to = "DAI";
    }
  }

  setTo(dynamic to){
    this.to = to;
    if(to is Stock){
      this.from = "DAI";
    }
  }

}