import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:correction_auto/core/theme/app_colors.dart';
import 'package:correction_auto/presentation/bloc/theme/theme_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsSection(
            title: 'Apparence',
            children: [
              // Theme selector
              _SettingsTile(
                icon: Icons.dark_mode,
                title: 'Thème',
                subtitle: 'Changer l\'apparence de l\'application',
                trailing: BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, state) {
                    return DropdownButton<ThemeMode>(
                      value: state.themeMode,
                      underline: const SizedBox.shrink(),
                      items: [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text('Système', style: Theme.of(context).textTheme.bodyMedium),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text('Clair', style: Theme.of(context).textTheme.bodyMedium),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text('Sombre', style: Theme.of(context).textTheme.bodyMedium),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          context.read<ThemeBloc>().add(SetThemeMode(value));
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          _SettingsSection(
            title: 'Correction',
            children: [
              // OCR language
              _SettingsTile(
                icon: Icons.translate,
                title: 'Langue OCR',
                subtitle: 'Langue principale pour la reconnaissance de texte',
                trailing: DropdownButton<String>(
                  value: 'fr',
                  underline: const SizedBox.shrink(),
                  items: [
                    DropdownMenuItem(
                      value: 'fr',
                      child: Text('Français', style: Theme.of(context).textTheme.bodyMedium),
                    ),
                    DropdownMenuItem(
                      value: 'en',
                      child: Text('Anglais', style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  ],
                  onChanged: (value) {
                    // Update OCR language preference
                  },
                ),
              ),
              
              // Comparison threshold
              _SettingsTile(
                icon: Icons.tune,
                title: 'Seuil de similarité',
                subtitle: 'Seuil minimum pour considérer une réponse comme correcte',
                trailing: DropdownButton<int>(
                  value: 75,
                  underline: const SizedBox.shrink(),
                  items: [
                    for (int i = 50; i <= 90; i += 5)
                      DropdownMenuItem(
                        value: i,
                        child: Text('$i%', style: Theme.of(context).textTheme.bodyMedium),
                      ),
                  ],
                  onChanged: (value) {
                    // Update threshold preference
                  },
                ),
              ),
            ],
          ),
          _SettingsSection(
            title: 'Exportation',
            children: [
              // Export format
              _SettingsTile(
                icon: Icons.file_present,
                title: 'Format d\'export',
                subtitle: 'Format par défaut pour l\'exportation des résultats',
                trailing: DropdownButton<String>(
                  value: 'pdf',
                  underline: const SizedBox.shrink(),
                  items: [
                    DropdownMenuItem(
                      value: 'pdf',
                      child: Text('PDF', style: Theme.of(context).textTheme.bodyMedium),
                    ),
                    DropdownMenuItem(
                      value: 'csv',
                      child: Text('CSV', style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  ],
                  onChanged: (value) {
                    // Update export format preference
                  },
                ),
              ),
            ],
          ),
          _SettingsSection(
            title: 'Application',
            children: [
              // Version info
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'Version',
                subtitle: '1.0.0',
              ),
              
              // Privacy policy
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Politique de confidentialité',
                onTap: () {
                  // Show privacy policy
                },
              ),
              
              // About
              _SettingsTile(
                icon: Icons.help_outline,
                title: 'À propos',
                onTap: () {
                  // Show about dialog
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: onTap != null
          ? const BorderRadius.all(Radius.circular(16))
          : BorderRadius.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
