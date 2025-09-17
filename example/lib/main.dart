import 'package:flutter/material.dart';
import 'package:synctra_sdk/synctra_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Synctra SDK Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _status = 'Initialisation...';
  SynctraLinkData? _currentLink;
  SynctraReferralData? _currentReferral;

  @override
  void initState() {
    super.initState();
    _initializeSynctra();
  }

  Future<void> _initializeSynctra() async {
    try {
      await SynctraSDK.instance.initialize(
        apiBaseUrl: 'http://10.42.0.1:8000',
        projectId: '5890866f-a6cf-49df-9853-a256a1aa41de',
        apiKey: 'your_api_key_here',
        onLinkReceived: (linkData) {
          setState(() {
            _currentLink = linkData;
            _status = 'Lien reçu: ${linkData.shortCode}';
          });
        },
        onReferralDetected: (referralData) {
          setState(() {
            _currentReferral = referralData;
            _status = 'Code parrainage détecté: ${referralData.code}';
          });
        },
        onError: (error) {
          setState(() {
            _status = 'Erreur: $error';
          });
        },
      );
      
      setState(() {
        _status = 'SDK initialisé avec succès';
      });
    } catch (e) {
      setState(() {
        _status = 'Erreur initialisation: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Synctra SDK Example'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(_status),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            if (_currentLink != null) ...[
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Lien actuel:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('ID: ${_currentLink!.id}'),
                      Text('Code: ${_currentLink!.shortCode}'),
                      Text('URL: ${_currentLink!.originalUrl}'),
                      if (_currentLink!.title != null)
                        Text('Titre: ${_currentLink!.title}'),
                      if (_currentLink!.referralCode != null)
                        Text('Code parrainage: ${_currentLink!.referralCode}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_currentReferral != null) ...[
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Code de parrainage:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Code: ${_currentReferral!.code}'),
                      Text('Type récompense: ${_currentReferral!.rewardType}'),
                      Text('Valeur: ${_currentReferral!.rewardValue}'),
                      Text('Utilisations: ${_currentReferral!.currentUses}/${_currentReferral!.maxUses ?? "∞"}'),
                      Text('Actif: ${_currentReferral!.isActive ? "Oui" : "Non"}'),
                      if (_currentReferral!.expiresAt != null)
                        Text('Expire le: ${_currentReferral!.expiresAt}'),
                    ],
                  ),
                ),
              ),
            ],
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final linkId = await SynctraSDK.instance.getCurrentLinkId();
                      setState(() {
                        _status = 'ID lien actuel: ${linkId ?? "Aucun"}';
                      });
                    },
                    child: const Text('Lien actuel'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final referralCode = await SynctraSDK.instance.getReferralCode();
                      setState(() {
                        _status = 'Code parrainage: ${referralCode ?? "Aucun"}';
                      });
                    },
                    child: const Text('Code parrainage'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    SynctraSDK.instance.dispose();
    super.dispose();
  }
}
