import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(const EconImpactApp());
}

class EconImpactApp extends StatelessWidget {
  const EconImpactApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EconImpact PH',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}

class BackendCheckScreen extends StatefulWidget {
  const BackendCheckScreen({super.key});

  @override
  State<BackendCheckScreen> createState() => _BackendCheckScreenState();
}

class _BackendCheckScreenState extends State<BackendCheckScreen> {
  // Dynamically pick the right host:
  //   - Web / Windows desktop → localhost
  //   - Android emulator      → 10.0.2.2  (maps to host machine)
  static String get _backendUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/health';
    }
    return 'http://10.0.2.2:8000/health';
  }

  String _statusText = 'Checking...';
  String _responseBody = '';
  Color _statusColor = Colors.white54;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    checkBackendConnection();
  }

  Future<void> checkBackendConnection() async {
    setState(() {
      _isLoading = true;
      _statusText = 'Connecting...';
      _statusColor = Colors.white54;
    });

    try {
      final response = await http
          .get(Uri.parse(_backendUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _statusText = 'Backend: Connected';
          _responseBody = const JsonEncoder.withIndent('  ').convert(data);
          _statusColor = const Color(0xFF2DA44E); // green
          _isLoading = false;
        });
      } else {
        setState(() {
          _statusText = 'Backend: Error (HTTP ${response.statusCode})';
          _responseBody = response.body;
          _statusColor = Colors.redAccent;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusText = 'Backend: Error';
        _responseBody = e.toString();
        _statusColor = Colors.redAccent;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // Keeping dark mode just for the dev screen
      appBar: AppBar(
        title: const Text('Developer Backend Check'),
        backgroundColor: const Color(0xFF161B22),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo / Icon
              const Icon(
                Icons.bar_chart_rounded,
                size: 72,
                color: Color(0xFF1A73E8),
              ),
              const SizedBox(height: 20),
              const Text(
                'EconImpact PH',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Backend Connection Test',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 48),

              // Status Indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _statusColor.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _isLoading
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _statusColor,
                            ),
                          )
                        : Icon(
                            _statusColor == Colors.redAccent
                                ? Icons.error_outline
                                : Icons.check_circle_outline,
                            color: _statusColor,
                            size: 20,
                          ),
                    const SizedBox(width: 10),
                    Text(
                      _statusText,
                      style: TextStyle(
                        color: _statusColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Response body
              if (_responseBody.isNotEmpty) ...[
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    _responseBody,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Retry button
              TextButton.icon(
                onPressed: checkBackendConnection,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1A73E8),
                ),
              ),

              const SizedBox(height: 16),
              Text(
                'Endpoint: $_backendUrl',
                style: const TextStyle(color: Colors.white24, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
