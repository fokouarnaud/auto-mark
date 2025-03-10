import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:correction_auto/core/theme/app_colors.dart';
import 'package:correction_auto/presentation/bloc/theme/theme_bloc.dart';
import 'package:correction_auto/features/reference_management/presentation/create_reference_page.dart';
import 'package:correction_auto/presentation/pages/correction_page.dart';
import 'package:correction_auto/presentation/pages/statistics_page.dart';
import 'package:correction_auto/presentation/pages/settings_page.dart';
import 'package:correction_auto/presentation/widgets/empty_state_widget.dart';
import 'package:correction_auto/presentation/widgets/reference_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const _HomeTab(),
    const _ReferencesTab(),
    const _CorrectionsTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Accueil',
            ),
            NavigationDestination(
              icon: Icon(Icons.description_outlined),
              selectedIcon: Icon(Icons.description),
              label: 'Références',
            ),
            NavigationDestination(
              icon: Icon(Icons.grading_outlined),
              selectedIcon: Icon(Icons.grading),
              label: 'Corrections',
            ),
          ],
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
        ),
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CreateReferencePage(),
                  ),
                );
              },
              label: const Text('Nouvelle référence'),
              icon: const Icon(Icons.add),
            )
          : _selectedIndex == 2
              ? FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CorrectionPageWrapper(),
                      ),
                    );
                  },
                  label: const Text('Nouvelle correction'),
                  icon: const Icon(Icons.add),
                )
              : null,
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 180,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.secondary,
                    ],
                  ),
                ),
              ),
              titlePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Correction Auto',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      // Stats button
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const StatisticsPageWrapper(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.insights, color: Colors.white),
                      ),
                      // Theme toggle
                      IconButton(
                        onPressed: () {
                          context.read<ThemeBloc>().add(ToggleTheme());
                        },
                        icon: BlocBuilder<ThemeBloc, ThemeState>(
                          builder: (context, state) {
                            return Icon(
                              state.themeMode == ThemeMode.dark
                                  ? Icons.light_mode
                                  : Icons.dark_mode,
                              color: Colors.white,
                            );
                          },
                        ),
                      ),
                      // Settings
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SettingsPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.settings, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick actions
                  Text(
                    'Actions rapides',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ActionCard(
                        icon: Icons.description,
                        label: 'Nouvelle référence',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CreateReferencePage(),
                            ),
                          );
                        },
                      ),
                      _ActionCard(
                        icon: Icons.camera_alt,
                        label: 'Scanner copie',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CorrectionPageWrapper(),
                            ),
                          );
                        },
                      ),
                      _ActionCard(
                        icon: Icons.analytics,
                        label: 'Statistiques',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const StatisticsPageWrapper(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Corrections récentes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  // This would be a FutureBuilder or BlocBuilder in the real app
                  const EmptyStateWidget(
                    icon: Icons.grading_outlined,
                    title: 'Aucune correction récente',
                    message: 'Commencez à scanner des copies pour voir les corrections récentes ici.',
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

class _ReferencesTab extends StatelessWidget {
  const _ReferencesTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Références'),
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              // This would be a FutureBuilder or BlocBuilder in the real app
              child: Column(
                children: [
                  // Example reference cards
                  ReferenceCard(
                    title: 'Évaluation Science - Chapitre 3',
                    subject: 'Science',
                    questionsCount: 12,
                    lastUpdate: DateTime.now().subtract(const Duration(days: 2)),
                    onTap: () {
                      // Open reference details
                    },
                  ),
                  const SizedBox(height: 12),
                  ReferenceCard(
                    title: 'Contrôle Math - Algèbre',
                    subject: 'Mathématiques',
                    questionsCount: 8,
                    lastUpdate: DateTime.now().subtract(const Duration(days: 5)),
                    onTap: () {
                      // Open reference details
                    },
                  ),
                  const SizedBox(height: 12),
                  const EmptyStateWidget(
                    icon: Icons.description_outlined,
                    title: 'Créez des références',
                    message: 'Les références sont des modèles pour vos corrections automatiques.',
                    showButton: true,
                    buttonText: 'Créer une référence',
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

class _CorrectionsTab extends StatelessWidget {
  const _CorrectionsTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Corrections'),
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // This would be a FutureBuilder or BlocBuilder in the real app
                  const EmptyStateWidget(
                    icon: Icons.grading_outlined,
                    title: 'Aucune correction',
                    message: 'Commencez par créer une référence puis corrigez des copies.',
                    showButton: true,
                    buttonText: 'Scanner une copie',
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

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: AppColors.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
