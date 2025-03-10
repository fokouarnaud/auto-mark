import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:correction_auto/core/theme/app_colors.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'Semaine';
  String _selectedSubject = 'Toutes';
  
  // Données fictives pour démonstration
  final Map<String, List<double>> _mockScores = {
    'Mathématiques': [75, 68, 82, 79, 85, 76, 73],
    'Français': [82, 79, 85, 88, 90, 85, 84],
    'Sciences': [65, 72, 70, 75, 78, 80, 77],
    'Histoire': [70, 75, 68, 72, 76, 73, 71],
  };
  
  final List<String> _mockStudents = [
    'Emma Dupont',
    'Lucas Martin',
    'Chloé Bernard',
    'Nathan Thomas',
    'Léa Robert',
    'Hugo Petit',
    'Manon Richard',
    'Louis Durand',
    'Camille Simon',
    'Jules Michel',
  ];
  
  final Map<String, Map<String, int>> _mockQuestionStats = {
    'Mathématiques': {'Q1': 85, 'Q2': 65, 'Q3': 78, 'Q4': 92, 'Q5': 72},
    'Français': {'Q1': 90, 'Q2': 85, 'Q3': 82, 'Q4': 88, 'Q5': 86},
    'Sciences': {'Q1': 75, 'Q2': 68, 'Q3': 72, 'Q4': 80, 'Q5': 76},
    'Histoire': {'Q1': 78, 'Q2': 72, 'Q3': 70, 'Q4': 75, 'Q5': 73},
  };
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Aperçu'),
            Tab(text: 'Élèves'),
            Tab(text: 'Questions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildStudentsTab(),
          _buildQuestionsTab(),
        ],
      ),
    );
  }
  
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filtres
          _buildFilters(),
          
          const SizedBox(height: 24),
          
          // Graphique d'évolution
          Text(
            'Évolution des résultats',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 250,
            child: _buildLineChart(),
          ),
          
          const SizedBox(height: 24),
          
          // Répartition des notes
          Text(
            'Répartition des notes',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 250,
            child: _buildBarChart(),
          ),
          
          const SizedBox(height: 24),
          
          // Statistiques générales
          Text(
            'Statistiques générales',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          _buildGeneralStatsCards(),
        ],
      ),
    );
  }
  
  Widget _buildStudentsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Filtres
        _buildFilters(),
        
        const SizedBox(height: 24),
        
        // Liste des élèves
        const Text(
          'Performance des élèves',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ..._mockStudents.map((student) {
          // Générer un score aléatoire pour chaque élève
          final score = 50 + (student.hashCode % 50);
          return _buildStudentScoreCard(student, score);
        }).toList(),
      ],
    );
  }
  
  Widget _buildQuestionsTab() {
    // Utiliser les données de la matière sélectionnée ou les premières disponibles
    final Map<String, int> questionData = _selectedSubject == 'Toutes'
        ? _mockQuestionStats['Mathématiques']!
        : _mockQuestionStats[_selectedSubject] ?? _mockQuestionStats.values.first;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Filtres
        _buildFilters(),
        
        const SizedBox(height: 24),
        
        // Graphique des questions
        const Text(
          'Taux de réussite par question',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 250,
          child: _buildQuestionBarChart(questionData),
        ),
        
        const SizedBox(height: 24),
        
        // Liste des questions
        const Text(
          'Détail par question',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ...questionData.entries.map((entry) {
          return _buildQuestionCard(entry.key, entry.value);
        }).toList(),
      ],
    );
  }
  
  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtres',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Période',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    value: _selectedPeriod,
                    items: ['Semaine', 'Mois', 'Trimestre', 'Année'].map((period) {
                      return DropdownMenuItem<String>(
                        value: period,
                        child: Text(period),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedPeriod = value;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Matière',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    value: _selectedSubject,
                    items: ['Toutes', ..._mockScores.keys].map((subject) {
                      return DropdownMenuItem<String>(
                        value: subject,
                        child: Text(subject),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedSubject = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLineChart() {
    // Calculer les données moyennes ou par matière
    final List<double> displayData;
    if (_selectedSubject == 'Toutes') {
      // Calculer la moyenne de toutes les matières
      displayData = List.generate(7, (index) {
        double sum = 0;
        int count = 0;
        for (final scores in _mockScores.values) {
          if (index < scores.length) {
            sum += scores[index];
            count++;
          }
        }
        return count > 0 ? sum / count : 0;
      });
    } else {
      // Utiliser les données de la matière sélectionnée
      displayData = _mockScores[_selectedSubject] ?? [];
    }
    
    return displayData.isEmpty
        ? const Center(child: Text('Aucune donnée disponible'))
        : LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text('J${value.toInt() + 1}'),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(value.toString()),
                      );
                    },
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey, width: 1),
              ),
              minX: 0,
              maxX: displayData.length - 1.0,
              minY: 0,
              maxY: 100,
              lineBarsData: [
                LineChartBarData(
                  spots: displayData.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value);
                  }).toList(),
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.primary.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          );
  }
  
  Widget _buildBarChart() {
    // Créer des tranches de notes (0-20, 20-40, etc.)
    final Map<String, int> gradeRanges = {
      '0-20': 0,
      '20-40': 0,
      '40-60': 0,
      '60-80': 0,
      '80-100': 0,
    };
    
    // Compter les notes dans chaque tranche
    _mockScores.forEach((subject, scores) {
      if (_selectedSubject == 'Toutes' || _selectedSubject == subject) {
        for (final score in scores) {
          if (score < 20) {
            gradeRanges['0-20'] = gradeRanges['0-20']! + 1;
          } else if (score < 40) {
            gradeRanges['20-40'] = gradeRanges['20-40']! + 1;
          } else if (score < 60) {
            gradeRanges['40-60'] = gradeRanges['40-60']! + 1;
          } else if (score < 80) {
            gradeRanges['60-80'] = gradeRanges['60-80']! + 1;
          } else {
            gradeRanges['80-100'] = gradeRanges['80-100']! + 1;
          }
        }
      }
    });
    
    // Créer les données pour le graphique
    final List<BarChartGroupData> barGroups = gradeRanges.entries.toList().asMap().entries.map((entry) {
      final int index = entry.key;
      final String range = entry.value.key;
      final int count = entry.value.value;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            color: AppColors.primary,
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      );
    }).toList();
    
    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.black87,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final String range = gradeRanges.keys.elementAt(group.x.toInt());
              return BarTooltipItem(
                '${range}: ${rod.toY.toInt()} élèves',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4,
                  child: Text(
                    gradeRanges.keys.elementAt(value.toInt()),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox();
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 0,
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        barGroups: barGroups,
      ),
    );
  }
  
  Widget _buildQuestionBarChart(Map<String, int> questionData) {
    final List<BarChartGroupData> barGroups = questionData.entries.toList().asMap().entries.map((entry) {
      final int index = entry.key;
      final String question = entry.value.key;
      final int percentage = entry.value.value;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: percentage.toDouble(),
            color: AppColors.primary,
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      );
    }).toList();
    
    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.black87,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final String question = questionData.keys.elementAt(group.x.toInt());
              return BarTooltipItem(
                '${question}: ${rod.toY.toInt()}%',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4,
                  child: Text(
                    questionData.keys.elementAt(value.toInt()),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value % 20 != 0) return const SizedBox();
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 0,
                  child: Text(
                    '${value.toInt()}%',
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        barGroups: barGroups,
        maxY: 100,
      ),
    );
  }
  
  Widget _buildGeneralStatsCards() {
    // Calculer les statistiques générales
    double averageScore = 0;
    int totalScores = 0;
    double maxScore = 0;
    double minScore = 100;
    
    _mockScores.forEach((subject, scores) {
      if (_selectedSubject == 'Toutes' || _selectedSubject == subject) {
        for (final score in scores) {
          averageScore += score;
          totalScores++;
          maxScore = score > maxScore ? score : maxScore;
          minScore = score < minScore ? score : minScore;
        }
      }
    });
    
    averageScore = totalScores > 0 ? averageScore / totalScores : 0;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Moyenne',
            '${averageScore.toStringAsFixed(1)}%',
            Icons.trending_up,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Maximum',
            '${maxScore.toStringAsFixed(1)}%',
            Icons.arrow_upward,
            Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Minimum',
            '${minScore.toStringAsFixed(1)}%',
            Icons.arrow_downward,
            Colors.red,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStudentScoreCard(String name, int score) {
    Color scoreColor;
    if (score >= 80) {
      scoreColor = Colors.green;
    } else if (score >= 60) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            name.substring(0, 1),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(name),
        subtitle: LinearProgressIndicator(
          value: score / 100,
          backgroundColor: Colors.grey.withOpacity(0.2),
          color: scoreColor,
        ),
        trailing: Text(
          '$score%',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: scoreColor,
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuestionCard(String question, int percentage) {
    Color scoreColor;
    if (percentage >= 80) {
      scoreColor = Colors.green;
    } else if (percentage >= 60) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  question,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: scoreColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$percentage%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey.withOpacity(0.2),
              color: scoreColor,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              _getPerformanceText(percentage),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getPerformanceText(int percentage) {
    if (percentage >= 80) {
      return 'Question bien maîtrisée par les élèves';
    } else if (percentage >= 60) {
      return 'Question moyennement maîtrisée';
    } else {
      return 'Question difficile pour la plupart des élèves';
    }
  }
}
