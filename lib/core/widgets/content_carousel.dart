import 'package:flutter/material.dart';
import '../../data/models/content_model.dart';
import '../theme/colors.dart';
import '../theme/constants.dart';
import 'content_card.dart';

class ContentCarousel extends StatelessWidget {
  final String title;
  final List<ContentModel> items;
  final Function(ContentModel) onItemTap;
  final VoidCallback? onSeeAllTap;
  final bool isLoading;

  const ContentCarousel({
    super.key,
    required this.title,
    required this.items,
    required this.onItemTap,
    this.onSeeAllTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppThemeConstants.space16,
            vertical: AppThemeConstants.space8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (onSeeAllTap != null)
                TextButton(
                  onPressed: onSeeAllTap,
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppThemeConstants.space12,
            ),
            itemCount: isLoading ? 5 : items.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppThemeConstants.space4,
                ),
                child: SizedBox(
                  width: 120,
                  child: ContentCard(
                    content: isLoading ? null : items[index],
                    isLoading: isLoading,
                    onTap: isLoading ? null : () => onItemTap(items[index]),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
