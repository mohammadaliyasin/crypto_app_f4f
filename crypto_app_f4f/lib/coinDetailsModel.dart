
class CoinDetailsModels {
 late String id;
 late String symbol;
 late String name;
 late String image;
 late double currentPrice;
 late double priceChange24h;

  var priceChangePercentage24h;

  CoinDetailsModels(
      {required this.id,
      required this.symbol,
      required this.name,
      required this.image,
      required this.currentPrice,
      required this.priceChange24h});

  CoinDetailsModels.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    symbol = json['symbol'];
    name = json['name'];
    image = json['image'];
    currentPrice = json['current_price'].toDouble();
    priceChangePercentage24h = json['price_change_percentage_24h'];
  }



 
}
