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
  final int? durationMinutes;

  @HiveField(9)
  final String type; // 'movie', 'short', 'series'

  @HiveField(10)
  final double? progress; // e.g. 0.45 (45%). Null if not started.

  @HiveField(11)
  final int? durationSeconds;

  ContentModel({
    required this.id,
    required this.title,
    required this.synopsis,
    required this.posterUrl,
    required this.backdropUrl,
    required this.genre,
    required this.rating,
    required this.releaseYear,
    this.durationMinutes,
    required this.type,
    this.progress,
    this.durationSeconds,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      synopsis: json['synopsis'] as String? ?? '',
      posterUrl:
          json['poster_url'] as String? ?? json['posterUrl'] as String? ?? '',
      backdropUrl:
          json['backdrop_url'] as String? ??
          json['backdropUrl'] as String? ??
          '',
      genre: List<String>.from(json['genre'] as List? ?? []),
      rating: json['avg_rating'] != null
          ? json['avg_rating'].toString()
          : (json['rating'] != null ? json['rating'].toString() : 'N/A'),
      releaseYear:
          json['release_year']?.toString() ??
          json['releaseYear']?.toString() ??
          '',
      durationMinutes:
          json['duration_minutes'] as int? ?? json['durationMinutes'] as int?,
      durationSeconds:
          json['duration_seconds'] as int? ?? json['durationSeconds'] as int?,
      type: json['type'] as String? ?? 'movie',
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
      'poster_url': posterUrl,
      'posterUrl': posterUrl,
      'backdrop_url': backdropUrl,
      'backdropUrl': backdropUrl,
      'genre': genre,
      'avg_rating': rating,
      'rating': rating,
      'release_year': releaseYear,
      'releaseYear': releaseYear,
      'duration_minutes': durationMinutes,
      'durationMinutes': durationMinutes,
      'duration_seconds': durationSeconds,
      'durationSeconds': durationSeconds,
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
    int? durationSeconds,
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
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }
}
