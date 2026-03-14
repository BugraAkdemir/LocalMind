import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/widgets/connection_indicator.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../data/models/server_profile_model.dart';
import '../providers/server_provider.dart';

class ServerConnectionScreen extends ConsumerStatefulWidget {
  const ServerConnectionScreen({super.key});

  @override
  ConsumerState<ServerConnectionScreen> createState() => _ServerConnectionScreenState();
}

class _ServerConnectionScreenState extends ConsumerState<ServerConnectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _hostController = TextEditingController(text: ApiConstants.defaultHost);
  final _portController = TextEditingController(text: ApiConstants.defaultPort.toString());
  
  bool _isTesting = false;
  String? _testResult;
  bool _testSuccess = false;

  @override
  void dispose() {
    _nameController.dispose();
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }
  
  String _sanitizeHost(String rawHost) {
    String cleaned = rawHost.trim().toLowerCase();
    if (cleaned.startsWith('http://')) cleaned = cleaned.substring(7);
    if (cleaned.startsWith('https://')) cleaned = cleaned.substring(8);
    if (cleaned.endsWith('/')) cleaned = cleaned.substring(0, cleaned.length - 1);
    
    // Suggest 10.0.2.2 for Android emulator localhost
    if (cleaned == 'localhost' || cleaned == '127.0.0.1') {
      // In a real app we might check Platform.isAndroid, but 10.0.2.2 is safe to hint.
      // cleaned = '10.0.2.2'; // Auto-replace can be aggressive, let's just keep as is 
      // but the user might fail if on emulator. We'll add a helper text instead.
    }
    return cleaned;
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final sanitizedHost = _sanitizeHost(_hostController.text);
    _hostController.text = sanitizedHost;

    final tempServer = ServerProfileModel(
      id: 'temp',
      name: _nameController.text,
      host: sanitizedHost,
      port: int.parse(_portController.text),
    );

    try {
      final success = await ref.read(connectionTestProvider(tempServer).future);
      if (mounted) {
        setState(() {
          _testSuccess = success;
          _testResult = success ? 'Connection successful!' : 'Connection failed. Please check IP and Port.';
          _isTesting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _testSuccess = false;
          _testResult = 'Error: Cannot reach server. Check IP, Port, and Network.';
          _isTesting = false;
        });
      }
    }
  }

  void _saveServer() {
    if (!_formKey.currentState!.validate() || !_testSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please test the connection first')),
      );
      return;
    }

    final sanitizedHost = _sanitizeHost(_hostController.text);
    final newServer = ServerProfileModel(
      id: const Uuid().v4(),
      name: _nameController.text.isNotEmpty ? _nameController.text : 'My LM Studio',
      host: sanitizedHost,
      port: int.parse(_portController.text),
    );

    ref.read(serversProvider.notifier).addServer(newServer);
    
    _nameController.clear();
    _hostController.text = ApiConstants.defaultHost;
    _portController.text = ApiConstants.defaultPort.toString();
    setState(() {
      _testResult = null;
      _testSuccess = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Server saved as active!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final servers = ref.watch(serversProvider);
    final serverConn = ref.watch(activeServerConnectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LM Studio Connection'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Connect to Local AI',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the IP address of the computer running LM Studio. Ensure the local server is started.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),
              ),
              const SizedBox(height: 24),
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _hostController,
                        decoration: InputDecoration(
                          labelText: 'Host IP Address',
                          hintText: 'e.g., 192.168.1.100',
                          prefixIcon: const Icon(Icons.computer),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.url,
                        validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Name (Optional)',
                                hintText: 'My Desktop',
                                prefixIcon: const Icon(Icons.label_outline),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _portController,
                              decoration: InputDecoration(
                                labelText: 'Port',
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Required';
                                if (int.tryParse(value) == null) return 'Invalid';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      if (_testResult != null) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _testSuccess ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _testSuccess ? Colors.green : Colors.red.shade400),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _testSuccess ? Icons.check_circle : Icons.error_outline,
                                color: _testSuccess ? Colors.green : Colors.red.shade400,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _testResult!,
                                  style: TextStyle(
                                    color: _testSuccess ? Colors.green : Colors.red.shade400,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isTesting ? null : _testConnection,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isTesting 
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('Test Connection'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: _testSuccess ? _saveServer : null,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Save & Connect'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 36),
              if (servers.isNotEmpty) ...[
                Text(
                  'Saved Servers',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: servers.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final server = servers[index];
                    final isActive = server.isActive;
                    
                    return GlassCard(
                      padding: const EdgeInsets.all(4),
                      backgroundColor: isActive 
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                          : Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
                      child: ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isActive 
                                ? Theme.of(context).colorScheme.primary 
                                : Theme.of(context).colorScheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isActive ? Icons.hub : Icons.computer,
                            color: isActive ? Colors.white : Colors.grey.shade400,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          server.name,
                          style: TextStyle(
                            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                            color: isActive ? Colors.white : Colors.grey.shade300,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              ConnectionIndicator(
                                isConnected: isActive && (serverConn.valueOrNull?.isConnected ?? false),
                                isConnecting: isActive &&
                                    (serverConn.isLoading ||
                                        (serverConn.valueOrNull?.isConnecting ?? false)),
                                size: 8,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${server.host}:${server.port}',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: isActive 
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : IconButton(
                              icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
                              onPressed: () {
                                ref.read(serversProvider.notifier).deleteServer(server.id);
                              },
                            ),
                        onTap: () {
                          ref.read(serversProvider.notifier).setActiveServer(server.id);
                        },
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
