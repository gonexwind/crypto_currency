class CoinModel {
  CoinModel({
    this.id,
    this.symbol,
    this.name,
    this.image,
    this.currentPrice,
    this.priceChangePercentage24h,
  });

  CoinModel.fromJson(dynamic json) {
    id = json['id'];
    symbol = json['symbol'];
    name = json['name'];
    image = json['image'];
    currentPrice = json['current_price'].toDouble();
    priceChangePercentage24h = json['price_change_percentage_24h'];
  }

  String? id;
  String? symbol;
  String? name;
  String? image;
  double? currentPrice;
  double? priceChangePercentage24h;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['symbol'] = symbol;
    map['name'] = name;
    map['image'] = image;
    map['current_price'] = currentPrice;
    map['price_change_percentage_24h'] = priceChangePercentage24h;
    return map;
  }
}
