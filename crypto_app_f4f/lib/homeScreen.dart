import 'dart:convert';
import 'package:crypto_app_f4f/appTheme.dart';
import 'package:crypto_app_f4f/coinGraphScreen.dart';
import 'package:crypto_app_f4f/updateProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'coinDetailsModel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String url =
      "https://api.coingecko.com/api/v3/coins/markets?vs_currency=inr&order=market_cap_desc&per_page=100&page=1&sparkline=false";

  String? name, email, age;

  bool isDarkMode = AppTheme.isDarkModeEnabled;

  bool isFirstTimeDataAccess = true;

  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  List<CoinDetailsModels> coinDetailsList = [];

  late Future<List<CoinDetailsModels>> coinDetailsFuture;

  @override
  void initState() {
    super.initState();
    getUserDetails();
    getCoinDetails();
    coinDetailsFuture = getCoinDetails();
  }

  void getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      name = prefs.getString('name') ?? "";
      email = prefs.getString('email') ?? "";
      age = prefs.getString('age') ?? "";
    });
  }

  Future<List<CoinDetailsModels>> getCoinDetails() async {
    Uri uri = Uri.parse(url);

    final response = await http.get(uri);

    if (response.statusCode == 200 || response.statusCode == 201) {
      List coinsData = json.decode(response.body);
      List<CoinDetailsModels> data =
          coinsData.map((e) => CoinDetailsModels.fromJson(e)).toList();

      return data;
    } else {
      return <CoinDetailsModels>[];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            _globalKey.currentState!.openDrawer();
          },
          icon: Icon(
            Icons.menu,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        // iconTheme: IconThemeData(
        //   color: isDarkMode ? Colors.black : Colors.white,
        // ),

        title: Text(
          "CryptoCurrency App",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                "Name:$name",
                style: TextStyle(
                  color: isDarkMode ? Colors.black : Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              accountEmail: Text(
                "Email:$email\nAge:$age",
                style: TextStyle(
                  color: isDarkMode ? Colors.black : Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              currentAccountPicture: Icon(
                Icons.account_circle,
                size: 70,
                color: isDarkMode ? Colors.black : Colors.white,
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateProfileScreen(),
                  ),
                );
              },
              leading: Icon(
                Icons.account_box,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              title: Text(
                "Update Profile",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ListTile(
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                setState(() {
                  isDarkMode = !isDarkMode;
                });
                AppTheme.isDarkModeEnabled = isDarkMode;
                await prefs.setBool('isDarkMod', isDarkMode);
              },
              leading: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              title: Text(
                isDarkMode ? "Light Mode" : "Dark Mode",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        child: FutureBuilder(
            future: coinDetailsFuture,
            builder:
                ((context, AsyncSnapshot<List<CoinDetailsModels>> snapshot) {
              if (snapshot.hasData) {
                if (isFirstTimeDataAccess) {
                  coinDetailsList = snapshot.data!;

                  isFirstTimeDataAccess = false;
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 40,
                        
                      ),
                      child: TextField(
                        style: TextStyle(
                           color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        onChanged: (query) {
                          List<CoinDetailsModels> searchResult =
                              snapshot.data!.where((element) {
                            String coinName = element.name;

                            bool isItemFound = coinName.contains(query);

                            return isItemFound;
                          }).toList();

                          setState(() {
                            coinDetailsList = searchResult;
                          });
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.search,
                            color: isDarkMode ? Colors.white : Colors.grey,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: isDarkMode ? Colors.white : Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          hintText: "Search for a coin",
                          hintStyle: TextStyle(
                            color: isDarkMode ? Colors.white : null,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: coinDetailsList.isEmpty
                          ? const Center(
                              child: Text("No Coin Found"),
                            )
                          : ListView.builder(
                              itemCount: coinDetailsList.length,
                              itemBuilder: (context, index) {
                                return coinDetails(
                                    coinDetailsList[index], context);
                              },
                            ),
                    ),
                  ],
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            })),
      ),
    );
  }
}

Widget coinDetails(CoinDetailsModels model, context) {
  var isDarkMode = AppTheme.isDarkModeEnabled;
  return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: ((context) => CoinGraphScreen(
                        coinDetailsModels: model,
                      ))));
        },
        leading:
            SizedBox(height: 50, width: 50, child: Image.network(model.image)),
        title: Text("${model.name}\n${model.symbol}",
            style: TextStyle(
              fontSize: 17,
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
            )),
        trailing: RichText(
          textAlign: TextAlign.right,
          text: TextSpan(
            text: "Rs.${model.currentPrice}\n",
            style: TextStyle(
              fontSize: 17,
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: "${model.priceChangePercentage24h}%",
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ));
}
