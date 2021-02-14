import 'package:flutter/material.dart';
import 'dart:math';

Random rng = new Random();

final List<IconData> icons = [Icons.accessibility_new, Icons.accessible, Icons.account_balance, Icons.account_circle,
  Icons.add_shopping_cart, Icons.alarm, Icons.all_inbox, Icons.analytics, Icons.anchor, Icons.android, Icons.announcement,
  Icons.arrow_circle_down, Icons.arrow_circle_up, Icons.assignment, Icons.backup, Icons.bookmark, Icons.bug_report,
  Icons.build, Icons.calendar_today, Icons.card_membership, Icons.change_history, Icons.check_circle, Icons.chrome_reader_mode,
  Icons.class_, Icons.commute, Icons.copyright, Icons.dangerous, Icons.delete, Icons.donut_small, Icons.drag_indicator,
  Icons.dynamic_form, Icons.eco, Icons.event_seat, Icons.expand, Icons.face, Icons.favorite, Icons.fingerprint, Icons.extension,
  Icons.flight_takeoff, Icons.flaky, Icons.grade, Icons.home, Icons.hourglass_empty, Icons.horizontal_split, Icons.lock,
  Icons.language, Icons.lightbulb, Icons.lock_open, Icons.nightlife, Icons.nightlight_round, Icons.outlet, Icons.monetization_on,
  Icons.pan_tool, Icons.rowing, Icons.bluetooth, Icons.settings, Icons.mic, Icons.swipe, Icons.verified, Icons.view_in_ar,
  Icons.visibility, Icons.hearing, Icons.games, Icons.radio, Icons.circle, Icons.speed, Icons.business, Icons.dialer_sip,
  Icons.nat, Icons.qr_code, Icons.sentiment_satisfied, Icons.sentiment_dissatisfied, Icons.vpn_key, Icons.biotech, Icons.bolt,
  Icons.insights, Icons.gesture, Icons.content_cut, Icons.push_pin, Icons.flag, Icons.send, Icons.shield, Icons.save, Icons.mail,
  Icons.square_foot, Icons.weekend, Icons.airplanemode_active, Icons.local_fire_department];

final List<IconStock> stocks = [];

initStocks(){
  //whole app resets on start, no saving yet
  for(int i = 0; i < icons.length; i++){
    stocks.add(new IconStock(icons[i]));
  }
}

updateMarket(){
  print("UPDATING MARKET...");
  for(int i = 0; i < stocks.length; i++){
    stocks[i].updatePrice();
  }
}

bool chance(double prob){
  return prob > rng.nextDouble();
}

class IconStock{
  IconData icon;
  int price;
  int owned;
  bool liked;
  _StockCardState card;

  IconStock(IconData iconData){
    icon = iconData;
    price = 10 + rng.nextInt(191);
    owned = 0;
    liked = false;
    card = null;
  }

  updatePrice(){
    double percent = (chance(.1) ? .5 : .1);
    double maxChange = price * percent;
    price = min(9999, max(1, price + (maxChange * (rng.nextDouble() * 2 - 1)))).ceil();
    if(card != null) {
      card.updateState();
    }
  }
}

class StockCard extends StatefulWidget {
  StockCard({Key key, this.stock}) : super(key: key);

  final IconStock stock;

  @override
  _StockCardState createState() => _StockCardState();
}

class _StockCardState extends State<StockCard> {

  //This needs to be empty and generic because the price will update in the stock object
  //periodically without interaction with the widget and the reference to the object
  //doesn't need to change.
  updateState(){
    if(this.mounted) {
      setState(() {});
    }
  }

  toggleLike(){
    widget.stock.liked = !widget.stock.liked;
    updateState();
  }

  @override
  void initState(){
    super.initState();
    widget.stock.card = this;
  }

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
                    widget.stock.icon,
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
                            TextSpan(text: widget.stock.owned.toString(), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 30, color: Colors.white, height: 1)),
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
                      TextSpan(text: widget.stock.price.toString(), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 40)),
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
                  color: (widget.stock.liked ? Colors.red[100] : Colors.pink[50]),
                ),
                height: double.infinity,

                child: IconButton(
                  icon: Icon((widget.stock.liked ? Icons.favorite : Icons.favorite_outline), color: (widget.stock.liked ? Colors.red : Colors.black26)),
                  iconSize: 40,
                  onPressed: toggleLike
                ),
              ),
            ),
          ]
        )
    );
  }
}