import 'dart:collection';
import 'package:flutter/material.dart';
import 'dart:math';
import 'stock_page.dart';

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

final barPainter = Paint();
final barPainterRed= Paint();
final barPainterGreen = Paint();

int balance;

initStocks(){
  //whole app resets on start, no saving yet
  balance = 100;
  for(int i = 0; i < icons.length; i++){
    stocks.add(new IconStock(icons[i]));
  }

  barPainter.style = PaintingStyle.fill;
  barPainter.color = Colors.white;
}

updateMarket(){
  for(int i = 0; i < stocks.length; i++){
    stocks[i].updatePrice();
  }
}

bool chance(double prob){
  return prob > rng.nextDouble();
}

class IconStock{
  final int memory = 20;
  IconData icon;
  int price;
  int owned;
  bool liked;
  bool redraw;
  _StockCardState card;
  Color indicatorColor = Colors.grey;
  Queue<int> recentHistory = Queue();
  HistoryPainter painter;

  IconStock(IconData iconData){
    icon = iconData;
    price = 10 + rng.nextInt(191);
    owned = 0;
    liked = false;
    card = null;
    redraw = false;
    painter = HistoryPainter(stock: this);
  }

  updatePrice(){
    double percent = (chance(.1) ? .5 : .1);
    double maxChange = price * percent;
    double change = maxChange * (rng.nextDouble() * 2 - 1);
    price = min(9999, max(1, price + change)).ceil();
    indicatorColor = (change > 0 ? Colors.green[900] : (change < 0 ? Colors.red[900] : Colors.grey));

    recentHistory.addFirst(price);
    if(recentHistory.length > memory){
      recentHistory.removeLast();
    }
    redraw = true;

    if(card != null) {
      card.updateState();
    }
  }
}

class HistoryPainter extends CustomPainter {
  HistoryPainter({Key key, this.stock});
  final IconStock stock;

  @override
  void paint(Canvas canvas, Size size) {
    if(stock != null) {
      print("DRAW");
      int maxPrice = stock.recentHistory.reduce(max);
      double barSpace = (size.width - 10) / (stock.memory - 1);
      List<int> priceList = stock.recentHistory.toList();
      for(int i = 0; i < priceList.length - 1; i++){
        double heightPercent = priceList[priceList.length - 2 - i] / maxPrice;
        double height = (size.height - 10) * heightPercent;
        barPainter.color = (priceList[priceList.length - 2 - i] < priceList[priceList.length - 1 - i] ? Colors.red[700] : Colors.green[700]);
        //this line is a bit much, but I'm on a time budget
        canvas.drawRect(Rect.fromLTWH(5 + barSpace * .1 + barSpace * i, 10 + (size.height - 10 - height), barSpace * .8, height), barPainter);
      }
    }
  }

  @override
  bool shouldRepaint(HistoryPainter oldDelegate){
    if(stock == null) {
      return false;
    }

    if(stock.redraw){
      stock.redraw = false;
      return true;
    }
    return false;
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
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StockPage(stock: widget.stock)),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        height: 250,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //FIRST SECTION (ICON AND OWNED COUNTER)
              Expanded(
                flex: 8,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[

                    Expanded(
                      flex: 8,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(10)),
                          color: Colors.white,
                        ),
                        child: Icon(
                          widget.stock.icon,
                          color: Colors.grey[900],
                          size: 150.0,
                        ),
                      ),
                    ),

                  //Shares owned
                  Expanded(
                      flex: 2,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10)),
                        color: Colors.black,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                              Text(widget.stock.owned.toString(), style: TextStyle(fontWeight: FontWeight.w500, fontSize: 25, color: Colors.white, height: 1), textAlign: TextAlign.right),
                              Text(' shares\n owned', style: TextStyle(fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, fontSize: 9, color: Colors.grey[400]), textAlign: TextAlign.left),
                          ],
                        )
                      ),
                    )
                  )]
                ),
              ),


            //SECOND SECTION (GRAPH AND PRICE)
            Expanded(
              flex: 8,
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                      ),
                      width: double.infinity,
                      height: double.infinity,
                      alignment: Alignment.center,
                      child: LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints) =>
                          CustomPaint(painter: widget.stock.painter, size: Size(constraints.maxWidth, constraints.maxHeight)),

                      )
                    )
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                        decoration: BoxDecoration(
                          color: widget.stock.indicatorColor,
                        ),
                        height: double.infinity,
                        alignment: Alignment.centerRight,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                          ),
                          margin: EdgeInsets.symmetric(vertical: 5),
                          alignment: Alignment.centerRight,
                          child: Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Text.rich(
                            TextSpan(
                              children: <TextSpan>[
                                TextSpan(text: widget.stock.price.toString(), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 32, color: Colors.white)),
                                TextSpan(text: ' bits', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 18, color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
                  iconSize: 45,
                  alignment: Alignment.topCenter,
                  onPressed: toggleLike
                ),
              ),
            ),
          ],
        )
      ),
    );
  }
}