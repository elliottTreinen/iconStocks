import 'dart:core';
import 'dart:async';
import 'package:flutter/material.dart';
import 'stock_widgets.dart';

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
  new Timer.periodic(Duration(seconds:5), (timer) { updateMarket(); });
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
      backgroundColor: Colors.grey[700],
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView.builder(
          itemExtent: 110,
          itemBuilder: (context, index){
            //Simulating infinite content for the builder to meet the
            //"infinite scrolling" requirement
            return cards[index % cards.length];
          },
        )
      ),
    );
  }
}
