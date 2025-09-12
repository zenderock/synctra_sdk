import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import '../models/models.dart';
import '../utils/utils.dart';
import 'api_service.dart';

class AnalyticsService {
  final ApiService _apiService;
  final List<AnalyticsEvent> _pendingEvents = [];
  Timer? _batchTimer;
  
  static const int _batchSize = 50;
  static const Duration _batchInterval = Duration(seconds: 30);

  AnalyticsService(this._apiService) {
    _startBatchTimer();
    _loadPendingEvents();
  }

  Future<void> trackEvent({
    required AnalyticsEventType type,
    required String linkId,
    Map<String, dynamic>? properties,
    String? userId,
    String? sessionId,
    String? deviceId,
  }) async {
    try {
      final deviceInfo = await DeviceUtils.getDeviceInfo();
      
      final event = AnalyticsEvent(
        id: CryptoUtils.generateUuid(),
        type: type,
        linkId: linkId,
        timestamp: DateTime.now(),
        properties: properties ?? {},
        userId: userId ?? await StorageUtils.getUserId(),
        sessionId: sessionId ?? await StorageUtils.getSessionId(),
        deviceId: deviceId ?? await StorageUtils.getDeviceId(),
        platform: deviceInfo['platform'] as String?,
        appVersion: deviceInfo['version'] as String?,
      );

      _pendingEvents.add(event);
      await _savePendingEvents();

      if (_pendingEvents.length >= _batchSize) {
        await _flushEvents();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du tracking de l\'événement: $e');
      }
    }
  }

  Future<void> trackLinkClick(String linkId, {Map<String, dynamic>? properties}) async {
    await trackEvent(
      type: AnalyticsEventType.linkClicked,
      linkId: linkId,
      properties: properties,
    );
  }

  Future<void> trackLinkOpen(String linkId, {Map<String, dynamic>? properties}) async {
    await trackEvent(
      type: AnalyticsEventType.linkOpened,
      linkId: linkId,
      properties: properties,
    );
  }

  Future<void> trackAppInstall(String linkId, {Map<String, dynamic>? properties}) async {
    await trackEvent(
      type: AnalyticsEventType.appInstalled,
      linkId: linkId,
      properties: properties,
    );
  }

  Future<void> trackAppOpen(String linkId, {Map<String, dynamic>? properties}) async {
    await trackEvent(
      type: AnalyticsEventType.appOpened,
      linkId: linkId,
      properties: properties,
    );
  }

  Future<void> trackReferralUsed(String linkId, String referralCode, {Map<String, dynamic>? properties}) async {
    final eventProperties = Map<String, dynamic>.from(properties ?? {});
    eventProperties['referralCode'] = referralCode;
    
    await trackEvent(
      type: AnalyticsEventType.referralUsed,
      linkId: linkId,
      properties: eventProperties,
    );
  }

  Future<void> trackConversion(String linkId, {
    double? value,
    String? currency,
    Map<String, dynamic>? properties,
  }) async {
    final eventProperties = Map<String, dynamic>.from(properties ?? {});
    if (value != null) eventProperties['value'] = value;
    if (currency != null) eventProperties['currency'] = currency;
    
    await trackEvent(
      type: AnalyticsEventType.conversionCompleted,
      linkId: linkId,
      properties: eventProperties,
    );
  }

  Future<void> trackCustomEvent(String linkId, String eventName, {Map<String, dynamic>? properties}) async {
    final eventProperties = Map<String, dynamic>.from(properties ?? {});
    eventProperties['eventName'] = eventName;
    
    await trackEvent(
      type: AnalyticsEventType.customEvent,
      linkId: linkId,
      properties: eventProperties,
    );
  }

  Future<void> flush() async {
    await _flushEvents();
  }

  Future<void> _flushEvents() async {
    if (_pendingEvents.isEmpty) return;

    try {
      final eventsToSend = List<AnalyticsEvent>.from(_pendingEvents);
      _pendingEvents.clear();
      await _savePendingEvents();

      final response = await _apiService.post(
        '/analytics/events',
        body: {
          'events': eventsToSend.map((e) => e.toJson()).toList(),
        },
      );

      if (!response.success) {
        _pendingEvents.addAll(eventsToSend);
        await _savePendingEvents();
        
        if (kDebugMode) {
          print('Erreur lors de l\'envoi des événements: ${response.message}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de l\'envoi des événements: $e');
      }
    }
  }

  void _startBatchTimer() {
    _batchTimer?.cancel();
    _batchTimer = Timer.periodic(_batchInterval, (_) => _flushEvents());
  }

  Future<void> _savePendingEvents() async {
    try {
      final eventsJson = _pendingEvents.map((e) => e.toJson()).toList();
      await StorageUtils.saveAnalyticsEvents(eventsJson);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la sauvegarde des événements: $e');
      }
    }
  }

  Future<void> _loadPendingEvents() async {
    try {
      final eventsJson = await StorageUtils.getAnalyticsEvents();
      _pendingEvents.clear();
      
      for (final eventJson in eventsJson) {
        try {
          final event = AnalyticsEvent.fromJson(eventJson);
          _pendingEvents.add(event);
        } catch (e) {
          if (kDebugMode) {
            print('Erreur lors du chargement d\'un événement: $e');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du chargement des événements: $e');
      }
    }
  }

  void dispose() {
    _batchTimer?.cancel();
    _flushEvents();
  }

  @visibleForTesting
  List<AnalyticsEvent> get pendingEvents => List.unmodifiable(_pendingEvents);
}
