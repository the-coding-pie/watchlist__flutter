import 'dart:convert';
import 'package:flutter_youtube/flutter_youtube.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:watchlist/constants.dart';
import 'package:watchlist/models/movie.dart';
import 'package:watchlist/utils/movie_db.dart';

class MovieDetailScreen extends StatefulWidget {
  int movie_id;

  MovieDetailScreen(this.movie_id);

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {

  void addMovieToDb(movie) async {
    if (movie != '' && await Provider.of<MovieDb>(context, listen: false).checkMovie(movie.name) !=
            true) {
      //save the text and url
      //check for position
      var pos;
      var count =
          await Provider.of<MovieDb>(context, listen: false).empytOrNot();
      //if 0 -> insert 0, or insert count + 1
      if (count == null) {
        pos = 0;
      } else {
        pos = count + 1;
      }
      await Provider.of<MovieDb>(context, listen: false).insertMovie(Movie(name: movie.name, url: movie.url, position: pos, movie_id: movie.movie_id));
     
    }
  }

  var youtube_api = "your_youtube_api_key";
  //poster base url
  var image_baseurl = "http://image.tmdb.org/t/p/w92//";

  final backdrop_path_url = "http://image.tmdb.org/t/p/original";

  final url = "https://api.themoviedb.org/3/movie/";
  final url_end =
      "?api_key=your_api_key&append_to_response=videos,images,credits,similar,reviews";

  Movie movie;

  Future<Movie> getMovie(id) async {
    Response response = await get(url + id.toString() + url_end);
    Map map = jsonDecode(response.body);
    return Movie(
        name: map['title'],
        desc: map["overview"],
        rating: map["vote_average"],
        backdrop_path: map["backdrop_path"],
        poster_path: map['poster_path'],
        video: map["videos"]["results"][0]["key"], minutes: map["runtime"], genres: map["genres"], cast: map["credits"]["cast"], crew: map["credits"]["crew"]);
    //  , desc: map['overview'], minutes: map['runtime'], rating: map['vote_average'], video: map["videos"]["results"][0]["key"], backdrop_path: map["backdrop_path"], poster_path: map['poster_path'])
  }


  String getGenres(list) {
    String genres = "";
    for(int i = 0; i < list.length; i++) {
      if (i == list.length - 1) {
        genres += list[i]["name"];
      } else {
        genres += list[i]["name"] + ", ";
      }
    }
    return genres;
  }

  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Details",
          style: kTabTextStyle,
        ),
      ),
      body: FutureBuilder(
        future: getMovie(widget.movie_id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Padding(
              padding: EdgeInsets.all(8.0),
              child: ListView(
                children: <Widget>[
                  Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                                              child: Image.network(
                            backdrop_path_url + snapshot.data.backdrop_path),
                      )),
                Container(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 15.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                    "Genres: ",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  SizedBox(width: 10.0,),
                  Expanded(
                                      child: Text(
                      getGenres(snapshot.data.genres),
                      style: TextStyle(
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                    ],
                  ),
                ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Card(
                            color: Colors.red,
                            child: IconButton(
                              iconSize: 35.0,
                              icon: Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                FlutterYoutube.playYoutubeVideoById(
                                  apiKey: youtube_api,
                                  videoId: snapshot.data.video,
                                  autoPlay: true,
                                  appBarColor: Colors.black,
                                  fullScreen: true,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Card(
                          
                            color: Colors.green,
                            child: IconButton(
                              iconSize: 35.0,
                              icon: Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                addMovieToDb(snapshot.data);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.network(
                              image_baseurl + snapshot.data.poster_path),
                        ),
                      ),
                      SizedBox(width: 8.0,),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              snapshot.data.name,
                              style: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                            ),

                            SizedBox(height: 8.0,),

                            Text(
                              snapshot.data.desc,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Container(
                          height: 80.0,
                          width: 60.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                             color: Colors.white,
                          ),
                        
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.star,
                              color: Color(0xFFFFD700),
                              size: 30.0,
                            ),
                            SizedBox(height: 5.0,),
                            Text(
                              snapshot.data.rating.toString(),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        ),
                      ),

                         Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Container(
                          height: 80.0,
                          width: 60.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                             color: Colors.white,
                          ),
                        
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.access_time,
                              color: Colors.blueAccent,
                              size: 30.0,
                            ),
                              SizedBox(height: 5.0,),
                            Text(
                              snapshot.data.minutes.toString() + ' m',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        ),
                      ),

                    
                    ],
                  ),
          SizedBox(height: 10.0,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                   Text(
                    "Cast",
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.w400
                    ),
                   ),
                   SizedBox(height: 8.0,),
                   Container(
                     height: 100.0,
                    
                     child: ListView.builder(
                       scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data.cast.length > 7 ? 7 : 5,
                      itemBuilder: (BuildContext context, int index) {
                        return 
                            Padding(
                              padding: EdgeInsets.all(6.0),
                              child: CircleAvatar(
                                
                                radius: 40.0,
                                backgroundImage: NetworkImage(
                                  image_baseurl + snapshot.data.cast[index]["profile_path"],
                                ),
                              ),
                            );
             
                        
                      },
                     ),
                   ),
                ],
              ),


    SizedBox(height: 10.0,),
         ],
              ),
            );
          } else {
            return Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}
