import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watchlist/constants.dart';
import 'package:watchlist/models/movie.dart';
import 'package:watchlist/utils/movie_db.dart';
import 'package:http/http.dart';

class WatchListScreen extends StatefulWidget {
  @override
  _WatchListScreen createState() => _WatchListScreen();
}

class _WatchListScreen extends State<WatchListScreen> {
  //poster base url
  var image_baseurl = "http://image.tmdb.org/t/p/w92//";

  //textController
  var _controller = TextEditingController();
  FocusNode _focusNode;

  // addMovieToDb
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
          .insertMovie(Movie(name: movie.name, url: movie.url, position: pos));
      //delete the text
      _controller.clear();
      _focusNode.unfocus();
    }
    //delete the text
    _controller.clear();
    _focusNode.unfocus();
  }

  @override
  void initState() {
    super.initState();

    //initialize it
    _focusNode = FocusNode();
  }

  Future<List<Movie>> searchMovies(value) async {
    Response response = await get(
        "https://api.themoviedb.org/3/search/movie?api_key=897a1f013542be95c6fd47b321604faa&query=$value");

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
    return Column(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
            child: Consumer<MovieDb>(
              builder: (context, movieDb, child) {
                return ReorderableListView(
                  onReorder: (int oldIndex, int newIndex) {
                    Provider.of<MovieDb>(context, listen: false)
                        .reorder(oldIndex, newIndex);
                  },
                  children: List.generate(
                    Provider.of<MovieDb>(context).movies.length,
                    (index) {
                      return Card(
                        key: ValueKey("$index"),
                        color: Colors.white,
                        child: Dismissible(
                          key: Key(Provider.of<MovieDb>(context)
                              .movies[index]
                              .id
                              .toString()),
                          background: Container(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Icon(
                                  Icons.delete_forever,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            color: Colors.red,
                          ),
                          direction: DismissDirection.endToStart,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            height: 60.0,
                            width: double.infinity,
                            child: Row(
                              children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(4.0), bottomLeft: Radius.circular(4.0),),
                                                          child: Image(
                                image: CachedNetworkImageProvider(
                                    Provider.of<MovieDb>(context)
                                        .movies[index]
                                        .url),
                              ),
                            ),
                            SizedBox(width: 10.0,),
                             Text(
                              Provider.of<MovieDb>(context).movies[index].name,
                              style: kTextStyle,
                            ),
                              ],
                            ),
                          ),
                          onDismissed: (DismissDirection direction) async {
                            //if direction == left, delete it
                            if (direction == DismissDirection.endToStart) {
//ie left swipe, so delete the element and update the entire widget
                              //check its position
                              var high = await movieDb.empytOrNot();
                              if (high == 0) {
                                await movieDb.deleteMovie(
                                    Provider.of<MovieDb>(context)
                                        .movies[index]
                                        .id);
                              } else if (Provider.of<MovieDb>(context)
                                      .movies[index]
                                      .position !=
                                  high) {
                                //check if not last movie
                                for (int i = Provider.of<MovieDb>(context)
                                            .movies[index]
                                            .position +
                                        1;
                                    i <= high;
                                    i++) {
                                  //dec - 1 for next movie or all movie below it
                                  await movieDb.updateMovie(
                                      Provider.of<MovieDb>(context).movies[i],
                                      i - 1);
                                }
                                await movieDb.deleteMovie(
                                    Provider.of<MovieDb>(context)
                                        .movies[index]
                                        .id);
                              } else if (Provider.of<MovieDb>(context)
                                      .movies[index]
                                      .position ==
                                  high) {
                                //last movie
                                await movieDb.deleteMovie(
                                    Provider.of<MovieDb>(context)
                                        .movies[index]
                                        .id);
                              }
                            }
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 7.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: TypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                        decoration: InputDecoration(
                          hintStyle: TextStyle(
                            height: 2.0,
                            fontSize: 17.0,
                            letterSpacing: 0.9,
                          ),
                          hintText: "Add a movie",
                          contentPadding:
                              EdgeInsets.only(left: 10.0, right: 7.0),
                        ),
                        controller: _controller,
                        focusNode: _focusNode,
                      ),
                      suggestionsCallback: (value) async {
                        //returns List<Movie>
                        return await searchMovies(value);
                      },
                      errorBuilder: (context, obj) {
                        return Container(
                          color: Colors.redAccent,
                          child: ListTile(
                            title: Text(
                              "No Internet...",
                              style: kTextStyle,
                            ),
                          ),
                        );
                      },
                      suggestionsBoxDecoration: SuggestionsBoxDecoration(
                        borderRadius: BorderRadius.circular(7.0),
                        color: Colors.white,
                      ),
                      noItemsFoundBuilder: (BuildContext context) {
                        return Container(
                          color: Colors.white,
                          child: ListTile(
                            title: Text(
                              "No Items Found!",
                              style: kTextStyle,
                            ),
                          ),
                        );
                      },
                      hideSuggestionsOnKeyboardHide: true,
                      direction: AxisDirection.up,
                      itemBuilder: (context, movie) {
                        return Container(
                          padding: EdgeInsets.only(bottom: 5.0, top: 5.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: ListTile(
                            leading: Image.network(movie.url),
                            title: Text(
                              movie.name,
                              style: kTextStyle,
                            ),
                          ),
                        );
                      },
                      onSuggestionSelected: (movie) {
                        addMovieToDb(movie);
                        _controller.clear();
                      }),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 10.0, bottom: 10.0),
                child: FloatingActionButton(
                  backgroundColor: Color(0xFF00FF00),
                  onPressed: () async {
                    if (_controller.text != null && _controller.text != "") {
                      addMovieToDb(Movie(name: _controller.text, url: 'none'));
                    }
                    _controller.clear();
                  },
                  child: Icon(Icons.add,
                  size: 22.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.clear();
    _focusNode.unfocus();
    _controller.dispose();
    _focusNode.dispose();

    
  }
}
