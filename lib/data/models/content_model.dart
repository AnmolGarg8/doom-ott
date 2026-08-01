import 'package:hive/hive.dart';

part 'content_model.g.dart';

@HiveType(typeId: 0)
class ContentModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String thumbnailUrl;

  @HiveField(4)
  final String videoUrl;

  @HiveField(5)
  final String duration;

  @HiveField(6)
  final String releaseYear;

  @HiveField(7)
  final String rating;

  @HiveField(8)
  final List<String> genres;

  @HiveField(9)
  final List<String> cast;

  @HiveField(10)
  final bool isMovie;

  @HiveField(11)
  final String? category;

  ContentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.duration,
    required this.releaseYear,
    required this.rating,
    required this.genres,
    required this.cast,
    required this.isMovie,
    this.category,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      videoUrl: json['videoUrl'] as String,
      duration: json['duration'] as String,
      releaseYear: json['releaseYear'] as String,
      rating: json['rating'] as String,
      genres: List<String>.from(json['genres'] as List),
      cast: List<String>.from(json['cast'] as List),
      isMovie: json['isMovie'] as bool,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'duration': duration,
      'releaseYear': releaseYear,
      'rating': rating,
      'genres': genres,
      'cast': cast,
      'isMovie': isMovie,
      'category': category,
    };
  }
}
