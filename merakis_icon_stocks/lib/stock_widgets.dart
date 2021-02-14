import 'package:flutter/material.dart';
import 'dart:math';

Random rng = new Random();

class IconStock{
  IconData icon;
  int price;
  int owned;
  bool liked;

  IconStock(IconData iconData){
    icon = iconData;
    price = 10 + rng.nextInt(191);
  }
}

class StockCard extends StatelessWidget {
  StockCard({Key key, this.icon, this.price, this.owned = 0}) : super(key: key);

  //final IconStock stock;
  final IconData icon;
  final int price;
  final int owned;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        height: 110,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //FIRST SECTION (ICON AND OWNED COUNTER)
            Expanded(
              flex: 8,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                  color: Colors.white,
                ),
                height: double.infinity,

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                  Icon(
                    icon,
                    color: Colors.grey[900],
                    size: 70.0,
                  ),

                  //Shares owned
                  Container(
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)) ,
                      color: Colors.black,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(),
                          children: <TextSpan>[
                            TextSpan(text: owned.toString(), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 30, color: Colors.white, height: 1)),
                            TextSpan(text: '\nOWNED', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 10, color: Colors.white, height: .8)),
                          ],
                        ),
                      ),
                    ),
                  )]
                ),
              ),
            ),

            //SECOND SECTION (PRICE)
            Expanded(
              flex: 6,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey,
                ),
                height: double.infinity,
                alignment: Alignment.center,
                child: Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(text: price.toString(), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 40)),
                      TextSpan(text: 'bits', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 20, color: Colors.white)),
                    ],
                  )
                ),
              ),
            ),

            //THIRD SECTION (LIKE)
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                  color: Colors.red[50],
                ),
                height: double.infinity,

                child: IconButton(
                  icon: Icon(Icons.favorite_outline, color: Colors.black26),
                  iconSize: 40,
                  onPressed: null
                ),
              ),
            ),
          ]
        )
    );
  }
}