import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/colors.dart';

class ReviewsScreen extends StatefulWidget {
  final String contentId;
  final String contentTitle;

  const ReviewsScreen({
    super.key,
    required this.contentId,
    required this.contentTitle,
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  String _sortBy = 'Most Recent';
  List<Map<String, dynamic>> _reviews = [];

  final List<Color> _avatarColors = const [
    Colors.amber,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.red,
    Colors.orange,
  ];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  void _loadReviews() {
    final list = [
      {
        'userName': 'Aarav Mehta',
        'rating': 5,
        'text':
            'Absolutely stunning! The visual effects and sound design are top tier. A must watch on a large screen.',
        'date': 'Aug 01, 2026',
        'timestamp': 1772428800000, // mock epoch
      },
      {
        'userName': 'Priya Sharma',
        'rating': 4,
        'text':
            'Great storyline and acting. The pacing is a bit slow in the middle, but the climax makes up for it completely.',
        'date': 'Jul 30, 2026',
        'timestamp': 1772256000000,
      },
      {
        'userName': 'Vikram Rathore',
        'rating': 5,
        'text':
            'Outstanding performances! Easily one of the best releases this year. Totally worth the subscription.',
        'date': 'Jul 29, 2026',
        'timestamp': 1772169600000,
      },
      {
        'userName': 'John Doe',
        'rating': 3,
        'text':
            'Decent watch. Expected a bit more action based on the trailer, but it is a good one-time watch.',
        'date': 'Jul 28, 2026',
        'timestamp': 1772083200000,
      },
    ];

    _sortReviews(list);
  }

  void _sortReviews(List<Map<String, dynamic>> list) {
    if (_sortBy == 'Most Recent') {
      list.sort(
        (a, b) => (b['timestamp'] as num).compareTo(a['timestamp'] as num),
      );
    } else {
      list.sort((a, b) => (b['rating'] as num).compareTo(a['rating'] as num));
    }
    setState(() {
      _reviews = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate Average
    double avg = 0.0;
    if (_reviews.isNotEmpty) {
      avg =
          _reviews.map((r) => r['rating'] as int).reduce((a, b) => a + b) /
          _reviews.length;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Reviews',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              widget.contentTitle,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Average Rating Header Block
          Container(
            padding: const EdgeInsets.all(20),
            color: AppColors.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      textBaseline: TextBaseline.alphabetic,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      children: [
                        Text(
                          avg.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          '/5.0',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < avg.round()
                              ? LucideIcons.star
                              : LucideIcons.star,
                          color: index < avg.round()
                              ? AppColors.primary
                              : Colors.white12,
                          size: 14,
                        );
                      }),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Based on ${_reviews.length} ratings',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                // Sort Dropdown
                DropdownButton<String>(
                  value: _sortBy,
                  dropdownColor: AppColors.surface,
                  underline: const SizedBox(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Most Recent',
                      child: Text('Most Recent'),
                    ),
                    DropdownMenuItem(
                      value: 'Highest Rated',
                      child: Text('Highest Rated'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _sortBy = val;
                      });
                      _sortReviews(_reviews);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Reviews List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                final rev = _reviews[index];
                final avatarColor = _avatarColors[index % _avatarColors.length];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1F1F1F)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User header details
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: avatarColor,
                                child: Text(
                                  rev['userName']
                                      .toString()
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                rev['userName'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            rev['date'] as String,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Star Ratings row
                      Row(
                        children: List.generate(5, (sIndex) {
                          return Icon(
                            LucideIcons.star,
                            color: sIndex < (rev['rating'] as int)
                                ? AppColors.primary
                                : Colors.white10,
                            size: 12,
                          );
                        }),
                      ),
                      const SizedBox(height: 8),

                      // Review text description
                      Text(
                        rev['text'] as String,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
