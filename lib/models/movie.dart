class Movie {
  int id;
  String name;
  String url;
  int position;
  int movie_id;
  String video;
  String backdrop_path;
  String desc;
  int year;
  double rating;
  dynamic minutes;
  List genres;
  dynamic cast;
  dynamic crew;
  String poster_path;

  Movie({ this.id, this.name, this.url, this.position, this.movie_id, this.video, this.backdrop_path, this.desc, this.year, this.rating, this.minutes, this.genres, this.cast, this.poster_path, this.crew});

  //convert Movie to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'position': position,
      'movie_id': movie_id,
    };
  }
}