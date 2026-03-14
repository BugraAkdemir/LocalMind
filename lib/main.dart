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
  Hive.registerAdapter(ServerProfileModelAdapter());
  Hive.registerAdapter(ConversationModelAdapter());
  Hive.registerAdapter(MessageModelAdapter());
  Hive.registerAdapter(SystemPromptModelAdapter());
  Hive.registerAdapter(SettingsModelAdapter());

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
