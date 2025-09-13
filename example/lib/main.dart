/// Application d'exemple démontrant l'utilisation du SDK Synctra.
/// 
/// Cette application montre comment :
/// - Initialiser le SDK Synctra
/// - Créer des liens dynamiques
/// - Gérer les codes de parrainage
/// - Afficher les informations du SDK
library;

import 'package:flutter/material.dart';
import 'package:synctra_sdk/synctra_sdk.dart';

/// Point d'entrée principal de l'application d'exemple.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  const config = SynctraConfig(
    apiKey: 'your_api_key_here',
    projectId: 'your_project_id_here',
    debugMode: true,
  );
  
  await SynctraSDK.initialize(config);
  
  runApp(const SynctraExampleApp());
}

/// Widget racine de l'application d'exemple Synctra.
class SynctraExampleApp extends StatelessWidget {
  /// Crée une nouvelle instance de [SynctraExampleApp].
  const SynctraExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Synctra SDK Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const HomePage(),
    );
  }
}

/// Page d'accueil de l'application d'exemple.
/// 
/// Affiche une interface permettant de tester les fonctionnalités
/// principales du SDK Synctra.
class HomePage extends StatefulWidget {
  /// Crée une nouvelle instance de [HomePage].
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _urlController = TextEditingController();
  final _referralController = TextEditingController();
  String? _createdLink;
  String? _message;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    await SynctraSDK.instance.setUserId('demo_user_${DateTime.now().millisecondsSinceEpoch}');
  }

  Future<void> _createLink() async {
    if (_urlController.text.isEmpty) {
      _showMessage('Veuillez entrer une URL');
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final link = await SynctraSDK.instance.createLink(
        originalUrl: _urlController.text,
        parameters: {
          'source': 'demo_app',
          'timestamp': DateTime.now().toIso8601String(),
        },
        fallbackUrl: 'https://synctra.link',
      );

      setState(() {
        _createdLink = link.shortUrl;
        _message = 'Lien créé avec succès !';
      });
    } catch (e) {
      _showMessage('Erreur: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createReferralCode() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final referralCode = await SynctraSDK.instance.createReferralCode(
        customCode: _referralController.text.isNotEmpty ? _referralController.text : null,
        maxUses: 10,
        rewardAmount: 5.0,
        rewardType: 'credit',
      );

      setState(() {
        _message = 'Code de parrainage créé: ${referralCode.code}';
      });
    } catch (e) {
      _showMessage('Erreur: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Synctra SDK Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Créer un lien dynamique',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        labelText: 'URL à raccourcir',
                        hintText: 'https://example.com',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _createLink,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Créer le lien'),
                    ),
                    if (_createdLink != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Lien créé:'),
                            const SizedBox(height: 4),
                            SelectableText(
                              _createdLink!,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Code de parrainage',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _referralController,
                      decoration: const InputDecoration(
                        labelText: 'Code personnalisé (optionnel)',
                        hintText: 'MONCODE123',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _createReferralCode,
                      child: const Text('Créer le code'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations SDK',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Statut', SynctraSDK.instance.isInitialized ? 'Initialisé' : 'Non initialisé'),
                    _buildInfoRow('User ID', SynctraSDK.instance.userId ?? 'Non défini'),
                    _buildInfoRow('Session ID', SynctraSDK.instance.sessionId ?? 'Non défini'),
                    _buildInfoRow('Device ID', SynctraSDK.instance.deviceId ?? 'Non défini'),
                  ],
                ),
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _message!.startsWith('Erreur') 
                      ? Theme.of(context).colorScheme.errorContainer
                      : Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _message!,
                  style: TextStyle(
                    color: _message!.startsWith('Erreur')
                        ? Theme.of(context).colorScheme.onErrorContainer
                        : Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    _referralController.dispose();
    super.dispose();
  }
}
