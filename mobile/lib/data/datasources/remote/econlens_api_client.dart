import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_article_model.dart';

/// EconLensApiClient — Data Layer (Remote Data Source)
///
/// Handles all HTTP communication with the Spring Boot backend.
/// Base URL is read from the environment — never hardcoded.
class EconLensApiClient {
  final http.Client _client;
  final String _baseUrl;

  EconLensApiClient({
    http.Client? client,
    required String baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl;

  // ---- News Articles ----

  Future<List<NewsArticleModel>> getArticles() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/api/v1/news'),
      headers: _headers(),
    );
    _checkStatus(response);
    final List<dynamic> json = jsonDecode(response.body);
    return json.map((e) => NewsArticleModel.fromJson(e)).toList();
  }

  Future<NewsArticleModel> getArticle(int id) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/api/v1/news/$id'),
      headers: _headers(),
    );
    _checkStatus(response);
    return NewsArticleModel.fromJson(jsonDecode(response.body));
  }

  Future<NewsArticleModel> submitArticle(NewsArticleModel article) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/v1/news'),
      headers: _headers(),
      body: jsonEncode(article.toJson()),
    );
    _checkStatus(response);
    return NewsArticleModel.fromJson(jsonDecode(response.body));
  }

  // ---- Private helpers ----

  Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  void _checkStatus(http.Response response) {
    if (response.statusCode >= 400) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'API Error: ${response.body}',
      );
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException({required this.statusCode, required this.message});
  @override
  String toString() => 'ApiException($statusCode): $message';
}
