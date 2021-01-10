import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:watchlist/models/movie.dart';

class MovieDb extends ChangeNotifier {
  static Database _db;

  List<Movie> _movies = [];

  //get _movies
  UnmodifiableListView<Movie> get movies {
    return UnmodifiableListView(_movies);
  }

  //gets or makes a db
  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    //or it creates a new db
    _db = await initDatabase();
    return _db;
  }

  initDatabase() async {
    String path = join(await getDatabasesPath(), '_movies.db');
    var db = await openDatabase(path, onCreate: _onCreate, version: 1);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE movie(id INTEGER PRIMARY KEY, name TEXT, url TEXT, position INTEGER, movie_id INTEGER)");
  }

  //insert a Movie
  Future<void> insertMovie(Movie movie) async {
    //it should of type Map
    final Database database = await db;

    await database.insert('movie', movie.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    //after adding notify it
    await getMovies();
    notifyListeners();
  }

  //retrieve a List<Movie>
  Future getMovies() async {
    _movies = [];
    final Database database = await db;

    final List<Map<String, dynamic>> maps =
        await database.rawQuery("SELECT * FROM movie ORDER BY position ASC");

    //convert List<Map<String, dynamic>> to List<Movie>
    List.generate(maps.length, (i) {
      _movies.add(Movie(
        id: maps[i]['id'],
        name: maps[i]['name'],
        url: maps[i]['url'],
        position: maps[i]['position'],
        movie_id: maps[i]['movie_id'],
      ));
    });
  }

  //update
  Future<void> updateMovie(Movie movie, int newIndex) async {
    Database _db;
    if (_db == null) {
      _db = await db;
    }
    int id = movie.id;
    await _db.rawUpdate('''UPDATE movie SET position = ? WHERE id = ?''', [newIndex, id]);
    notifyListeners();
  }

  //delete
  Future<void> deleteMovie(int id) async {
    final database = await db;

    await database.delete('movie', where: 'id=?', whereArgs: [id]);
    await getMovies();
    notifyListeners();
  }

  void reorder(int oldIndex, int newIndex) async {
     var element = movies[oldIndex];
    //move up
    if (oldIndex > newIndex) {
      for (int i = newIndex; i < oldIndex; i++) {
        //update movies position at this i
        await updateMovie(movies[i], i + 1);
      }
      await updateMovie(element, newIndex);
    }
    //move down
    else if (oldIndex < newIndex) {
      for (int i = oldIndex + 1; i < newIndex; i++) {
        await updateMovie(movies[i], i - 1);
      }
      await updateMovie(element, newIndex);
    }
       await getMovies();
      notifyListeners();
  }


  //db empty or not
  Future<int> empytOrNot() async {
    final database = await db;
    var _movies = await database.rawQuery("SELECT * from movie", null);

    if (_movies.length > 0) {
      //find largest value of position
      var count = await database.rawQuery("SELECT MAX(position) FROM movie");
      return count[0]['MAX(position)'];
    } else {
      //return 0
      return null;
    }
  }

  //checks already exists or not
  Future<bool> checkMovie(String name) async {
    final Database database = await db;

    final List<Map<String, dynamic>> movie =
        await database.query('movie', where: "name=?", whereArgs: [name]);
    if (movie.length != 0) {
      //already a movie with this name exists
      return true;
    } else {
      return false;
    }
  }

  Future<void> closeDb() async {
    final database = await db;
    await database.close();
  }
}
