import 'package:flutter/material.dart';
import 'stock_widgets.dart';

class StockPage extends StatefulWidget {
  StockPage({Key key, this.stock}) : super(key: key);
  final IconStock stock;
  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        centerTitle: true,
        title: Text('Icon Stocks', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),),
      ),
      body: Icon(widget.stock.icon),
    );
  }
}

