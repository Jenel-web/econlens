/// NewsArticle — Domain Entity (Flutter)
///
/// Mirror of the Spring Boot domain entity.
/// No HTTP/JSON concerns here — pure business object.
class NewsArticle {
  final int? id;
  final String title;
  final String content;
  final String? sourceUrl;
  final String? sourceName;
  final String? affectedCountries;
  final EconomicSector? economicSector;
  final String? aiImpactSummary;
  final DateTime? publishedAt;
  final DateTime? createdAt;

  const NewsArticle({
    this.id,
    required this.title,
    required this.content,
    this.sourceUrl,
    this.sourceName,
    this.affectedCountries,
    this.economicSector,
    this.aiImpactSummary,
    this.publishedAt,
    this.createdAt,
  });
}

enum EconomicSector {
  ENERGY,
  TRADE,
  FINANCE,
  AGRICULTURE,
  TECHNOLOGY,
  GEOPOLITICS,
  OTHER,
}
