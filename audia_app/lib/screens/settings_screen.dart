import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../l10n/app_strings.dart';
import '../services/api_service.dart';
import '../services/perfil_service.dart';
import '../models/perfil_model.dart';
import '../widgets/profile_image.dart';
import '../app_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiService _api = ApiService();
  final PerfilService _perfilService = PerfilService();
  bool _cuentaPrivada = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final me = await _api.get('/auth/me');
      final account = me['account'] as Map<String, dynamic>;
      setState(() {
        _cuentaPrivada = account['cuenta_privada'] as bool? ?? false;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _togglePrivacidad(bool value) async {
    try {
      await _api.put('/perfil/me', {'cuenta_privada': value});
      setState(() => _cuentaPrivada = value);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.privacyUpdated)),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.error}: ${AppStrings.updateError}')),
      );
    }
  }

  void _showBlockedAccounts() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _BlockedAccountsSheet(perfilService: _perfilService),
    );
  }

  void _showGuidelines() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppStrings.normsTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Text(AppStrings.normsContent, style: const TextStyle(height: 1.6)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.done),
          ),
        ],
      ),
    );
  }

  void _showAnnouncements() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppStrings.announcements, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(AppStrings.noAnnouncements),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.done),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker() {
    final localeProvider = context.read<LocaleProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(AppStrings.chooseLanguage,
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 16)),
          ),
          const Divider(height: 1, color: Colors.white12),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: AppStrings.supportedLocales.length,
              itemBuilder: (_, i) {
                final code = AppStrings.supportedLocales[i];
                final name = AppStrings.localeName(code);
                final isSelected = code == localeProvider.localeCode;
                return ListTile(
                  title: Text(name,
                    style: TextStyle(
                      color: isSelected ? AppTheme.primaryColor : null,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () {
                    localeProvider.setLocale(code);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppStrings.logout, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(AppStrings.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
              GoRouter.of(context).go(AppRouter.splash);
            },
            child: Text(AppStrings.confirm, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(AppStrings.settings)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.settings, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _SectionHeader(title: AppStrings.privateAccount),
          Card(
            color: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: SwitchListTile(
              title: Text(AppStrings.privateAccount, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(AppStrings.privateAccountDesc, style: const TextStyle(fontSize: 12)),
              value: _cuentaPrivada,
              onChanged: _togglePrivacidad,
              activeTrackColor: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: AppStrings.blockedAccounts),
          Card(
            color: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              leading: const Icon(Icons.block, color: Colors.redAccent),
              title: Text(AppStrings.blockedAccounts, style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showBlockedAccounts,
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: AppStrings.communityGuidelines),
          Card(
            color: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              leading: const Icon(Icons.description_outlined, color: Colors.blueAccent),
              title: Text(AppStrings.communityGuidelines, style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showGuidelines,
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: AppStrings.announcements),
          Card(
            color: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              leading: const Icon(Icons.campaign_outlined, color: Colors.orangeAccent),
              title: Text(AppStrings.announcements, style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showAnnouncements,
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: AppStrings.appearance),
          Card(
            color: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(AppStrings.language, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(AppStrings.localeName(localeProvider.localeCode)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showLanguagePicker,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode),
                  title: Text(AppStrings.darkMode, style: const TextStyle(fontWeight: FontWeight.w600)),
                  value: themeProvider.isDarkMode,
                  onChanged: themeProvider.setDarkMode,
                  activeTrackColor: AppTheme.primaryColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: Text(AppStrings.logout, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.redAccent)),
              onTap: _confirmLogout,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(AppStrings.audiaVersion,
              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(100), fontSize: 12)),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _BlockedAccountsSheet extends StatefulWidget {
  final PerfilService perfilService;
  const _BlockedAccountsSheet({required this.perfilService});

  @override
  State<_BlockedAccountsSheet> createState() => _BlockedAccountsSheetState();
}

class _BlockedAccountsSheetState extends State<_BlockedAccountsSheet> {
  final ApiService _api = ApiService();
  List<PerfilBasico> _blocked = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _api.get('/perfil/bloqueados');
      final list = data as List<dynamic>;
      setState(() {
        _blocked = list.map((j) => PerfilBasico.fromJson(j as Map<String, dynamic>)).toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _unblock(String perfilId) async {
    try {
      await _api.post('/perfil/block/$perfilId', {});
      setState(() => _blocked.removeWhere((p) => p.perfilId == perfilId));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(AppStrings.blockedAccounts,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 18, fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: CircularProgressIndicator(),
            )
          else if (_blocked.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(AppStrings.noBlocked,
                style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _blocked.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final p = _blocked[i];
                  return ListTile(
                    leading: ProfileImage(imageData: p.fotoPerfil, radius: 20),
                    title: Text(p.nombreUsuario),
                    trailing: TextButton(
                      onPressed: () => _unblock(p.perfilId),
                      child: Text(AppStrings.unblock),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
