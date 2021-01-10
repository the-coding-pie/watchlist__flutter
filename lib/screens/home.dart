import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:watchlist/constants.dart';
import 'package:watchlist/screens/discover_screen.dart';
import 'package:watchlist/screens/watchlist_screen.dart';
import 'package:watchlist/utils/movie_db.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  void initState() {
    super.initState();
    //set orientation
    //get the movies
    Provider.of<MovieDb>(context, listen: false).getMovies();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            isScrollable: true,
            indicatorWeight: 4.0,
            indicatorColor: Color(0xFF00FF00),
            tabs: <Widget>[
              Tab(
                child: Text(
                  "Discover",
                  style: TextStyle(
                    fontSize: 21.0,
                    color: Color(0xFF00FF00),
                    fontFamily: 'YeonSung',
                    ),
                ),
              ),
              Tab(
                child: Text(
                  "WatchList",
                  style: TextStyle(
                    fontSize: 21.0,
                    color: Color(0xFF00FF00),
                    fontFamily: 'YeonSung',
                    ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.black,
          title: Text(
            'WatchList',
            style: TextStyle(
fontSize: 30.0,
                    color: Color(0xFF00FF00),
                    fontFamily: 'YeonSung',
                    )
            ,
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            //first Child
              DiscoverScreen(),
            //second Child
            WatchListScreen()
          ],
        ),
      ),
    );
  }

  void dispose() {
    super.dispose();
  }
}