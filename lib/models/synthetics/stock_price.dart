

class StockPrice{
  StockPriceDetail long;
  StockPriceDetail short;

  StockPrice(this.long, this.short);
}

class StockPriceDetail{
  double price;
  double fee;

  StockPriceDetail(this.price, this.fee);
}