import 'dart:collection';
import 'package:flutter/material.dart';
import 'dart:math';

final Random rng = Random();
final Portfolio portfolio = Portfolio();

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
final List<StockCard> cards = [];

_StockPageState currentPage;
_PortfolioBarState storedBar;

initStocks(){
  //whole app resets on start, no saving yet
  for(int i = 0; i < icons.length; i++){
    stocks.add(new IconStock(icons[i]));
  }

  portfolio.initPortfolio();

  barPainter.style = PaintingStyle.fill;
  barPainter.color = Colors.white;

  cards.length = stocks.length;
  for(int i = 0; i < stocks.length; i++){
    cards[i] = StockCard(stock: stocks[i]);
  }
}

updateMarket(){
  for(int i = 0; i < stocks.length; i++){
    stocks[i].updatePrice();
  }

  updateInfo();
}

updateInfo(){
  if(portfolio != null){
    portfolio.updateInfoBar();
  }

  if(currentPage != null){
    currentPage.updateState();
  }
}

bool chance(double prob){
  return prob > rng.nextDouble();
}

class IconStock{
  final int memory = 30;
  IconData icon;
  int price;
  bool liked;
  bool redraw;
  _StockCardState card;
  Color indicatorColor = Colors.grey;
  Queue<int> recentHistory;
  HistoryPainter painter;

  IconStock(IconData iconData){
    icon = iconData;
    price = 10 + rng.nextInt(191);
    liked = false;
    card = null;
    redraw = false;
    painter = HistoryPainter(stock: this);
    recentHistory = Queue();
    recentHistory.addFirst(price);
  }
  updatePrice(){
    double percent = (chance(.1) ? .5 : .1);
    double maxChange = price * percent;
    int change = (maxChange * (rng.nextDouble() * 2 - 1)).ceil();
    price = min(9999, max(1, price + change));
    indicatorColor = (change > 0 ? Color(0xff005700) : (change < 0 ? Color(0xff570000) : Colors.grey[800]));

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

class Portfolio{
  int balance;
  Map<IconStock, int> sharesOwned;
  _PortfolioBarState homeBar;
  _PortfolioBarState stockBar;

  initPortfolio(){
    balance = 100;
    sharesOwned = Map();
    for(int i = 0; i < stocks.length; i++){
      sharesOwned[stocks[i]] = 0;
    }
  }

  updateInfoBar(){
    //Yeah, this is gross, but I haven't had time to fully understand
    //routes yet.
    if(homeBar != null) {
      homeBar.updateState();
    }

    if(stockBar != null) {
      stockBar.updateState();
    }
  }

  int numOwned(IconStock stock){
    return sharesOwned[stock];
  }

  buy(IconStock stock){
    if(balance > stock.price){
      balance -= stock.price;
      sharesOwned[stock]++;
    }
  }

  sell(IconStock stock){
    if(sharesOwned[stock] > 0){
      sharesOwned[stock]--;
      balance += stock.price;
    }
  }

  int portfolioValue(){
    int sum = 0;
    sharesOwned.forEach((stock, owned){
      sum += stock.price * owned;
    });
    return sum;
  }
}

class HistoryPainter extends CustomPainter {
  HistoryPainter({Key key, this.stock});
  final IconStock stock;

  @override
  void paint(Canvas canvas, Size size) {
    if(stock != null) {
      //this section is a bit much, but I'm on a time budget
      int numPainted = min((size.width / 10).floor(), 30);
      int maxPrice = stock.recentHistory.reduce(max);
      double barSpace = (size.width - 10) / (numPainted);
      List<int> priceList = stock.recentHistory.toList();
      for(int i = 0; i < min(numPainted, stock.recentHistory.length - 1); i++){
        double heightPercent = priceList[i] / maxPrice;
        double height = (size.height - 10) * heightPercent;
        barPainter.color = (priceList[i] < priceList[i + 1] ? Colors.red[700] : (priceList[i] > priceList[i + 1] ? Colors.green[700] : Colors.grey[700]));
        canvas.drawRect(Rect.fromLTWH(size.width - (barSpace * (i + 1.5)), 10 + (size.height - 10 - height), barSpace * .8, height), barPainter);
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
                          border: Border.all(
                            width: 5,
                            color: Colors.black,
                          ),
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

                    //shares owned
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
                                Text(portfolio.numOwned(widget.stock).toString(), style: TextStyle(fontWeight: FontWeight.w500, fontSize: 25, color: Colors.white, height: 1), textAlign: TextAlign.right),
                                Text(' shares\n owned', style: TextStyle(fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, fontSize: 9, color: Colors.grey[400]), textAlign: TextAlign.left),
                              ],
                            )
                        ),
                      )
                    ),
                  ]
                ),
              ),


            //SECOND SECTION (GRAPH AND PRICE)
            Expanded(
              flex: 8,
              child: Column(
                children: <Widget>[

                  //Graph
                  Expanded(
                    flex: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border(
                          bottom: BorderSide(width: 5, color: Colors.black),
                        ),
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

                  //Price
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.stock.indicatorColor,
                        border: Border(
                          bottom: BorderSide(width: 5, color: Colors.black),
                          left: BorderSide(width: 5, color: Colors.black),
                          right: BorderSide(width: 5, color: Colors.black),
                        ),
                      ),
                      height: double.infinity,
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
                  border: Border.all(
                    width: 5,
                    color: Colors.black,
                  ),
                ),
                height: double.infinity,

                child: IconButton(
                  icon: Icon((widget.stock.liked ? Icons.favorite : Icons.favorite_outline), color: (widget.stock.liked ? Colors.red : Colors.black26)),
                  iconSize: 35,
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

class PortfolioBar extends StatefulWidget {
  PortfolioBar({Key key, this.onStockPage}) : super(key: key);

  final bool onStockPage;
  @override
  _PortfolioBarState createState() => _PortfolioBarState();
}

class _PortfolioBarState extends State<PortfolioBar> {
  updateState(){
    if(this.mounted) {
      setState(() {});
    }
  }

  @override
  void initState(){
    super.initState();
    if(widget.onStockPage) {
      portfolio.stockBar = this;
    }else{
      portfolio.homeBar = this;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        if(widget.onStockPage) {
          Navigator.pop(context);
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PortfolioPage()),
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
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Portfolio', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Portfolio Value', style: TextStyle(fontSize: 15, color: Colors.white)),
                              Text.rich(
                                TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(text: portfolio.portfolioValue().toString(), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 25, color: Colors.white, height: .9)),
                                    TextSpan(text: ' bits', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14, color: Colors.white)),
                                  ],
                                ),
                              ),
                            ]
                        ),

                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Bits Balance', style: TextStyle(fontSize: 15, color: Colors.white)),
                              Text.rich(
                                TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(text: portfolio.balance.toString(), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 25, color: Colors.white, height: .9)),
                                    TextSpan(text: ' bits', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14, color: Colors.white)),
                                  ],
                                ),
                              ),
                            ]
                        ),
                      ],
                    ),
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
                  child: Icon(Icons.request_quote, size: 70, color: Colors.white),
                ),
              ),
            ]
        ),
      ),
    );
  }
}

//individual stock info page
class StockPage extends StatefulWidget {
  StockPage({Key key, this.stock}) : super(key: key);
  final IconStock stock;
  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {

  updateState(){
    if(this.mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    currentPage = this;
    List<int> historyPeek = widget.stock.recentHistory.toList();
    int maxPrice = historyPeek.reduce(max);
    int minPrice = historyPeek.reduce(min);
    int avgPrice = (historyPeek.reduce((a, b){return a + b;}) / historyPeek.length).floor();
    int percentChange = 0;
    if(historyPeek.length >= 29)
      percentChange = (((historyPeek[0] - avgPrice) / avgPrice) * 100).floor();
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        centerTitle: true,
        title: Text('Stock Info', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),),
      ),
      body: Container(
        child: Column(
            children: <Widget>[

              //info
              Expanded(
                flex: 4,
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 8,
                        child: Column(
                          children: <Widget>[

                            //Icon
                            Expanded(
                              flex: 4,
                              child: Container(
                                margin: EdgeInsets.only(top: 10, left: 10,),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10)),
                                  color: Colors.white,
                                  border: Border.all(
                                    width: 5,
                                    color: Colors.black,
                                  ),
                                ),
                                child: Icon(widget.stock.icon, size: 200),
                              ),
                            ),

                            //shares owned
                            Expanded(
                              flex: 1,
                              child: Container(
                                margin: EdgeInsets.only(left: 10),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Text(portfolio.numOwned(widget.stock).toString(), style: TextStyle(fontWeight: FontWeight.w500, fontSize: 35, color: Colors.white, height: 1), textAlign: TextAlign.right),
                                      Text(' shares\n owned', style: TextStyle(fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, fontSize: 13, color: Colors.grey[400], height: 1), textAlign: TextAlign.left),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        flex: 5,
                        child: Container(
                          margin: EdgeInsets.only(top: 10, right: 10),
                          height: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(topRight: Radius.circular(10)),
                            color: Colors.black,
                          ),
                          child:  Column(
                            children: <Widget>[

                              //percent change
                              Expanded(
                                flex: 5,
                                child: Container(
                                  height: double.infinity,
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 20, left: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text.rich(
                                          TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(text: '30', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white)),
                                              TextSpan(text: '\nsec', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15, color: Colors.white, height: .5)),
                                            ],
                                          ),
                                        ),
                                        Text.rich(
                                          TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(text: (percentChange > 0 ? '+' : '') + percentChange.toString(), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 30, color: Colors.white)),
                                              TextSpan(text: '%', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 25, color: Colors.white)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              //max price
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: double.infinity,
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Icon(Icons.vertical_align_top, color: Colors.white, size: 18),
                                        Text.rich(
                                          TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(text: maxPrice.toString(), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white)),
                                              TextSpan(text: ' bits', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Colors.white)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              //avg price
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: double.infinity,
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Icon(Icons.vertical_align_center, color: Colors.white, size: 18),
                                        Text.rich(
                                          TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(text: avgPrice.toString(), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white)),
                                              TextSpan(text: ' bits', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Colors.white)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              //min price
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: double.infinity,
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Icon(Icons.vertical_align_bottom, color: Colors.white, size: 18),
                                        Text.rich(
                                          TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(text: minPrice.toString(), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white)),
                                              TextSpan(text: ' bits', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Colors.white)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              //stock price
                              Expanded(
                                flex: 3,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: widget.stock.indicatorColor,
                                    border: Border(
                                      right: BorderSide(width: 5, color: Colors.black),
                                    ),
                                  ),
                                  height: double.infinity,
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
                            ]
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              //graph
              Expanded(
                flex: 4,
                child: Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                    color: Colors.black,
                  ),
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) =>
                        CustomPaint(painter: widget.stock.painter, size: Size(constraints.maxWidth, constraints.maxHeight)),
                    ),
                  ),
                ),
              ),

              //buy and sell
              Expanded(
                flex: 2,
                child: Container(
                  margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                    color: Colors.black,
                    border: Border.all(
                      width: 5,
                      color: Colors.black,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      GestureDetector(
                        onTap: (){portfolio.sell(widget.stock); updateInfo();},
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.green,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Text('SELL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 40))
                          )
                        ),
                      ),

                      GestureDetector(
                        onTap: (){portfolio.buy(widget.stock); updateInfo();},
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.green,
                          ),
                          child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Text('BUY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 40))
                          )
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              PortfolioBar(onStockPage: true),
            ]
        ),
      ),
    );
  }
}

class PortfolioPage extends StatefulWidget {
  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  @override
  Widget build(BuildContext context) {
    List<StockCard> selectedCards = [];
    cards.forEach((element) {if(element.stock.liked || portfolio.sharesOwned[element.stock] > 0){selectedCards.add(element);}});
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        centerTitle: true,
        title: Text('Portfolio', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: ListView.builder(
                itemCount: selectedCards.length,
                itemExtent: 250,
                itemBuilder: (context, index){
                  //Simulating infinite content for the builder to meet the
                  //"infinite scrolling" requirement
                  return selectedCards[index];
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}