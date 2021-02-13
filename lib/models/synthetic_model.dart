
enum SelectionMode { none, long, short }
enum SyntheticState { closedMarket, openMarket, loading, timeRequired }

class SyntheticModel{
  dynamic from;
  dynamic to;
  SelectionMode selectionMode;
  SyntheticState syntheticState;
  bool isMaxSelected;


  SyntheticModel(){
    this.from = "DAI";
    this.selectionMode = SelectionMode.none;
    this.syntheticState = SyntheticState.loading;
  }

//  setFrom(dynamic from){
//    this.from = from;
//    if(from is Stock){
//      this.to = "DAI";
//    }
//  }
//
//  setTo(dynamic to){
//    this.to = to;
//    if(to is Stock){
//      this.from = "DAI";
//    }
//  }

}