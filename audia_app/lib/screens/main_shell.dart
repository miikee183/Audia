import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../l10n/app_strings.dart';
import '../providers/audio_provider.dart';
import '../widgets/playback_bar.dart';
import 'audio_list_screen.dart';
import 'inbox_screen.dart';
import 'record_screen.dart';
import 'friends_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final _profileKey = GlobalKey<ProfileScreenState>();

  late final List<Widget> _screens = [
    const AudioListScreen(),
    const InboxScreen(),
    const RecordScreen(),
    const FriendsScreen(),
    ProfileScreen(key: _profileKey),
  ];

  @override
  void initState() {
    super.initState();
    _loadTab();
    _saveOnboarded();
  }

  Future<void> _loadTab() async {
    final prefs = await SharedPreferences.getInstance();
    final tab = prefs.getInt('tabIndex') ?? 0;
    if (mounted) setState(() => _currentIndex = tab);
  }

  Future<void> _saveOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarded', true);
  }

  Future<void> _saveTab(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tabIndex', index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
          Consumer<AudioProvider>(
            builder: (context, provider, _) {
              if (provider.currentAudio != null) {
                return const PlaybackBar();
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;
          context.read<AudioProvider>().stop();
          setState(() {
            _currentIndex = index;
            _saveTab(index);
          });
          if (index == 4) _profileKey.currentState?.loadProfile();
        },
        backgroundColor: AppTheme.backgroundColor,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), activeIcon: const Icon(Icons.home), label: AppStrings.home),
          BottomNavigationBarItem(icon: const Icon(Icons.inbox_outlined), activeIcon: const Icon(Icons.inbox), label: AppStrings.inbox),
          const BottomNavigationBarItem(icon: Icon(Icons.mic, size: 32), label: ''),
          BottomNavigationBarItem(icon: const Icon(Icons.people_outline), activeIcon: const Icon(Icons.people), label: AppStrings.friends),
          BottomNavigationBarItem(icon: const Icon(Icons.person_outline), activeIcon: const Icon(Icons.person), label: AppStrings.profile),
        ],
      ),
    );
  }
}
