import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/app.dart';
import 'features/server/data/models/server_profile_model.dart';
import 'features/chat/data/models/conversation_model.dart';
import 'features/chat/data/models/message_model.dart';
import 'features/prompts/data/models/system_prompt_model.dart';

import 'features/settings/data/models/settings_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load();
  } catch (e) {
    debugPrint("Warning: .env file loading failed: $e");
  }

  await Hive.initFlutter();

  // Register Hive adapters
  // Hot-restart will re-run `main()`; guard adapter registration to avoid exceptions.
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(ServerProfileModelAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(ConversationModelAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(MessageModelAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(SystemPromptModelAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(SettingsModelAdapter());
  }

  // Open boxes
  await Hive.openBox<ServerProfileModel>('servers');
  await Hive.openBox<ConversationModel>('conversations');
  await Hive.openBox<SystemPromptModel>('prompts');
  await Hive.openBox<SettingsModel>('settings');

  runApp(
    const ProviderScope(
      child: LocalLMApp(),
    ),
  );
}
