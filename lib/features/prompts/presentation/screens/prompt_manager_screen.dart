import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../data/models/system_prompt_model.dart';
import '../providers/prompt_provider.dart';
import 'package:mobile_locallm/core/localization/app_i18n.dart';

class PromptManagerScreen extends ConsumerStatefulWidget {
  const PromptManagerScreen({super.key});

  @override
  ConsumerState<PromptManagerScreen> createState() => _PromptManagerScreenState();
}

class _PromptManagerScreenState extends ConsumerState<PromptManagerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _savePrompt() {
    if (!_formKey.currentState!.validate()) return;

    final newPrompt = SystemPromptModel(
      id: const Uuid().v4(),
      name: _titleController.text,
      content: _contentController.text,
    );

    ref.read(systemPromptsProvider.notifier).addPrompt(newPrompt);
    
    _titleController.clear();
    _contentController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppI18n.of(context).promptSavedSuccessfully)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppI18n.of(context);
    final prompts = ref.watch(systemPromptsProvider);
    final activePromptId = ref.watch(activeSystemPromptIdProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.systemPromptsTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.createNewPrompt,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: l10n.promptTitle,
                        hintText: l10n.promptTitleHint,
                      ),
                      validator: (value) =>
                        value == null || value.isEmpty ? l10n.required : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _contentController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: l10n.systemPromptContent,
                        hintText: l10n.systemPromptContentHint,
                      ),
                      validator: (value) =>
                        value == null || value.isEmpty ? l10n.required : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _savePrompt,
                      icon: const Icon(Icons.save),
                      label: Text(l10n.savePrompt),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              l10n.savedPrompts,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            
            if (prompts.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    l10n.noSystemPromptsSaved,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: prompts.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final prompt = prompts[index];
                  final isSelected = prompt.id == activePromptId;
                  
                  return GlassCard(
                    padding: const EdgeInsets.all(8),
                    backgroundColor: isSelected 
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                        : null,
                    child: ListTile(
                      title: Text(
                        prompt.name,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.accentLight : AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        prompt.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected) 
                            const Icon(Icons.check_circle, color: AppColors.accent, size: 20),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                            onPressed: () {
                              ref.read(systemPromptsProvider.notifier).deletePrompt(prompt.id);
                              if (isSelected) {
                                ref.read(activeSystemPromptIdProvider.notifier).state = null;
                              }
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        // Toggle selection
                        if (isSelected) {
                           ref.read(activeSystemPromptIdProvider.notifier).state = null;
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(content: Text(l10n.clearedActiveSystemPrompt)),
                           );
                        } else {
                           ref.read(activeSystemPromptIdProvider.notifier).state = prompt.id;
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(content: Text(l10n.setActivePrompt(prompt.name))),
                           );
                        }
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
