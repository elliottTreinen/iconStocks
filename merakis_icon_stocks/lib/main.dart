import 'dart:core';
import 'dart:async';
import 'package:flutter/material.dart';
import 'stock_widgets.dart';
import 'portfolio.dart';

//this seems like a really inefficient way to gather this data, but there's
//no way to iterate through the Icons class and I want to hand pick which
//ones are used so it's what I'm going with.

List<StockCard> cards = [];

void main() {
  initStocks();
  cards.length = stocks.length;
  for(int i = 0; i < stocks.length; i++){
    cards[i] = StockCard(stock: stocks[i]);
  }
  new Timer.periodic(Duration(seconds:1), (timer) { updateMarket(); });
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Icon Stocks',
      theme: ThemeData(
        primaryColor: Colors.grey[900],
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.grey[50],
          foregroundColor: Colors.black,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Icon Stocks'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title, style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                child: ListView.builder(
                  itemExtent: 250,
                  itemBuilder: (context, index){
                    //Simulating infinite content for the builder to meet the
                    //"infinite scrolling" requirement
                    return cards[index % cards.length];
                  },
                ),
              ),
            ),

            //portfolio button
            GestureDetector(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PortfolioScreen()),
                );
              },
              child: Container(
                height: 90,
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(10)),
                          color: Colors.grey[900],
                        ),
                        height: double.infinity,
                        child: Column(
                          children: <Widget>[
                            Text('Portfolio', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
                            Text('Portfolio Value: 0', style: TextStyle(fontSize: 15, color: Colors.white)),
                            Text('Bits Balance: 0', style: TextStyle(fontSize: 15, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(topRight: Radius.circular(10)),
                          color: Colors.green[600],
                        ),
                        height: double.infinity,
                        child: Icon(Icons.edit, size: 70, color: Colors.white),
                      ),
                    ),
                  ]
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
