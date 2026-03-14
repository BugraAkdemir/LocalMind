import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppI18n {
  final Locale locale;

  const AppI18n(this.locale);

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  static const LocalizationsDelegate<AppI18n> delegate = _AppI18nDelegate();

  static AppI18n of(BuildContext context) {
    final value = Localizations.of<AppI18n>(context, AppI18n);
    assert(value != null, 'AppI18n not found in context');
    return value!;
  }

  bool get _tr => locale.languageCode == 'tr';

  String get appName => 'LocalLM';

  String get connected => _tr ? 'Bagli' : 'Connected';
  String get connecting => _tr ? 'Baglaniyor...' : 'Connecting...';
  String get disconnected => _tr ? 'Bagli degil' : 'Disconnected';

  String get noServerConnected => _tr ? 'Sunucu bagli degil' : 'No server connected';
  String get noServerSelected => _tr ? 'Sunucu secilmedi' : 'No server selected';

  String get controlCenter => _tr ? 'Kontrol Merkezi' : 'Control Center';
  String get conversations => _tr ? 'Sohbetler' : 'Conversations';
  String get conversationsSubtitle => _tr ? 'Gecmis, adlandirma veya silme.' : 'Switch, rename, or delete.';
  String get newChat => _tr ? 'Yeni sohbet' : 'New chat';
  String get newChatShort => _tr ? 'Yeni' : 'New';
  String get close => _tr ? 'Kapat' : 'Close';
  String get delete => _tr ? 'Sil' : 'Delete';

  String get servers => _tr ? 'Sunucular' : 'Servers';
  String get models => _tr ? 'Modeller' : 'Models';
  String get settings => _tr ? 'Ayarlar' : 'Settings';
  String get systemPrompts => _tr ? 'Sistem istemleri' : 'System prompts';

  String get clearMessages => _tr ? 'Mesajlari temizle' : 'Clear messages';
  String get clearChatHistoryTitle => _tr ? 'Sohbet gecmisi temizlensin mi?' : 'Clear chat history?';
  String get clearChatHistoryBody => _tr
      ? 'Bu islem mevcut sohbetteki tum mesajlari silecek.'
      : 'This will delete all messages in the current conversation.';
  String get cancel => _tr ? 'Iptal' : 'Cancel';
  String get clear => _tr ? 'Temizle' : 'Clear';

  String get noConversationsYet => _tr ? 'Henuz sohbet yok.' : 'No conversations yet.';
  String messagesCount(int count) => _tr ? '$count mesaj' : '$count messages';

  String get typeToStart => _tr ? 'Baslamak icin mesaj yaz.' : 'Type a message to start.';
  String get welcomeTagline => _tr
      ? 'Kendi modellerinle, yerel-oncelikli ozel sohbet.'
      : 'Private, local-first chat with your own models.';
  String get noCloudStoredOnDevice => _tr ? 'Bulut yok. Cihazda saklanir.' : 'No cloud. Stored on device.';

  String get messageHint => _tr ? "LocalLM'e mesaj yaz" : 'Message LocalLM';
  String get listening => _tr ? 'Dinleniyor...' : 'Listening...';
  String get microphonePermissionRequired => _tr
      ? 'Sesli giris icin mikrofon izni gerekli.'
      : 'Microphone permission is required for voice input.';
  String get imageAttached => _tr ? 'Gorsel eklendi' : 'Image attached';
  String get takePhoto => _tr ? 'Foto cek' : 'Take a photo';
  String get chooseFromGallery => _tr ? 'Galeriden sec' : 'Choose from gallery';
  String get copiedToClipboard => _tr ? 'Panoya kopyalandi' : 'Copied to clipboard';
  String get thinking => _tr ? 'Dusunuyor...' : 'Thinking...';

  String get refresh => _tr ? 'Yenile' : 'Refresh';
  String get selectModel => _tr ? 'Model sec' : 'Select model';
  String get pleaseConnectServerFirst => _tr ? 'Once bir sunucuya baglanin.' : 'Please connect to a server first.';
  String get failedToLoadModels => _tr ? 'Modeller yuklenemedi:' : 'Failed to load models:';
  String get tryAgain => _tr ? 'Tekrar dene' : 'Try again';
  String get noModelsFound => _tr ? 'Bu sunucuda model bulunamadi.' : 'No models found on this server.';
  String get localModel => _tr ? 'Yerel model' : 'Local model';
  String modelSetTo(String id) => _tr ? 'Model secildi: $id' : 'Model set to: $id';
  String get vision => _tr ? 'Gorsel' : 'Vision';
  String get tools => _tr ? 'Araclar' : 'Tools';
  String get embedding => 'Embedding';
  String get chat => _tr ? 'Sohbet' : 'Chat';

  String get lmStudioConnection => _tr ? 'LM Studio baglantisi' : 'LM Studio connection';
  String get connectToLocalAI => _tr ? 'Yerel yapay zekaya baglan' : 'Connect to local AI';
  String get connectInstruction => _tr
      ? 'LM Studio calisan bilgisayarin IP adresini girin. Yerel sunucunun baslatildigindan emin olun.'
      : 'Enter the IP address of the computer running LM Studio. Ensure the local server is started.';
  String get hostIpAddress => _tr ? 'Sunucu IP adresi' : 'Host IP address';
  String get ipHint => _tr ? 'or. 192.168.1.100' : 'e.g., 192.168.1.100';
  String get name => _tr ? 'Ad' : 'Name';
  String get nameOptional => _tr ? 'Ad (opsiyonel)' : 'Name (optional)';
  String get nameHint => _tr ? 'Masaustum' : 'My desktop';
  String get port => 'Port';
  String get required => _tr ? 'Zorunlu' : 'Required';
  String get invalid => _tr ? 'Gecersiz' : 'Invalid';
  String get testConnection => _tr ? 'Baglantiyi test et' : 'Test connection';
  String get saveAndConnect => _tr ? 'Kaydet ve baglan' : 'Save and connect';
  String get connectionSuccessful => _tr ? 'Baglanti basarili!' : 'Connection successful!';
  String get connectionFailed => _tr ? 'Baglanti basarisiz. IP ve portu kontrol edin.' : 'Connection failed. Please check IP and port.';
  String get cannotReachServer => _tr
      ? 'Hata: Sunucuya ulasilamiyor. IP, port ve agi kontrol edin.'
      : 'Error: Cannot reach server. Check IP, port, and network.';
  String get pleaseTestConnectionFirst => _tr ? 'Once baglantiyi test edin' : 'Please test the connection first';
  String get serverSavedAsActive => _tr ? 'Sunucu aktif olarak kaydedildi!' : 'Server saved as active!';
  String get savedServers => _tr ? 'Kayitli sunucular' : 'Saved servers';

  String get systemPromptsTitle => _tr ? 'Sistem istemleri' : 'System prompts';
  String get createNewPrompt => _tr ? 'Yeni istem olustur' : 'Create new prompt';
  String get promptTitle => _tr ? 'Istem basligi' : 'Prompt title';
  String get promptTitleHint => _tr ? 'or. Yardimci asistan' : 'e.g. Helpful assistant';
  String get systemPromptContent => _tr ? 'Sistem istemi icerigi' : 'System prompt content';
  String get systemPromptContentHint => _tr ? 'Sen yardimci bir yapay zeka asistansin...' : 'You are a helpful AI assistant...';
  String get savePrompt => _tr ? 'Istemi kaydet' : 'Save prompt';
  String get promptSavedSuccessfully => _tr ? 'Istem basariyla kaydedildi' : 'Prompt saved successfully';
  String get savedPrompts => _tr ? 'Kayitli istemler' : 'Saved prompts';
  String get noSystemPromptsSaved => _tr ? 'Kayitli sistem istemi yok.' : 'No system prompts saved.';
  String get clearedActiveSystemPrompt => _tr ? 'Aktif sistem istemi kaldirildi' : 'Cleared active system prompt';
  String setActivePrompt(String name) => _tr ? 'Aktif istem ayarlandi: $name' : 'Set active prompt: $name';

  String get appearance => _tr ? 'Gorunum' : 'Appearance';
  String get themeMode => _tr ? 'Tema modu' : 'Theme mode';
  String get textSize => _tr ? 'Yazi boyutu' : 'Text size';
  String get systemAndLogic => _tr ? 'Sistem ve mantik' : 'System & logic';
  String get manageAiPersonalities => _tr ? "AI kisiliklerini ve davranisini yonet" : 'Manage AI personalities and behavior';
  String get experimental => _tr ? 'Deneysel' : 'Experimental';
  String get betaFeatures => _tr ? 'Beta ozellikler' : 'Beta features';
  String get enableExperimentalRestartRequired => _tr
      ? 'Deneysel ozellikleri ac (Yeniden baslatma gerekebilir)'
      : 'Enable experimental features (Restart required)';
  String get aiPreferences => _tr ? 'AI tercihleri' : 'AI preferences';
  String get voiceOutput => _tr ? 'Sesli cikti' : 'Voice output';
  String get speakResponsesAutomatically => _tr ? 'Yaniti otomatik seslendir' : 'Speak AI responses automatically';
  String get enableAiTools => _tr ? 'AI araclarini ac' : 'Enable AI tools';
  String get enableToolsSubtitle => _tr
      ? "AI'in batarya/cihaz bilgisine erismesine izin ver (Kapatmak arac istemlerini gizler)"
      : 'Allow AI to access battery/device info (Disable to hide tool prompts)';
  String get voiceAssistantBeta => _tr ? 'Sesli asistan (Beta)' : 'Voice assistant (Beta)';
  String get wakeWordAssistant => _tr ? 'Uyanma kelimesi asistani' : 'Wake word assistant';
  String get listenInBackground => _tr ? 'Arka planda komutlar icin dinle' : 'Listen in background for voice commands';
  String get wakeWordKeyword => _tr ? 'Uyanma kelimesi' : 'Wake word keyword';
  String get sensitivityCalibration => _tr ? 'Hassasiyet ayari' : 'Sensitivity calibration';
  String get porcupineAccessKey => _tr ? 'Porcupine AccessKey' : 'Porcupine AccessKey';
  String get notSetRequiredForWakeWord => _tr ? 'Ayarlanmadı (Uyanma kelimesi icin gerekli)' : 'Not set (Required for wake word)';

  String get betaWarningTitleShort => _tr ? 'Beta ozellikler acilsin mi?' : 'Enable beta features?';
  String get betaWarningBodyShort => _tr
      ? 'Bu ozellikler deneysel olabilir ve kararliligi etkileyebilir. Yeniden baslatma gerekebilir.'
      : 'These features are experimental and may affect stability. Restart may be required.';
  String get iUnderstand => _tr ? 'Anladim' : 'I understand';

  String get language => _tr ? 'Dil' : 'Language';
  String get english => _tr ? 'Ingilizce' : 'English';
  String get turkish => _tr ? 'Turkce' : 'Turkish';
  String get selectTheme => _tr ? 'Tema sec' : 'Select theme';
  String get selectTextSize => _tr ? 'Yazi boyutu sec' : 'Select text size';
  String get light => _tr ? 'Acik' : 'Light';
  String get dark => _tr ? 'Koyu' : 'Dark';
  String get system => _tr ? 'Sistem' : 'System';
  String get small => _tr ? 'Kucuk' : 'Small';
  String get medium => _tr ? 'Orta' : 'Medium';
  String get large => _tr ? 'Buyuk' : 'Large';
  String get enterAccessKey => _tr ? 'AccessKey gir' : 'Enter AccessKey';
  String get enterPicovoiceAccessKey => _tr ? 'Picovoice AccessKey gir' : 'Enter Picovoice AccessKey';
  String get save => _tr ? 'Kaydet' : 'Save';
  String get gotIt => _tr ? 'Anladim' : 'Got it';
  String get howToGetAccessKey => _tr ? 'AccessKey nasil alinır?' : 'How to get AccessKey?';
  String get accessKeyStep1 => _tr ? '1. console.picovoice.ai adresine git' : '1. Visit console.picovoice.ai';
  String get accessKeyStep2 => _tr ? '2. Ucretsiz hesap olustur.' : '2. Create a free account.';
  String get accessKeyStep3 => _tr ? '3. Panelden "AccessKey" degerini kopyala.' : '3. Copy your "AccessKey" from the dashboard.';
  String get accessKeyRequiredOffline => _tr
      ? 'Bu anahtar, uyanma kelimesi motorunun cevrimdisi calismasi icin gereklidir.'
      : 'This key is required for the wake word engine to work offline.';
}

class _AppI18nDelegate extends LocalizationsDelegate<AppI18n> {
  const _AppI18nDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'en' || locale.languageCode == 'tr';

  @override
  Future<AppI18n> load(Locale locale) => SynchronousFuture(AppI18n(locale));

  @override
  bool shouldReload(_AppI18nDelegate old) => false;
}
