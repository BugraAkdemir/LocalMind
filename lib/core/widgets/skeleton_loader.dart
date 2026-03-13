import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../app/theme/app_colors.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.cardSurface,
      highlightColor: AppColors.border,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class MessageSkeletonLoader extends StatelessWidget {
  const MessageSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Assistant" message skeleton
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonLoader(width: 32, height: 32, borderRadius: 16),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonLoader(width: 80, height: 12),
                    const SizedBox(height: 8),
                    SkeletonLoader(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: 14,
                    ),
                    const SizedBox(height: 6),
                    SkeletonLoader(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: 14,
                    ),
                    const SizedBox(height: 6),
                    SkeletonLoader(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
