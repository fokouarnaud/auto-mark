# Correction Auto

Application mobile pour la correction automatisée de copies d'élèves.

## Description

Correction Auto est une application mobile qui permet aux enseignants de corriger rapidement des copies d'élèves en utilisant l'appareil photo du smartphone et des algorithmes d'analyse textuelle. L'application fonctionne entièrement hors ligne en utilisant uniquement des technologies open source.

## Fonctionnalités

- Capture et traitement d'image (détection de contours, redressement automatique)
- Reconnaissance de texte (OCR) hors ligne
- Analyse textuelle avec approche hybride (TF-IDF, Similarité de Jaccard, Distance de Levenshtein)
- Création et gestion de références de correction
- Correction automatisée des copies
- Statistiques et analyses des résultats

## Spécifications techniques

- **Framework**: Flutter
- **Langage**: Dart
- **Architecture**: Clean Architecture / MVVM
- **Gestion d'état**: Bloc pattern
- **OCR**: Google ML Kit Text Recognition (hors ligne)
- **Analyse textuelle**: Algorithmes légers + TensorFlow Lite

## Installation

1. Cloner le dépôt
```bash
git clone https://github.com/username/correction_auto.git
```

2. Naviguer dans le répertoire du projet
```bash
cd correction_auto
```

3. Installer les dépendances
```bash
flutter pub get
```

4. Lancer l'application
```bash
flutter run
```

## Structure du projet

```
lib/
├── core/                  # Éléments de base partagés
│   ├── di/                # Injection de dépendances
│   ├── theme/             # Thème de l'application
│   └── utils/             # Utilitaires
├── data/                  # Couche de données
│   ├── datasources/       # Sources de données
│   ├── models/            # Modèles de données
│   └── repositories/      # Implémentations des repositories
├── domain/                # Couche domaine
│   ├── entities/          # Entités du domaine
│   ├── repositories/      # Interfaces des repositories
│   └── usecases/          # Cas d'utilisation
├── features/              # Fonctionnalités principales
│   ├── camera/            # Module de capture d'image
│   ├── correction/        # Module de correction
│   ├── ocr/               # Module de reconnaissance de texte
│   ├── reference_management/ # Gestion des références
│   ├── statistics/        # Statistiques et analyses
│   └── text_analysis/     # Analyse textuelle
├── presentation/          # Couche présentation
│   ├── bloc/              # Blocs pour la gestion d'état
│   ├── pages/             # Pages de l'application
│   └── widgets/           # Widgets réutilisables
└── main.dart              # Point d'entrée de l'application
```

## Contribution

1. Forker le projet
2. Créer une branche de fonctionnalité (`git checkout -b feature/amazing-feature`)
3. Commiter vos changements (`git commit -m 'Add some amazing feature'`)
4. Pousser la branche (`git push origin feature/amazing-feature`)
5. Ouvrir une Pull Request

## Licence

Ce projet est sous licence MIT - voir le fichier LICENSE pour plus de détails.
