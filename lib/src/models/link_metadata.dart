import 'package:meta/meta.dart';

@immutable
class LinkMetadata {
  final String title;
  final String? description;
  final String? imageUrl;
  final String? iconUrl;
  final String? siteName;
  final String? author;
  final DateTime? publishedAt;
  final List<String> tags;
  final Map<String, dynamic> customData;

  const LinkMetadata({
    required this.title,
    this.description,
    this.imageUrl,
    this.iconUrl,
    this.siteName,
    this.author,
    this.publishedAt,
    this.tags = const [],
    this.customData = const {},
  });

  factory LinkMetadata.fromJson(Map<String, dynamic> json) {
    return LinkMetadata(
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      iconUrl: json['iconUrl'] as String?,
      siteName: json['siteName'] as String?,
      author: json['author'] as String?,
      publishedAt: json['publishedAt'] != null 
          ? DateTime.parse(json['publishedAt'] as String) 
          : null,
      tags: List<String>.from(json['tags'] as List? ?? []),
      customData: Map<String, dynamic>.from(json['customData'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'iconUrl': iconUrl,
      'siteName': siteName,
      'author': author,
      'publishedAt': publishedAt?.toIso8601String(),
      'tags': tags,
      'customData': customData,
    };
  }

  LinkMetadata copyWith({
    String? title,
    String? description,
    String? imageUrl,
    String? iconUrl,
    String? siteName,
    String? author,
    DateTime? publishedAt,
    List<String>? tags,
    Map<String, dynamic>? customData,
  }) {
    return LinkMetadata(
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      iconUrl: iconUrl ?? this.iconUrl,
      siteName: siteName ?? this.siteName,
      author: author ?? this.author,
      publishedAt: publishedAt ?? this.publishedAt,
      tags: tags ?? this.tags,
      customData: customData ?? this.customData,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LinkMetadata && other.title == title;
  }

  @override
  int get hashCode => title.hashCode;

  @override
  String toString() {
    return 'LinkMetadata(title: $title, siteName: $siteName)';
  }
}
