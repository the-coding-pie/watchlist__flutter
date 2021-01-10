import 'package:flutter/material.dart';
import 'package:watchlist/widgets/single_row.dart';

class DiscoverScreen extends StatefulWidget {
  @override
  _DiscoverScreenState createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {

  

  //base url
  var upcoming_url = "https://api.themoviedb.org/3/movie/upcoming?api_key=your_api_key";
  var trending_url = "https://api.themoviedb.org/3/trending/movie/day?api_key=your_api_key";
  var toprated_url = "http://api.themoviedb.org/3/movie/top_rated?api_key=your_api_key";
  var topMoviesOf2019 = "http://api.themoviedb.org/3/discover/movie?api_key=your_api_key&sort_by=popularity.desc&year=2019";

    var topMoviesOf2018 = "http://api.themoviedb.org/3/discover/movie?api_key=your_api_key&sort_by=popularity.desc&year=2018";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        SingleRow(title: "UpComing", url: upcoming_url),
        SingleRow(title: "Trending Now", url: trending_url),
        SingleRow(title: "Top Rated", url: toprated_url),
        SingleRow(title: "Top Of 2019", url: topMoviesOf2019),
        SingleRow(title: "Top Of 2018", url: topMoviesOf2018),
        
      ],
    );
  }
}


