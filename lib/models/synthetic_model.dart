
enum SelectionMode { none, long, short }
enum SyntheticState { closedMarket, openMarket, loading, timeRequired }

class SyntheticModel{
  SelectionMode selectionMode;
  SyntheticState syntheticState;


  SyntheticModel(){
    this.selectionMode = SelectionMode.none;
    this.syntheticState = SyntheticState.loading;
  }

}