import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../server/presentation/providers/server_provider.dart';
import '../providers/model_provider.dart';
import 'package:mobile_locallm/core/localization/app_i18n.dart';

class ModelSelectionScreen extends ConsumerWidget {
  const ModelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppI18n.of(context);
    final activeServer = ref.watch(activeServerProvider);
    final modelsAsync = ref.watch(availableModelsProvider);
    final selectedModelId = ref.watch(selectedModelIdProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.selectModel),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refresh,
            onPressed: () => ref.refresh(availableModelsProvider),
          ),
        ],
      ),
      body: activeServer == null
          ? Center(
              child: Text(
                l10n.pleaseConnectServerFirst,
                style: TextStyle(color: AppColors.textMuted),
              ),
            )
          : modelsAsync.when(
              loading: () => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) => const GlassCard(
                  padding: EdgeInsets.all(16),
                  child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoader(width: double.infinity, height: 20),
                      SizedBox(height: 8),
                      SkeletonLoader(width: 150, height: 14),
                    ],
                  ),
                ),
              ),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        '${l10n.failedToLoadModels}\n${err.toString()}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => ref.refresh(availableModelsProvider),
                        child: Text(l10n.tryAgain),
                      ),
                    ],
                  ),
                ),
              ),
              data: (models) {
                if (models.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.noModelsFound,
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  );
                }

                // If no model is selected but we have models, select the first one automatically
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (selectedModelId == null && models.isNotEmpty) {
                    ref.read(selectedModelIdProvider.notifier).state = models.first['id'] as String;
                  }
                });

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: models.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final model = models[index];
                    final String id = model['id'] ?? 'Unknown';
                    final int? size = model['size']; // Note: 'size' might not be provided by all backends
                    
                    // Simple size formatting if available
                    String sizeText = '';
                    if (size != null) {
                       final gb = size / (1024 * 1024 * 1024);
                       sizeText = '${gb.toStringAsFixed(2)} GB';
                    }

                    final isSelected = id == selectedModelId;

                    return GlassCard(
                      padding: const EdgeInsets.all(4),
                      backgroundColor: isSelected 
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                          : null,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected 
                              ? AppColors.accent 
                              : AppColors.surfaceLight,
                          child: Icon(
                            Icons.memory,
                            color: isSelected ? AppColors.surface : AppColors.textMuted,
                          ),
                        ),
                        title: Text(
                          id,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  l10n.localModel,
                                  style: TextStyle(color: isSelected ? AppColors.accentLight : AppColors.textMuted),
                                ),
                                if (sizeText.isNotEmpty) ...[
                                  Text(' • ', style: TextStyle(color: AppColors.textMuted)),
                                  Text(sizeText, style: TextStyle(color: AppColors.textMuted)),
                                ]
                              ],
                            ),
                            const SizedBox(height: 4),
                            // Capability Badges
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: [
                                if (id.toLowerCase().contains('vision'))
                                  _buildBadge(context, l10n.vision, Icons.remove_red_eye, AppColors.info),
                                if (id.toLowerCase().contains('tool') || id.toLowerCase().contains('function'))
                                  _buildBadge(context, l10n.tools, Icons.build, AppColors.warning),
                                if (id.toLowerCase().contains('embed'))
                                  _buildBadge(context, l10n.embedding, Icons.layers, AppColors.accentDark),
                                if (id.toLowerCase().contains('instruct') || id.toLowerCase().contains('chat'))
                                  _buildBadge(context, l10n.chat, Icons.chat, AppColors.success),
                              ],
                            ),
                          ],
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: AppColors.accent)
                            : null,
                        onTap: () {
                          ref.read(selectedModelIdProvider.notifier).state = id;
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.modelSetTo(id))),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildBadge(BuildContext context, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
