import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/content_model.dart';
import '../theme/colors.dart';
import '../theme/constants.dart';
import 'loading_shimmer.dart';

class ContentCard extends StatelessWidget {
  final ContentModel? content;
  final VoidCallback? onTap;
  final bool isLoading;

  const ContentCard({
    super.key,
    this.content,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading || content == null) {
      return const AspectRatio(
        aspectRatio: 2 / 3,
        child: LoadingShimmer(
          width: double.infinity,
          height: double.infinity,
          borderRadius: AppThemeConstants.radiusCard,
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 2 / 3,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppThemeConstants.radiusCard),
            color: AppColors.surface,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: content!.posterUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const LoadingShimmer(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: AppThemeConstants.radiusCard,
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.surface,
                  child: const Icon(Icons.broken_image, color: AppColors.muted),
                ),
              ),
              // Bottom gradient and title overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.only(
                    left: AppThemeConstants.space8,
                    right: AppThemeConstants.space8,
                    top: AppThemeConstants.space8,
                    bottom: AppThemeConstants.space12,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black87,
                        Colors.black,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.6, 1.0],
                    ),
                  ),
                  child: Text(
                    content!.title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onBackground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              // Progress Bar overlay
              if (content!.progress != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 4,
                    color: Colors.white24,
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: content!.progress!.clamp(0.0, 1.0),
                      child: Container(color: AppColors.primary),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
