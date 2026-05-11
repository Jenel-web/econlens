import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

// Dummy Model
class NewsItem {
  final String title;
  final String summary;
  final String category;
  final String tag;
  final Color tagColor;
  final String anoNangyari;
  final String paanoMakakaApekto;
  final List<String> apektadongLarangan;
  final Map<String, String> tinantyangEpekto;
  final List<String> praktikalNaPayo;

  NewsItem({
    required this.title,
    required this.summary,
    required this.category,
    required this.tag,
    required this.tagColor,
    required this.anoNangyari,
    required this.paanoMakakaApekto,
    required this.apektadongLarangan,
    required this.tinantyangEpekto,
    required this.praktikalNaPayo,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<NewsItem> _dummyNews = [
    NewsItem(
      title: 'Fuel Prices Spike for 4th Consecutive Week',
      summary: 'The Department of Energy confirms a significant increase in per-liter costs for diesel and gasoline effective tomorrow morning.',
      category: 'Fuel',
      tag: '↑ Critical',
      tagColor: AppTheme.error,
      anoNangyari: 'Nag-anunsyo ang Department of Energy (DOE) ng panibagong pagtaas sa presyo ng petrolyo. Tumaas ng P1.50 bawat litro ang gasolina at P2.10 bawat litro ang diesel.',
      paanoMakakaApekto: 'Asahan ang posibleng pagtaas ng pamasahe at presyo ng mga pang-araw-araw na bilihin dahil sa mas mataas na gastos sa transportasyon ng mga produkto.',
      apektadongLarangan: ['Transportasyon', 'Bilihin (Lalo na ang mga gulay at isda)'],
      tinantyangEpekto: {
        'Gasolina (Buwanan)': '+P300 (Kung kumukonsumo ng 200L/buwan)',
        'Pamasahe (Jeep)': 'Posibleng +P1-P2 sa susunod na buwan',
      },
      praktikalNaPayo: [
        'Mag-carpool o gumamit ng pampublikong transportasyon kung maaari.',
        'Pagplanuhan ang mga biyahe para makatipid sa gas.',
        'Iwasang mag-idle ang makina nang matagal.'
      ],
    ),
    NewsItem(
      title: 'Rice Ceiling Price Lifted',
      summary: 'Local markets observe stabilized pricing as seasonal harvests begin to hit the shelves across major regional hubs.',
      category: 'Food',
      tag: 'Stabilized',
      tagColor: AppTheme.primary,
      anoNangyari: 'Tinanggal na ang price ceiling sa bigas na P41/kg para sa regular milled at P45/kg para sa well-milled rice dahil nagsimula na ang anihan.',
      paanoMakakaApekto: 'Posibleng maging mas available na ulit ang iba\'t ibang klase ng bigas sa palengke, at inaasahang unti-unting bababa ang presyo kumpara noong nakaraang buwan.',
      apektadongLarangan: ['Badyet sa Pagkain', 'Karinderya/Food Business'],
      tinantyangEpekto: {
        'Bigas (Kilo)': 'Posibleng bumaba ng P2-P4/kilo kumpara noong kasagsagan ng krisis',
      },
      praktikalNaPayo: [
        'Bumili ng bigas nang bultuhan (per sack) kung may sapat na budget para makatipid sa retail price.',
        'Subukan ang ibang sources ng carbohydrates tulad ng kamote, saging (saba), o mais bilang alternatibo.',
        'Maging mapagmatyag sa suggested retail price (SRP) sa mga palengke upang maiwasan ang pananamantala.'
      ],
    ),
    NewsItem(
      title: 'Jeepney Modernization Update',
      summary: 'New routes opened for modern PUVs in Metro Manila to improve commuter flow during peak holiday rush hours.',
      category: 'Transport',
      tag: 'Update',
      tagColor: AppTheme.secondary,
      anoNangyari: 'Nagbukas ang DOTr ng 15 bagong ruta para sa mga modern jeepneys sa iba\'t ibang bahagi ng Metro Manila upang maibsan ang siksikan ngayong paparating na holiday season.',
      paanoMakakaApekto: 'Magiging mas madali at komportable ang pag-commute sa mga piling lugar, ngunit maaaring mas mataas nang bahagya ang pamasahe kumpara sa mga tradisyonal na jeepney.',
      apektadongLarangan: ['Araw-araw na Biyahe', 'Badyet sa Pamasahe'],
      tinantyangEpekto: {
        'Oras ng Biyahe': 'Maaaring mabawasan ng 15-20 minuto',
        'Pamasahe (Base fare)': 'P15 (Modern Jeep) kumpara sa P13 (Tradisyonal)',
      },
      praktikalNaPayo: [
        'Alamin ang mga bagong ruta upang mas mapabilis ang iyong pag-commute.',
        'Maghanda ng beep card o barya para sa mas mabilis na transaksyon.',
        'Maging maaga pa rin sa pag-alis lalo na sa rush hour.'
      ],
    ),
    NewsItem(
      title: 'Inflation Hits 5.4% in September',
      summary: 'PSA reports higher transport and food costs as the primary drivers for the recent surge, affecting urban household budgets significantly.',
      category: 'Economy',
      tag: '↑ 5.4%',
      tagColor: AppTheme.error,
      anoNangyari: 'Iniulat ng Philippine Statistics Authority (PSA) na pumalo sa 5.4% ang inflation rate noong Setyembre, ang pinakamataas sa loob ng nakalipas na anim na buwan.',
      paanoMakakaApekto: 'Mas mabilis na mauubos ang pondo para sa mga pang-araw-araw na gastusin. Mas mahihirapan mag-ipon ang mga pamilya dahil halos lahat ng pangunahing bilihin ay nagtaasan ang presyo.',
      apektadongLarangan: ['Lahat ng Bilihin', 'Transportasyon', 'Kuryente'],
      tinantyangEpekto: {
        'Pangkalahatang Badyet': 'Kailangan ng karagdagang 5.4% sa budget para makabili ng parehong dami ng produkto kumpara noong nakaraang taon.',
      },
      praktikalNaPayo: [
        'Bawasan ang pagbili ng mga hindi masyadong kailangang gamit.',
        'Maghanap ng mga alternatibong brand na mas mura ngunit de-kalidad.',
        'Siguraduhing naka-budget nang maigi ang sahod buwan-buwan.'
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoNews PH'),
        backgroundColor: AppTheme.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppTheme.onSurface),
            onPressed: () {
              context.push('/notifications');
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Categories Header (Placeholder)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('All News', true),
                _buildCategoryChip('Fuel Prices', false),
                _buildCategoryChip('Basic Goods', false),
                _buildCategoryChip('Transport', false),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          Text('Latest Updates', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          
          // News Cards
          ..._dummyNews.map((news) => _buildNewsCard(news)),
          
          const SizedBox(height: 24),
          const Center(
            child: Text('You\'ve caught up with all the economic pillars today.',
              style: TextStyle(color: AppTheme.outline),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          if (index == 0) {
            setState(() {
              _currentIndex = index;
            });
          } else if (index == 1) {
            context.push('/settings');
          } else if (index == 2) {
            context.push('/about');
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
          NavigationDestination(icon: Icon(Icons.info_outline), label: 'About'),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {},
        backgroundColor: AppTheme.surface,
        selectedColor: AppTheme.tertiary,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primary : AppTheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildNewsCard(NewsItem news) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/article', extra: news);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    news.category,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: news.tagColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      news.tag,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: news.tagColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                news.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                news.summary,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              const Divider(color: AppTheme.outlineVariant),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.menu_book, size: 16, color: AppTheme.outline),
                  const SizedBox(width: 8),
                  Text('Read Full Article', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.primary)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
