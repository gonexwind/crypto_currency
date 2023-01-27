import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

import '../helper/currency_helper.dart';
import '../model/coin_model.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key, required this.coin}) : super(key: key);
  final CoinModel coin;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isLoading = true;
  bool isFirstTime = true;
  List<FlSpot> flSpotList = [];
  double minX = 0;
  double minY = 0;
  double maxX = 0;
  double maxY = 0;

  void getChartData(String days) async {
    if (isFirstTime) {
      isFirstTime = false;
    } else {
      setState(() {
        isLoading = true;
      });
    }
    String api =
        'https://api.coingecko.com/api/v3/coins/${widget.coin.id}/market_chart?vs_currency=idr&days=$days';
    final response = await http.get(Uri.parse(api));
    if (response.statusCode == 200) {
      Map<String, dynamic> result = json.decode(response.body);
      List rawList = result['prices'];
      List<List> chartData = rawList.map((e) => e as List).toList();
      List<PriceAndTime> priceAndTimeList = chartData
          .map((e) => PriceAndTime(time: e[0] as int, price: e[1] as double))
          .toList();
      flSpotList = [];
      for (var chart in priceAndTimeList) {
        flSpotList.add(FlSpot(chart.time.toDouble(), chart.price));
      }
      minX = priceAndTimeList.first.time.toDouble();
      maxX = priceAndTimeList.last.time.toDouble();
      priceAndTimeList.sort((a, b) => a.price.compareTo(b.price));
      minY = priceAndTimeList.first.price;
      maxY = priceAndTimeList.last.price;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getChartData('1');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.coin.name!)),
      body: isLoading == false
          ? Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${widget.coin.name} Price'),
                    Text(
                      CurrencyHelper.idr(widget.coin.currentPrice!),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${widget.coin.priceChangePercentage24h} %',
                      style: TextStyle(color: Colors.red),
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      height: 250,
                      child: Expanded(
                        child: LineChart(
                          LineChartData(
                            minX: minX,
                            minY: minY,
                            maxX: maxX,
                            maxY: maxY,
                            titlesData: FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(
                              getDrawingHorizontalLine: (value) =>
                                  FlLine(strokeWidth: 0),
                              getDrawingVerticalLine: (value) =>
                                  FlLine(strokeWidth: 0),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: flSpotList,
                                dotData: FlDotData(show: false),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () => getChartData('1'),
                          child: Text('1D'),
                        ),
                        ElevatedButton(
                          onPressed: () => getChartData('15'),
                          child: Text('15D'),
                        ),
                        ElevatedButton(
                          onPressed: () => getChartData('30'),
                          child: Text('30D'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}

class PriceAndTime {
  late int time;
  late double price;

  PriceAndTime({required this.time, required this.price});
}
