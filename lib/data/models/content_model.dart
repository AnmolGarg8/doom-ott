import 'package:hive/hive.dart';

part 'content_model.g.dart';

@HiveType(typeId: 0)
class ContentModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String synopsis;

  @HiveField(3)
  final String posterUrl;

  @HiveField(4)
  final String backdropUrl;

  @HiveField(5)
  final List<String> genre;

  @HiveField(6)
  final String rating;

  @HiveField(7)
  final String releaseYear;

  @HiveField(8)
  final int durationMinutes;

  @HiveField(9)
  final String type; // 'movie', 'short', 'series'

  @HiveField(10)
  final double? progress; // e.g. 0.45 (45%). Null if not started.

  ContentModel({
    required this.id,
    required this.title,
    required this.synopsis,
    required this.posterUrl,
    required this.backdropUrl,
    required this.genre,
    required this.rating,
    required this.releaseYear,
    required this.durationMinutes,
    required this.type,
    this.progress,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      synopsis: json['synopsis'] as String,
      posterUrl: json['posterUrl'] as String,
      backdropUrl: json['backdropUrl'] as String,
      genre: List<String>.from(json['genre'] as List),
      rating: json['rating'] as String,
      releaseYear: json['releaseYear'] as String,
      durationMinutes: json['durationMinutes'] as int,
      type: json['type'] as String,
      progress: json['progress'] != null
          ? (json['progress'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'synopsis': synopsis,
      'posterUrl': posterUrl,
      'backdropUrl': backdropUrl,
      'genre': genre,
      'rating': rating,
      'releaseYear': releaseYear,
      'durationMinutes': durationMinutes,
      'type': type,
      'progress': progress,
    };
  }

  ContentModel copyWith({
    String? id,
    String? title,
    String? synopsis,
    String? posterUrl,
    String? backdropUrl,
    List<String>? genre,
    String? rating,
    String? releaseYear,
    int? durationMinutes,
    String? type,
    double? progress,
  }) {
    return ContentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      synopsis: synopsis ?? this.synopsis,
      posterUrl: posterUrl ?? this.posterUrl,
      backdropUrl: backdropUrl ?? this.backdropUrl,
      genre: genre ?? this.genre,
      rating: rating ?? this.rating,
      releaseYear: releaseYear ?? this.releaseYear,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      type: type ?? this.type,
      progress: progress ?? this.progress,
    );
  }
}
