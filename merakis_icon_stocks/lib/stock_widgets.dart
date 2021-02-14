import 'package:flutter/material.dart';

class StockCard extends StatelessWidget {
  StockCard({Key key, this.icon, this.price, this.owned=0}) : super(key: key);

  final IconData icon;
  final int price;
  final int owned;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)) ,
        color: Colors.white,
      ),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Icon(
              icon,
              color: Colors.grey[900],
              size: 70.0,
            ),

            //Current Price
            Text.rich(
              TextSpan(
                children: <TextSpan>[
                  TextSpan(text: price.toString(), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 40)),
                  TextSpan(text: 'bits', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 20, color: Colors.grey)),
                ],
              )
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
            ),
          ],
        ),
      ),
    );
  }
}