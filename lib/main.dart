import 'package:flutter/material.dart';
import 'synctra_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser le SDK Synctra
  await SynctraSDK.instance.initialize(
    apiBaseUrl:
        'http://192.168.0.109:8000', // Remplacez par votre URL de production
    projectId:
        '5890866f-a6cf-49df-9853-a256a1aa41de', // Remplacez par votre project ID
    apiKey:
        'sk_live_zxYkQUyKn1QVteARG3vDDTapHcuA_My_Rhwjq21cQpk', // Remplacez par votre API key
    onLinkReceived: (linkData) {
      debugPrint('Lien reçu: ${linkData.shortCode} -> ${linkData.originalUrl}');
    },
    onReferralDetected: (referralData) {
      debugPrint(
          'Code de parrainage détecté: ${referralData.code} (${referralData.rewardValue} ${referralData.rewardType})');
    },
    onError: (error) {
      debugPrint('Erreur SDK Synctra: $error');
    },
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Synctra SDK Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Synctra SDK Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _currentLinkId;
  String? _referralCode;
  String _status = 'SDK initialisé';
  SynctraLinkData? _currentLinkData;
  SynctraReferralData? _currentReferralData;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
    _setupSDKCallbacks();
  }

  void _setupSDKCallbacks() {
    SynctraSDK.instance.initialize(
      apiBaseUrl: '',
      projectId: '',
      apiKey: 'your_api_key_here',
      onLinkReceived: (linkData) {
        setState(() {
          _currentLinkData = linkData;
          _status = 'Lien reçu: ${linkData.shortCode}';
        });
        debugPrint(
            'Lien reçu: ${linkData.shortCode} -> ${linkData.originalUrl}');
      },
      onReferralDetected: (referralData) {
        setState(() {
          _currentReferralData = referralData;
          _status +=
              '\nCode parrainage: ${referralData.code} (${referralData.rewardValue} ${referralData.rewardType})';
        });
        debugPrint(
            'Code de parrainage détecté: ${referralData.code} (${referralData.rewardValue} ${referralData.rewardType})');
      },
      onError: (error) {
        setState(() {
          _status = 'Erreur: $error';
        });
        debugPrint('Erreur SDK Synctra: $error');
      },
    );
  }

  Future<void> _loadSavedData() async {
    final linkId = await SynctraSDK.instance.getCurrentLinkId();
    final referralCode = await SynctraSDK.instance.getReferralCode();

    setState(() {
      _currentLinkId = linkId;
      _referralCode = referralCode;
      if (linkId != null) {
        _status = 'Lien détecté: $linkId';
      }
      if (referralCode != null) {
        _status += '\nCode parrainage: $referralCode';
      }
    });
  }

  Future<void> _trackConversion() async {
    try {
      await SynctraSDK.instance.trackConversion(conversionValue: 10.0);
      setState(() {
        _status = 'Conversion trackée avec succès!';
      });
    } catch (e) {
      setState(() {
        _status = 'Erreur tracking: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'État du SDK',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations stockées',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text('Lien actuel: ${_currentLinkId ?? 'Aucun'}'),
                    Text('Code parrainage: ${_referralCode ?? 'Aucun'}'),
                  ],
                ),
              ),
            ),
            if (_currentLinkData != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Détails du lien reçu',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text('ID: ${_currentLinkData!.id}'),
                      Text('Code court: ${_currentLinkData!.shortCode}'),
                      Text('URL: ${_currentLinkData!.originalUrl}'),
                      if (_currentLinkData!.title != null)
                        Text('Titre: ${_currentLinkData!.title}'),
                      if (_currentLinkData!.referralCode != null)
                        Text(
                            'Code parrainage lié: ${_currentLinkData!.referralCode}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green)),
                    ],
                  ),
                ),
              ),
            ],
            if (_currentReferralData != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.card_giftcard, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            'Code de parrainage détecté',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.green.shade700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Code: ${_currentReferralData!.code}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                          'Type de récompense: ${_currentReferralData!.rewardType}'),
                      Text('Valeur: ${_currentReferralData!.rewardValue}'),
                      Text(
                          'Utilisations: ${_currentReferralData!.currentUses}/${_currentReferralData!.maxUses ?? '∞'}'),
                      Text(
                          'Actif: ${_currentReferralData!.isActive ? 'Oui' : 'Non'}'),
                      if (_currentReferralData!.expiresAt != null)
                        Text(
                            'Expire le: ${_currentReferralData!.expiresAt!.toLocal().toString().split(' ')[0]}'),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _trackConversion,
                child: const Text('Tracker une conversion'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loadSavedData,
                child: const Text('Actualiser les données'),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Instructions de test:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Pour tester les deep links:\n\n'
                '1. Lien dynamique:\n'
                'adb shell am start -W -a android.intent.action.VIEW -d "synctra://open?id=LINK_ID" com.example.synctra_sdk\n\n'
                '2. Code de parrainage simple:\n'
                'adb shell am start -W -a android.intent.action.VIEW -d "synctra://open?rel=CODE_PARRAINAGE" com.example.synctra_sdk\n\n'
                'Remplacez LINK_ID et CODE_PARRAINAGE par des valeurs valides',
                style: TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
