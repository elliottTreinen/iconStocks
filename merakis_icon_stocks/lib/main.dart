import 'dart:core';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'stock_market.dart';

//This app makes use of the simulated stock market tools in stock_market.dart
//Made by: Elliott Treinen

void main() {
	initStocks(); //set up stock market
	new Timer.periodic(Duration(seconds:1), (timer) { updateMarket(); });//set stock market to update every second
	runApp(MyApp());
}



class MyApp extends StatelessWidget {
	// This widget is the root of your application.
	@override
	Widget build(BuildContext context) {
		SystemChrome.setPreferredOrientations([
			DeviceOrientation.portraitUp,
		]);
		return MaterialApp(
			title: 'Icon Stocks',
			theme: ThemeData(
				primaryColor: Colors.black,
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
			backgroundColor: Colors.white,
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
									itemExtent: 200,
									itemBuilder: (context, index){
										//Simulating infinite content for the builder to meet the
										//"infinite scrolling" requirement
										return cards[index % cards.length];
									},
								),
							),
						),
						PortfolioBar(),
					],
				),
			),
		);
	}
}