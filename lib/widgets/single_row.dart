import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:watchlist/constants.dart';
import 'package:watchlist/models/movie.dart';
import 'package:watchlist/widgets/movie_widget.dart';


class SingleRow extends StatefulWidget {
  String title;
  String url;

  SingleRow({ this.title, this.url });

  @override
  _SingleRowState createState() => _SingleRowState();
}

class _SingleRowState extends State<SingleRow> {

  var image_baseurl = "http://image.tmdb.org/t/p/w154//";


  Future<List<Movie>> getMovies(url) async {
    Response response = await get(url);

    Map data = jsonDecode(response.body);

    //List<Map>
    var results = data['results'];

    List<Movie> moviesList = [];

    //convert List<Map> to List<Movie>
    try {
      for (var i = 0; i < results.length; i++) {
        moviesList.add(Movie(
            name: results[i]['title'],
            movie_id: results[i]['id'],
            url: image_baseurl + results[i]['poster_path']));
            
        // print(results[i]['poster_path']);
        // print(results[i]['release_date']);
        // print(results[i]['title']);
        // print(results[i]['vote_average']);
      }
    } catch (e) {
      print(e);
    }

    return moviesList;
  }
  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: EdgeInsets.only(left: 8.0),
      child: Container(
            width: double.infinity,
            height: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    widget.title,
                    style: kTabTextStyle  ,
                  ),
                ),
                FutureBuilder(
                  future: getMovies(widget.url),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Container(
                          height: 230,
                          child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            return MovieWidget(snapshot.data[index]);
                          },
                        ),
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
    );
  }
}