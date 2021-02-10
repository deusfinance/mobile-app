

class SwapModel{
  dynamic from;
  dynamic to;
  double slippage;
  bool isMaxSelected;
  bool approved;


  SwapModel(){
    slippage = 0;
    approved = false;
  }

  setFrom(dynamic from){
    this.from = from;
  }

  setTo(dynamic to){
    this.to = to;
  }

}