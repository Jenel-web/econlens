import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../home/home_screen.dart' show NewsItem;

class ArticleDetailScreen extends StatelessWidget {
  final NewsItem news;
  
  const ArticleDetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              news.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {},
              child: Text(
                'Original Report',
                style: TextStyle(
                  color: AppTheme.primary,
                  decoration: TextDecoration.underline,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            _buildSectionTitle(context, 'Ano ang nangyari?'),
            Text(
              news.anoNangyari,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            
            _buildSectionTitle(context, 'Paano ito makaka-apekto sa atin?'),
            Text(
              news.paanoMakakaApekto,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            
            _buildSectionTitle(context, 'Mga Apektadong Larangan'),
            ...news.apektadongLarangan.map((larangan) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.arrow_right, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(larangan, style: Theme.of(context).textTheme.bodyMedium)),
                ],
              ),
            )),
            const SizedBox(height: 24),
            
            _buildSectionTitle(context, 'Tinantyang Epekto sa Budget'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: news.tinantyangEpekto.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.key, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Text(entry.value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 24),
            
            _buildSectionTitle(context, 'Praktikal na Payo'),
            ...news.praktikalNaPayo.map((payo) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: AppTheme.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(payo, style: Theme.of(context).textTheme.bodyMedium)),
                ],
              ),
            )),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
