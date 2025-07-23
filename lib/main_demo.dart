import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/reading_settings_provider.dart';
import 'providers/user_stats_provider.dart';
import 'widgets/loading/smart_loading_widget.dart';
import 'widgets/error/smart_error_widget.dart';
import 'widgets/performance/performance_monitor.dart';
import 'widgets/profile/profile_stats_widget.dart';
import 'widgets/books/reading_progress_bar.dart';
import 'widgets/books/reading_settings_panel.dart';
import 'widgets/offline/connection_status_widget.dart';

void main() {
  runApp(const AlterTaleDemoApp());
}

class AlterTaleDemoApp extends StatelessWidget {
  const AlterTaleDemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ReadingSettingsProvider()),
        ChangeNotifierProvider(create: (context) => UserStatsProvider()),
      ],
      child: MaterialApp(
        title: 'AlterTale v1.1 Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const DemoHomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class DemoHomePage extends StatefulWidget {
  const DemoHomePage({Key? key}) : super(key: key);

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const FeaturesDemo(),
    const LoadingDemo(),
    const ErrorDemo(),
    const PerformanceDemo(),
  ];

  @override
  Widget build(BuildContext context) {
    return PerformanceMonitor(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('AlterTale v1.1 Demo'),
          actions: [
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: () => _showInfoDialog(),
            ),
          ],
        ),
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Features'),
            BottomNavigationBarItem(
              icon: Icon(Icons.hourglass_empty),
              label: 'Loading',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.error), label: 'Errors'),
            BottomNavigationBarItem(
              icon: Icon(Icons.speed),
              label: 'Performance',
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AlterTale v1.1 Features'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🌟 Major Features Implemented:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('⭐ Rating System'),
              Text('📤 Advanced Sharing'),
              Text('📊 Profile Statistics'),
              Text('🔄 Offline Sync'),
              Text('📖 Enhanced Reader'),
              Text('⚡ Performance Optimization'),
              Text('🎨 UX Improvements'),
              SizedBox(height: 16),
              Text('This demo showcases the new widgets and features!'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class FeaturesDemo extends StatelessWidget {
  const FeaturesDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '✨ New Features Demo',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Profile Stats Widget
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📊 Profile Statistics',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 16),
                  ProfileStatsWidget(showDetailed: false),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Reading Progress Bar
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📖 Reading Progress',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  ReadingProgressBar(
                    currentPage: 45,
                    totalPages: 200,
                    onPageTap: (page) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Jumped to page $page')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Connection Status
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🔄 Offline Sync Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 16),
                  ConnectionStatusWidget(showSyncButton: false),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Reading Settings Button
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚙️ Reading Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showReadingSettings(context),
                    icon: const Icon(Icons.settings),
                    label: const Text('Open Reading Settings'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReadingSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        child: const ReadingSettingsPanel(onClose: null),
      ),
    );
  }
}

class LoadingDemo extends StatefulWidget {
  const LoadingDemo({Key? key}) : super(key: key);

  @override
  State<LoadingDemo> createState() => _LoadingDemoState();
}

class _LoadingDemoState extends State<LoadingDemo> {
  LoadingType _currentType = LoadingType.books;
  bool _showProgress = false;
  double _progress = 0.3;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⏳ Smart Loading States',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Loading Type Selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Loading Type:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: LoadingType.values.map((type) {
                      return ChoiceChip(
                        label: Text(type.name),
                        selected: _currentType == type,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _currentType = type);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Progress Toggle
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('Show Progress:'),
                  const SizedBox(width: 16),
                  Switch(
                    value: _showProgress,
                    onChanged: (value) => setState(() => _showProgress = value),
                  ),
                  if (_showProgress) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: Slider(
                        value: _progress,
                        onChanged: (value) => setState(() => _progress = value),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Loading Widget Demo
          Center(
            child: SmartLoadingWidget(
              type: _currentType,
              message: 'Loading ${_currentType.name}...',
              subtitle: 'Please wait while we fetch your data',
              showProgress: _showProgress,
              progress: _progress,
            ),
          ),
        ],
      ),
    );
  }
}

class ErrorDemo extends StatefulWidget {
  const ErrorDemo({Key? key}) : super(key: key);

  @override
  State<ErrorDemo> createState() => _ErrorDemoState();
}

class _ErrorDemoState extends State<ErrorDemo> {
  ErrorType _currentType = ErrorType.network;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🚨 Smart Error Handling',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Error Type Selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Error Type:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ErrorType.values.map((type) {
                      return ChoiceChip(
                        label: Text(type.name),
                        selected: _currentType == type,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _currentType = type);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Error Widget Demo
          SmartErrorWidget(
            error: 'This is a demo ${_currentType.name} error',
            type: _currentType,
            onRetry: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Retry button pressed!')),
              );
            },
            onGoBack: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Go back button pressed!')),
              );
            },
            showDetails: true,
          ),
        ],
      ),
    );
  }
}

class PerformanceDemo extends StatelessWidget {
  const PerformanceDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📈 Performance Features',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '✨ Performance Monitor',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Real-time FPS and memory monitoring is active. '
                    'Toggle the eye icon in the top-right to see performance overlay.',
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      PerformanceMetrics.printReport();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Performance report printed to console',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.analytics),
                    label: const Text('Print Performance Report'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚡ Optimization Features',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  const ListTile(
                    leading: Icon(Icons.rocket_launch, color: Colors.green),
                    title: Text('Lazy Loading'),
                    subtitle: Text('Pagination with smart preloading'),
                  ),
                  const ListTile(
                    leading: Icon(Icons.memory, color: Colors.blue),
                    title: Text('Smart Caching'),
                    subtitle: Text('Multi-layer cache with auto-expiry'),
                  ),
                  const ListTile(
                    leading: Icon(Icons.speed, color: Colors.orange),
                    title: Text('Performance Monitoring'),
                    subtitle: Text('Real-time FPS and memory tracking'),
                  ),
                  const ListTile(
                    leading: Icon(Icons.animation, color: Colors.purple),
                    title: Text('Smooth Animations'),
                    subtitle: Text('60fps animations with smart easing'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
