import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/profile/profile_screen.dart';
import 'models/profile_model.dart';

void main() {
  runApp(const ProfileDemoApp());
}

class ProfileDemoApp extends StatelessWidget {
  const ProfileDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MockProfileProvider())],
      child: MaterialApp(
        title: 'Altertale Profile Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const ProfileDemoHome(),
      ),
    );
  }
}

class ProfileDemoHome extends StatefulWidget {
  const ProfileDemoHome({super.key});

  @override
  State<ProfileDemoHome> createState() => _ProfileDemoHomeState();
}

class _ProfileDemoHomeState extends State<ProfileDemoHome> {
  @override
  void initState() {
    super.initState();
    _loadMockProfile();
  }

  void _loadMockProfile() {
    final profileProvider = context.read<MockProfileProvider>();
    profileProvider.initializeMockData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Altertale Profile Demo'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Altertale Profil Demo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Profil sistemi test için hazır',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
            _ProfileDemoButton(),
          ],
        ),
      ),
    );
  }
}

class _ProfileDemoButton extends StatelessWidget {
  const _ProfileDemoButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
      },
      icon: const Icon(Icons.account_circle),
      label: const Text('Profil Ekranını Aç'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16),
      ),
    );
  }
}

// Mock Profile Provider - Firebase'e bağımlı olmayan
class MockProfileProvider extends ChangeNotifier {
  ProfileModel? _profile;
  Map<String, dynamic>? _stats;
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _errorMessage;

  // Getters
  ProfileModel? get profile => _profile;
  Map<String, dynamic>? get stats => _stats;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  bool get hasProfile => _profile != null;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;

  void initializeMockData() {
    _isLoading = true;
    notifyListeners();

    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _profile = ProfileModel(
        uid: 'demo_user',
        name: 'Demo Kullanıcı',
        email: 'demo@altertale.com',
        username: 'demoland',
        displayName: 'Demo User',
        bio:
            'Bu bir demo profili. Altertale uygulamasını test etmek için oluşturulmuştur.',
        profileImageUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastUpdated: DateTime.now(),
        joinDate: DateTime.now().subtract(const Duration(days: 30)),
        lastActiveDate: DateTime.now(),
        isPremium: true,
        isActive: true,
        isDeleted: false,
        preferences: {
          'language': 'tr',
          'soundEffects': true,
          'hapticFeedback': true,
          'autoSave': true,
        },
        notificationSettings: {
          'newBookNotifications': true,
          'campaignNotifications': true,
          'dailySummaryNotifications': false,
          'referralNotifications': true,
        },
        readingSettings: {
          'theme': 'system',
          'fontFamily': 'sans',
          'fontSize': 'medium',
          'lineHeight': 'normal',
          'backgroundColor': 'default',
        },
      );

      _stats = {
        'totalBooksRead': 12,
        'totalReadingTime': 720, // 12 saat
        'totalPointsEarned': 850,
        'totalBooksPurchased': 15,
        'totalBooksFavorited': 8,
        'totalPointsSpent': 650,
      };

      _isLoading = false;
      notifyListeners();
    });
  }

  // Mock update methods
  Future<bool> updateTheme(String theme) async {
    if (_profile == null) return false;

    _isUpdating = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    _profile = _profile!.updateTheme(theme);
    _isUpdating = false;
    notifyListeners();
    return true;
  }

  Future<bool> updateNotificationSetting(String key, bool value) async {
    if (_profile == null) return false;

    _isUpdating = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    _profile = _profile!.updateNotificationSetting(key, value);
    _isUpdating = false;
    notifyListeners();
    return true;
  }

  Future<bool> updatePreference(String key, dynamic value) async {
    if (_profile == null) return false;

    _isUpdating = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    _profile = _profile!.updatePreference(key, value);
    _isUpdating = false;
    notifyListeners();
    return true;
  }

  // Convenience getters
  String get currentTheme => _profile?.theme ?? 'system';
  String get currentLanguage => _profile?.language ?? 'tr';
  double get profileCompletionPercentage =>
      _profile?.profileCompletionPercentage ?? 0.0;
  int get membershipDays => _profile?.membershipDays ?? 0;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
