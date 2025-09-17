# Synctra SDK Flutter

SDK Flutter pour intégrer les fonctionnalités de tracking et deep linking de Synctra dans vos applications mobiles.

## Fonctionnalités

- ✅ **Détection première installation** : Identifie automatiquement les nouvelles installations
- ✅ **Matching de signature** : Associe les installations aux liens de parrainage
- ✅ **Deep linking** : Écoute et traite les liens entrants automatiquement
- ✅ **Codes de parrainage** : Récupère et stocke les codes de parrainage
- ✅ **Analytics** : Tracking complet des interactions utilisateur

## Installation

Ajoutez le SDK à votre `pubspec.yaml` :

```yaml
dependencies:
  synctra_sdk:
    path: ../synctra_sdk
```

## Configuration

### 1. Initialisation

```dart
import 'package:synctra_sdk/synctra_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SynctraSDK.instance.initialize(
    apiBaseUrl: 'https://your-api-url.com',
    projectId: 'your-project-id',
    onLinkReceived: (linkData) {
      print('Lien reçu: ${linkData.shortCode}');
    },
    onReferralDetected: (referralData) {
      print('Code parrainage: ${referralData.code}');
    },
    onError: (error) {
      print('Erreur SDK: $error');
    },
  );
  
  runApp(MyApp());
}
```

### 2. Configuration Android

Ajoutez dans `android/app/src/main/AndroidManifest.xml` :

```xml
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:launchMode="singleTop"
    android:theme="@style/LaunchTheme">
    
    <!-- Intent filter pour les deep links -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="myapp" />
    </intent-filter>
</activity>
```

### 3. Configuration iOS

Ajoutez dans `ios/Runner/Info.plist` :

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>myapp.deeplink</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>myapp</string>
        </array>
    </dict>
</array>
```

## Utilisation

### Récupérer les informations actuelles

```dart
// ID du lien actuel
String? linkId = await SynctraSDK.instance.getCurrentLinkId();

// Code de parrainage stocké
String? referralCode = await SynctraSDK.instance.getReferralCode();
```

### Écouter les événements

```dart
SynctraSDK.instance.initialize(
  // ... configuration
  onLinkReceived: (SynctraLinkData linkData) {
    // Traiter le lien reçu
    print('Titre: ${linkData.title}');
    print('URL: ${linkData.originalUrl}');
    print('UTM: ${linkData.utmParams}');
  },
  onReferralDetected: (SynctraReferralData referralData) {
    // Traiter le code de parrainage
    print('Code: ${referralData.code}');
    print('Récompense: ${referralData.rewardValue} ${referralData.rewardType}');
    print('Utilisations: ${referralData.currentUses}/${referralData.maxUses}');
  },
);
```

## Modèles de données

### SynctraLinkData

```dart
class SynctraLinkData {
  final String id;
  final String shortCode;
  final String originalUrl;
  final String? title;
  final String? description;
  final String? referralCode;
  final Map<String, dynamic>? utmParams;
}
```

### SynctraReferralData

```dart
class SynctraReferralData {
  final String code;
  final String rewardType;
  final double rewardValue;
  final int? maxUses;
  final int currentUses;
  final bool isActive;
  final DateTime? expiresAt;
}
```

## Flux de fonctionnement

1. **Installation** → Le SDK détecte la première ouverture
2. **Signature** → Génère une signature unique du device
3. **Matching** → Recherche une signature correspondante dans la BD
4. **Attribution** → Associe l'installation au lien/code de parrainage
5. **Deep links** → Écoute les liens entrants en continu
6. **Stockage** → Sauvegarde les informations localement

## Exemple complet

Voir le fichier `example/lib/main.dart` pour un exemple d'implémentation complète.

## Support

- **Android** : API 21+ (Android 5.0)
- **iOS** : iOS 11.0+
- **Flutter** : 3.0.0+

## APIs Backend requises

Le SDK nécessite les endpoints suivants sur votre backend :

- `POST /api/v1/sdk/match-signature` - Matching de signature
- `GET /api/v1/sdk/link/{id}` - Données du lien  
- `GET /api/v1/sdk/referral/{code}` - Données du code de parrainage
