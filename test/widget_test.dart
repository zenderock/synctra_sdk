// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:synctra_sdk/synctra_sdk.dart';

void main() {
  group('SynctraSDK Tests', () {
    test('SynctraConfig creation', () {
      const config = SynctraConfig(
        apiKey: 'test_api_key',
        projectId: 'test_project_id',
      );

      expect(config.apiKey, 'test_api_key');
      expect(config.projectId, 'test_project_id');
      expect(config.enableAnalytics, true);
      expect(config.enableDeepLinking, true);
      expect(config.enableReferrals, true);
    });

    test('DeepLink model', () {
      final deepLink = DeepLink(
        id: 'test_id',
        originalUrl: 'https://example.com',
        shortUrl: 'https://short.ly/abc123',
        parameters: {'key': 'value'},
        createdAt: DateTime.now(),
      );

      expect(deepLink.id, 'test_id');
      expect(deepLink.originalUrl, 'https://example.com');
      expect(deepLink.isValid, true);
    });

    test('ReferralCode model', () {
      final referralCode = ReferralCode(
        code: 'TEST123',
        userId: 'user_123',
        createdAt: DateTime.now(),
      );

      expect(referralCode.code, 'TEST123');
      expect(referralCode.userId, 'user_123');
      expect(referralCode.isValid, true);
    });

    test('AnalyticsEvent model', () {
      final event = AnalyticsEvent(
        id: 'event_123',
        type: AnalyticsEventType.linkClicked,
        linkId: 'link_123',
        timestamp: DateTime.now(),
      );

      expect(event.id, 'event_123');
      expect(event.type, AnalyticsEventType.linkClicked);
      expect(event.linkId, 'link_123');
    });
  });
}
