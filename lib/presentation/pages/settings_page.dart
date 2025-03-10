import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:correction_auto/core/theme/app_colors.dart';
import 'package:correction_auto/presentation/bloc/theme/theme_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Correction Auto',
    packageName: 'com.example.correction_auto',
    version: '1.0.0',
    buildNumber: '1',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() {
        _packageInfo = info;
      });
    } catch (e) {
      // En cas d'erreur, on conserve les valeurs par défaut
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        children: [
          _buildThemeSection(),
          _buildDataSection(),
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildThemeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            'Apparence',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            return ListTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text('Thème'),
              subtitle: Text(
                state.themeMode == ThemeMode.dark
                    ? 'Sombre'
                    : state.themeMode == ThemeMode.light
                        ? 'Clair'
                        : 'Système',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showThemeDialog(context),
            );
          },
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildDataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            'Données',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.backup),
          title: const Text('Sauvegarde et restauration'),
          subtitle: const Text('Sauvegarder ou restaurer vos données'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Implémenter la sauvegarde et restauration
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Fonctionnalité en cours de développement'),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_outline),
          title: const Text('Supprimer toutes les données'),
          subtitle: const Text('Effacer définitivement vos données'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showDeleteConfirmationDialog(),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            'À propos',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Informations'),
          subtitle: Text('Version ${_packageInfo.version} (${_packageInfo.buildNumber})'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.code),
          title: const Text('Licences'),
          subtitle: const Text('Licences des bibliothèques utilisées'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            showLicensePage(
              context: context,
              applicationName: 'Correction Auto',
              applicationVersion: '${_packageInfo.version} (${_packageInfo.buildNumber})',
              applicationIcon: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 48,
                  height: 48,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.school,
                      size: 48,
                      color: Colors.blue,
                    );
                  },
                ),
              ),
            );
          },
        ),
        const Divider(),
      ],
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choisir un thème'),
          content: BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildThemeOption(
                    context,
                    'Clair',
                    Icons.light_mode,
                    state.themeMode == ThemeMode.light,
                    () {
                      context.read<ThemeBloc>().add(const SetThemeMode(ThemeMode.light));
                      Navigator.pop(context);
                    },
                  ),
                  _buildThemeOption(
                    context,
                    'Sombre',
                    Icons.dark_mode,
                    state.themeMode == ThemeMode.dark,
                    () {
                      context.read<ThemeBloc>().add(const SetThemeMode(ThemeMode.dark));
                      Navigator.pop(context);
                    },
                  ),
                  _buildThemeOption(
                    context,
                    'Système',
                    Icons.brightness_auto,
                    state.themeMode == ThemeMode.system,
                    () {
                      context.read<ThemeBloc>().add(const SetThemeMode(ThemeMode.system));
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    IconData icon,
    bool selected,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: selected ? Icon(Icons.check, color: Colors.blue) : null,
      onTap: onTap,
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer toutes les données ?'),
          content: const Text(
            'Cette action supprimera définitivement toutes vos données. Cette action est irréversible.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implémenter la suppression des données
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Données supprimées')),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}
