// ignore: file_names
import 'dart:convert';
import 'dart:ui';
import 'package:crypto_app_f4f/appTheme.dart';
import 'package:crypto_app_f4f/coinDetailsModel.dart';
import 'package:crypto_app_f4f/homeScreen.dart';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

class CoinGraphScreen extends StatefulWidget {
  final CoinDetailsModels coinDetailsModels;
  const CoinGraphScreen({super.key, required this.coinDetailsModels});

  @override
  State<CoinGraphScreen> createState() => _CoinGraphScreenState();
}

class _CoinGraphScreenState extends State<CoinGraphScreen> {
  bool isLoading = true,
      isFirstTime = true,
      isDarkMode = AppTheme.isDarkModeEnabled;
  List<FlSpot> flSpotList = [];
  double minX = 0.0, minY = 0.0, maxX = 0.0, maxY = 0.0;
  @override
  void initState() {
    super.initState();
    getChartData("1");
  }

  void getChartData(String days) async {
    if (isFirstTime) {
      isFirstTime = false;
    } else {
      setState(() {
        isLoading = true;
      });
    }

    String apiUrl =
        "https://api.coingecko.com/api/v3/coins/${widget.coinDetailsModels.id}/market_chart?vs_currency=inr&days=$days";
    Uri uri = Uri.parse(apiUrl);
    final response = await http.get(uri);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // ignore: avoid_print
      print(response.body);

      Map<String, dynamic> result = json.decode(response.body);

      List rawList = result['prices'];

      List<List> chartData = rawList.map((e) => e as List).toList();

      List<PriceAndTime> priceAndTimeList = chartData
          .map((e) => PriceAndTime(price: e[1] as double, time: e[0] as int))
          .toList();
      flSpotList = [];

      for (var element in priceAndTimeList) {
        flSpotList.add(FlSpot(element.time.toDouble(), element.price));
      }

      minX = priceAndTimeList.first.time.toDouble();
      maxX = priceAndTimeList.last.time.toDouble();

      priceAndTimeList.sort(((a, b) => a.price.compareTo(b.price)));

      minY = priceAndTimeList.first.price;
      maxY = priceAndTimeList.last.price;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: 
            () => Navigator.pop(context, false),
          
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        title: Text(
          widget.coinDetailsModels.name,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
      ),
      body: isLoading == false
          ? SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        text: TextSpan(
                          text: "${widget.coinDetailsModels.name} Price\n",
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontSize: 18,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  "Rs.${widget.coinDetailsModels.currentPrice}\n",
                              style: TextStyle(
                                fontSize: 28,
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "${widget.coinDetailsModels.priceChangePercentage24h}%\n",
                              style: const TextStyle(
                                color: Colors.red,
                              ),
                            ),
                            TextSpan(
                              text: "Rs.$maxY\n",
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 150,
                  ),
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: LineChart(
                      LineChartData(
                        minX: minX,
                        minY: minY,
                        maxX: maxX,
                        maxY: maxY,
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          show: false,
                        ),
                        gridData: FlGridData(
                          getDrawingHorizontalLine: (value) {
                            return FlLine(strokeWidth: 0);
                          },
                          getDrawingVerticalLine: (value) {
                            return FlLine(strokeWidth: 0);
                          },
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
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            getChartData("1d");
                          },
                          child: const Text("1d"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            getChartData("15d");
                          },
                          child: const Text("15d"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            getChartData("30d");
                          },
                          child: const Text("30d"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

class PriceAndTime {
  late int time;
  late double price;

  PriceAndTime({
    required this.time,
    required this.price,
  });
}
