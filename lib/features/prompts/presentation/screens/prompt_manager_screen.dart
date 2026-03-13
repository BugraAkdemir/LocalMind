import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../data/models/system_prompt_model.dart';
import '../providers/prompt_provider.dart';

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
      const SnackBar(content: Text('Prompt saved successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prompts = ref.watch(systemPromptsProvider);
    final activePromptId = ref.watch(activeSystemPromptIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Prompts'),
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
                      'Create New Prompt',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Prompt Title',
                        hintText: 'e.g. Helpful Assistant',
                      ),
                      validator: (value) => 
                        value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _contentController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'System Prompt Content',
                        hintText: 'You are a helpful AI assistant...',
                      ),
                      validator: (value) => 
                        value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _savePrompt,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Prompt'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'Saved Prompts',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            
            if (prompts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'No system prompts saved.',
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
                             const SnackBar(content: Text('Cleared active system prompt')),
                           );
                        } else {
                           ref.read(activeSystemPromptIdProvider.notifier).state = prompt.id;
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(content: Text('Set active prompt: ${prompt.name}')),
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
