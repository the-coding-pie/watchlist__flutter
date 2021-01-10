import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watchlist/models/movie.dart';
import 'package:watchlist/screens/movie_detail.dart';
import 'package:watchlist/utils/movie_db.dart';

class MovieWidget extends StatefulWidget {
  final Movie movie;

  MovieWidget(this.movie);

  @override
  _MovieWidgetState createState() => _MovieWidgetState();
}

class _MovieWidgetState extends State<MovieWidget> {
  void addMovieToDb(movie) async {
    if (movie != '' &&
        await Provider.of<MovieDb>(context, listen: false)
                .checkMovie(movie.name) !=
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
      await Provider.of<MovieDb>(context, listen: false)
          .insertMovie(Movie(name: movie.name, url: movie.url, position: pos, movie_id: movie.movie_id));
     
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 8.0),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 10.0,
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(

                  builder: (context) => MovieDetailScreen(widget.movie.movie_id),
                ));
              },
              onDoubleTap: () async {
            
                await addMovieToDb(widget.movie);
              },
                          child: Container(
          height: 160,
          width: 100,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
           
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
                  child: Image.network(widget.movie.url),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.center,
                                  child: Text(
                      widget.movie.name.length > 15 ? widget.movie.name.substring(0, 15)  + '...' : widget.movie.name,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
          ),
        ),
            ),
      ),
    );
  }
}
