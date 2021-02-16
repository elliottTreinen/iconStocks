import 'dart:collection';
import 'package:flutter/material.dart';
import 'dart:math';

//This file implements a simulated stock market, as well as several widgets
//to interact with and view information about said market.
//Made by: Elliott Treinen

//There doesn't seem to be a good way to procedurally import icons, this
//will have to do for now.
final List<IconData> icons = [
	Icons.accessibility_new,
	Icons.accessible,
	Icons.account_balance,
	Icons.account_circle,
	Icons.add_shopping_cart,
	Icons.alarm,
	Icons.all_inbox,
	Icons.analytics,
	Icons.anchor,
	Icons.android,
	Icons.announcement,
	Icons.arrow_circle_down,
	Icons.arrow_circle_up,
	Icons.assignment,
	Icons.backup,
	Icons.bookmark,
	Icons.bug_report,
	Icons.build,
	Icons.calendar_today,
	Icons.card_membership,
	Icons.change_history,
	Icons.check_circle,
	Icons.chrome_reader_mode,
	Icons.class_,
	Icons.commute,
	Icons.copyright,
	Icons.dangerous,
	Icons.delete,
	Icons.donut_small,
	Icons.drag_indicator,
	Icons.dynamic_form,
	Icons.eco,
	Icons.event_seat,
	Icons.expand,
	Icons.face,
	Icons.favorite,
	Icons.fingerprint,
	Icons.extension,
	Icons.flight_takeoff,
	Icons.flaky,
	Icons.grade,
	Icons.home,
	Icons.hourglass_empty,
	Icons.horizontal_split,
	Icons.lock,
	Icons.language,
	Icons.lightbulb,
	Icons.lock_open,
	Icons.nightlife,
	Icons.nightlight_round,
	Icons.outlet,
	Icons.monetization_on,
	Icons.pan_tool,
	Icons.rowing,
	Icons.bluetooth,
	Icons.settings,
	Icons.mic,
	Icons.swipe,
	Icons.verified,
	Icons.view_in_ar,
	Icons.visibility,
	Icons.hearing,
	Icons.games,
	Icons.radio,
	Icons.circle,
	Icons.speed,
	Icons.business,
	Icons.dialer_sip,
	Icons.nat,
	Icons.qr_code,
	Icons.sentiment_satisfied,
	Icons.sentiment_dissatisfied,
	Icons.vpn_key,
	Icons.biotech,
	Icons.bolt,
	Icons.insights,
	Icons.gesture,
	Icons.content_cut,
	Icons.push_pin,
	Icons.flag,
	Icons.send,
	Icons.shield,
	Icons.save,
	Icons.mail,
	Icons.square_foot,
	Icons.weekend,
	Icons.airplanemode_active,
	Icons.local_fire_department
]; //All icons to be included in the market

final List<IconStock> stocks = [];
final List<StockCard> cards = [];
final barPainter = Paint(); //to paint the price history graphs
final Random rng = Random();
final Portfolio portfolio = Portfolio(); //to store data on about the user's interactions with the market

initStocks() {
	//whole app resets on start, no saving yet

	//initialize stock objects
	for (int i = 0; i < icons.length; i++) {
		stocks.add(new IconStock(icons[i]));
	}

	portfolio.initPortfolio();

	barPainter.style = PaintingStyle.fill;
	barPainter.color = Colors.black;

	//initialize cards and store in list for ListView
	cards.length = stocks.length;
	for (int i = 0; i < stocks.length; i++) {
		cards[i] = StockCard(stock: stocks[i]);
	}
}

//calling this makes the market take a "step"
//called once/sec in main.dart by default
updateMarket() {
	for (int i = 0; i < stocks.length; i++) {
		stocks[i].updatePrice();
	}

	updateInfo();
}

//updates displayed info regarding portfolio
updateInfo() {
	if (portfolio != null) {
		portfolio.updateInfoDisplays();
	}
}

//just for ease of use.
//returns true [prob * 100]% of the time.
bool chance(double prob) {
	return prob > rng.nextDouble();
}

//A class to represent individual stocks
class IconStock {
	final int memory = 30; //memory determines how many seconds of price history each stock tracks
	IconData icon;
	int price;
	bool liked;
	bool redraw; //redraw lets the stock know if it was updated while off screen
	Queue<int> recentHistory;
	HistoryPainter painter;

	Queue<_StockCardState> cardStack;
	//I'm kinda proud of this, although I feel as though it has the possibility to cause issues somehow.
	//This stack lets the stock update the card displaying its data. Whenever a new state is
	//created for a card referencing this stock it pushes itself onto the end of this stack
	//and pops itself off when its destroyed. This means that when entering a new page the
	//new state for that card will be at the end, but when returning to the homepage, the
	//original state is restored. Whenever this stock need to update its card it can just
	//reference the last state on the stack.

	IconStock(IconData iconData) {
		icon = iconData;
		price = 10 + rng.nextInt(191);
		liked = false;
		cardStack = Queue<_StockCardState>();
		redraw = false;
		painter = HistoryPainter(stock: this);
		recentHistory = Queue();
		recentHistory.addFirst(price);
	}

	//updates the price and history of this specific stock, redrawing if necessary.
	updatePrice() {
		//this is not accurate to how the real stock market behaves
		double percent = (chance(.1) ? .5 : .1);
		double maxChange = price * percent;
		int change = (maxChange * (rng.nextDouble() * 2 - 1)).ceil();
		price = min(9999, max(1, price + change));

		recentHistory.addFirst(price);
		if (recentHistory.length > memory) {
			recentHistory.removeLast();
		}

		redraw = true;

		//update info displayed on most recently created stock card
		if (cardStack.length > 0) {
			if(cardStack.last != null){
				cardStack.last.updateState();
			}
		}
	}
}

//A class to interact with the user's portfolio
class Portfolio {
	int balance;
	Map<IconStock, int> sharesOwned;//how many shares of each stock user owns
	_PortfolioBarState infoBar;//nav bar displaying portfolio info
	_PortfolioPageState infoPage;//page displaying portfolio info

	initPortfolio() {
		balance = 100;
		sharesOwned = Map();
		for (int i = 0; i < stocks.length; i++) {
			sharesOwned[stocks[i]] = 0;
		}
	}

	//updates the different widgets displaying portfolio data
	updateInfoDisplays() {
		if (infoBar != null) {
			infoBar.updateState();
		}

		if(infoPage != null){
			infoPage.updateState();
		}
	}

	//returns the number of shares of 'stock' owned
	int numOwned(IconStock stock) {
		return sharesOwned[stock];
	}

	//buys a single stock if possible
	buy(IconStock stock) {
		if (balance > stock.price) {
			balance -= stock.price;
			sharesOwned[stock]++;
		}
		updateInfoDisplays();
	}

	//sells a single stock if possible
	sell(IconStock stock) {
		if (sharesOwned[stock] > 0) {
			sharesOwned[stock]--;
			balance += stock.price;
		}
		updateInfoDisplays();
	}

	//returns the summed bit value of all owned shares
	int portfolioValue() {
		int sum = 0;
		sharesOwned.forEach((stock, owned) {
			sum += stock.price * owned;
		});
		return sum;
	}

	//returns number of liked stocks
	int numLiked(){
		int sum = 0;
		stocks.forEach((stock){if(stock.liked){sum++;}});
		return sum;
	}
}

//used to paint the price history bar graphs
class HistoryPainter extends CustomPainter {
	HistoryPainter({Key key, this.stock});

	final IconStock stock;

	@override
	void paint(Canvas canvas, Size size) {
		if (stock != null) {int numPainted = min((size.width / 10).floor(), 30); //paint either the entire memory, or enough that each bar is as close to 10 pixels wide as possible
			int maxPrice = stock.recentHistory.reduce(max);
			double barSpace = (size.width - 10) / (numPainted); //find the exact width of each bar
			List<int> priceList = stock.recentHistory.toList(); //convert history for easier parsing

			for (int i = 0; i < min(numPainted, stock.recentHistory.length - 1); i++) {
				//paints each bar so that the tallest bar in memory is always 10 pixels shorter than the canvas height
				double heightPercent = priceList[i] / maxPrice;
				double height = (size.height - 10) * heightPercent;
				canvas.drawRect(Rect.fromLTWH(size.width - (barSpace * (i + 1.5)), 10 + (size.height - 10 - height), barSpace * .8, height), barPainter);
			}
		}
	}

	//checks to see if the stock price has been updated, if so it redraws the price history.
	@override
	bool shouldRepaint(HistoryPainter oldDelegate) {
		if (stock == null) {
			return false;
		}

		if (stock.redraw) {
			stock.redraw = false;
			return true;
		}
		return false;
	}
}

//The cards displaying data related to the stocks. seen on the home page and portfolio screen.
class StockCard extends StatefulWidget {
	StockCard({Key key, this.stock}) : super(key: key);

	final IconStock stock; //the stock associated with this card

	@override
	_StockCardState createState() => _StockCardState();
}

class _StockCardState extends State<StockCard> {

	//This is called on each card periodically, it only sets the state because no data
	//in the card is changed. It works off the same reference to the stock object on
	//each update.
	updateState() {
		if (this.mounted) {
			setState(() {});
		}
	}

	toggleLike() {
		widget.stock.liked = !widget.stock.liked;
		updateState();
	}

	@override
	void initState() {
		super.initState();
		widget.stock.cardStack.addLast(this);//add self to stock's card stack
	}

	@override
	void dispose() {
		super.dispose();
		widget.stock.cardStack.removeLast();//remove self from stock's card stack
	}

	@override
	Widget build(BuildContext context) {
		return Container(//The white background of each card
			margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
			height: 200,
			decoration: BoxDecoration(
				borderRadius: BorderRadius.all(Radius.circular(3)),
				color: Colors.white,
				boxShadow: [
					BoxShadow(color: Colors.grey[300], spreadRadius: 1, blurRadius: 7)
				],
			),

			child: Padding(
				padding: EdgeInsets.only(top: 10, right: 10),
				//The format gets a bit complicated here, rows inside of Expands inside of column inside of rows
				//The Stack widget might work better here, but I'm still learning.
				child: Column(//holds everything in card
					mainAxisAlignment: MainAxisAlignment.spaceBetween,
					children: <Widget>[
						Expanded(
							flex: 3,
							child: Row(//icon, price, graph, and like
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: <Widget>[
									Expanded(
										flex: 3,
										child: Icon(//stock icon
											widget.stock.icon,
											size: 125,
										),
									),

									Expanded(
										flex: 4,
										child: Column(//price, graph, and like
											mainAxisAlignment: MainAxisAlignment.spaceBetween,
											crossAxisAlignment: CrossAxisAlignment.center,
											children: <Widget>[
												Expanded(
													flex: 1,
													child: Row(//price and like
														mainAxisAlignment: MainAxisAlignment.spaceBetween,
														crossAxisAlignment: CrossAxisAlignment.center,
														children: <Widget>[
															Text.rich(//current price
																TextSpan(
																	children: <TextSpan>[
																		TextSpan(text: widget.stock.price.toString(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.black)),
																		TextSpan(text: ' bits', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 10, color: Colors.black)),
																	],
																),
															),

															IconButton(//like button
																icon: Icon((widget.stock.liked ? Icons.favorite : Icons.favorite_outline), color: (widget.stock.liked ? Colors.red : Colors.black26)),
																onPressed: toggleLike
															),
														]
													),
												),

												Expanded(
													flex: 2,
													child: LayoutBuilder(//Graph
														builder: (BuildContext context, BoxConstraints constraints) =>
															CustomPaint(painter: widget.stock.painter, size: Size(constraints.maxWidth, constraints.maxHeight)),
													),
												),
											],
										),
									),
								],
							),
						),

						Expanded(
							flex: 1,
							child: Row(//Buy, sell, and num owned
								mainAxisAlignment: MainAxisAlignment.spaceAround,
								crossAxisAlignment: CrossAxisAlignment.center,
								children: <Widget>[
									FlatButton(//sell button
										onPressed: (){portfolio.sell(widget.stock); updateState();},
										child: Text('SELL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
									),

									Text(portfolio.numOwned(widget.stock).toString()),//number owned

									FlatButton(//buy button
										onPressed: (){portfolio.buy(widget.stock); updateState();},
										child: Text('BUY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
									),
								],
							),
						),
					],
				),
			),
		);
	}
}

//the info bar at the bottom of the main page
class PortfolioBar extends StatefulWidget {
	@override
	_PortfolioBarState createState() => _PortfolioBarState();
}

class _PortfolioBarState extends State<PortfolioBar> {
	updateState() {
		if (this.mounted) {
			setState(() {});
		}
	}

	@override
	void initState() {
		super.initState();
		portfolio.infoBar = this;//set self to be updated when portfolio data is updated
	}

	@override
	Widget build(BuildContext context) {
		return GestureDetector(
			onTap: () {
				Navigator.push(
					context,
					MaterialPageRoute(builder: (context) => PortfolioPage()),
				);
			},
			child: Container(
				height: 90,
				width: double.infinity,
				color: Colors.black,

				child: Padding(
					padding: EdgeInsets.symmetric(horizontal: 20),
					child: Row(//portfolio info and icon
						crossAxisAlignment: CrossAxisAlignment.end,
						children: <Widget>[
							Expanded(
								flex: 3,
								child: Column(//portfolio info
									crossAxisAlignment: CrossAxisAlignment.start,
									mainAxisAlignment: MainAxisAlignment.spaceEvenly,
									children: <Widget>[
										Text('Portfolio', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),

										Row(//current portfolio value
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

										Row(//Current account balance
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
									]
								),
							),
							Icon(Icons.request_quote, size: 70, color: Colors.white),
						]
					),
				),
			),
		);
	}
}

//the second page where you can view information about owned and liked stocks as well as your portfolio value.
class PortfolioPage extends StatefulWidget {
	@override
	_PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {

	List<StockCard> selectedCards;

	updateState() {
		if (this.mounted) {
			setState(() {});
		}
	}

	@override
	void initState() {
		super.initState();
		portfolio.infoPage = this;//set self to be updated when portfolio info updates

		//create a list of cards for stocks that user either liked or owns shares in
		selectedCards = [];
		stocks.forEach((element) {
			if (element.liked || portfolio.numOwned(element) > 0) {
				selectedCards.add(StockCard(stock: element));
			}
		});

		//sort by number of shares owned
		selectedCards.sort((a, b) => portfolio.numOwned(b.stock).compareTo(portfolio.numOwned(a.stock)));
	}

	@override
	Widget build(BuildContext context) {

		return Scaffold(
			backgroundColor: Colors.white,
			appBar: AppBar(
				centerTitle: true,
				title: Text(
					'Portfolio',
					style: TextStyle(
							fontSize: 40,
							fontWeight: FontWeight.w900,
							fontStyle: FontStyle.italic),
				),
			),
			body: Column(
				children: <Widget>[
					Expanded(
						flex: 7,
						child: Container(//top info bar
							height: 90,
							width: double.infinity,
							color: Colors.black,
							child: Padding(
								padding: EdgeInsets.all(20),
								child: Column(
									mainAxisAlignment: MainAxisAlignment.spaceBetween,
									children: <Widget>[
										Row(//Current account balance
											mainAxisAlignment: MainAxisAlignment.spaceBetween,
											children: <Widget>[
												Text('Bits Balance', style: TextStyle(fontSize: 25, color: Colors.white)),

												Text.rich(
													TextSpan(
														children: <TextSpan>[
															TextSpan(text: portfolio.balance.toString(), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 30, color: Colors.white, height: .9)),
															TextSpan(text: ' bits', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 17, color: Colors.white)),
														],
													),
												),
											]
										),

										Row(//Current portfolio value
											mainAxisAlignment: MainAxisAlignment.spaceBetween,
											children: <Widget>[
												Text('Portfolio Value', style: TextStyle(fontSize: 25, color: Colors.white)),

												Text.rich(
													TextSpan(
														children: <TextSpan>[
															TextSpan(text: portfolio.portfolioValue().toString(), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 30, color: Colors.white, height: .9)),
															TextSpan(text: ' bits', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 17, color: Colors.white)),
														],
													),
												),
											]
										),

										Row(//Current total value
												mainAxisAlignment: MainAxisAlignment.spaceBetween,
												children: <Widget>[
													Text('Total', style: TextStyle(fontSize: 25, color: Colors.white)),

													Text.rich(
														TextSpan(
															children: <TextSpan>[
																TextSpan(text: (portfolio.portfolioValue() + portfolio.balance).toString(), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 30, color: Colors.white, height: .9)),
																TextSpan(text: ' bits', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 17, color: Colors.white)),
															],
														),
													),
												]
										),

										Row(//Current number of liked icons
												mainAxisAlignment: MainAxisAlignment.spaceBetween,
												children: <Widget>[
													Text('Liked Icons', style: TextStyle(fontSize: 25, color: Colors.white)),

													Text(portfolio.numLiked().toString(), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 30, color: Colors.white, height: .9)),
												]
										),
									],
								)
							)
						)
					),

					Expanded(//list label
						flex: 1,
						child: Container(
							color: Colors.grey[900],
							width: double.infinity,
							alignment: Alignment.center,
							child: Text('STOCKS YOU\'VE LIKED OR INVESTED IN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
						)
					),

					Expanded(//liked and invested card list
						flex: 20,
						child: Container(
							child: ListView.builder(
								itemCount: selectedCards.length,
								itemExtent: 250,
								itemBuilder: (context, index) {
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
