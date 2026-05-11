import '../../domain/entities/news_article.dart';

/// NewsArticleModel — Data Layer
///
/// Extends the domain entity with JSON serialisation/deserialisation.
/// Handles the API ↔ domain mapping — the domain never knows about JSON.
class NewsArticleModel extends NewsArticle {
  const NewsArticleModel({
    super.id,
    required super.title,
    required super.content,
    super.sourceUrl,
    super.sourceName,
    super.affectedCountries,
    super.economicSector,
    super.aiImpactSummary,
    super.publishedAt,
    super.createdAt,
  });

  factory NewsArticleModel.fromJson(Map<String, dynamic> json) {
    return NewsArticleModel(
      id: json['id'] as int?,
      title: json['title'] as String,
      content: json['content'] as String,
      sourceUrl: json['sourceUrl'] as String?,
      sourceName: json['sourceName'] as String?,
      affectedCountries: json['affectedCountries'] as String?,
      economicSector: json['economicSector'] != null
          ? EconomicSector.values.firstWhere(
              (e) => e.name == json['economicSector'],
              orElse: () => EconomicSector.OTHER,
            )
          : null,
      aiImpactSummary: json['aiImpactSummary'] as String?,
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'title': title,
        'content': content,
        if (sourceUrl != null) 'sourceUrl': sourceUrl,
        if (sourceName != null) 'sourceName': sourceName,
        if (affectedCountries != null) 'affectedCountries': affectedCountries,
        if (economicSector != null) 'economicSector': economicSector!.name,
      };
}
