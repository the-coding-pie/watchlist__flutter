import 'package:flutter/material.dart';
import 'package:watchlist/screens/home.dart';
import 'package:provider/provider.dart';
import 'package:watchlist/utils/movie_db.dart';

void main() => runApp(WatchList());

class WatchList extends StatelessWidget {
  @override 
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChangeNotifierProvider(
        create: (context) => MovieDb(),
        child: Home(),
      ),
      theme: ThemeData.dark().copyWith(
        primaryColor: Color(0xFF00FF00),
        accentColor: Color(0xFF00FF00),
      ),
      
    );
  }
}