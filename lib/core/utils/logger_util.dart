import 'package:logger/logger.dart';

/// Crée et configure une instance de Logger
Logger getLoggerInstance() {
  return Logger(
    // Filter logs selon le niveau
    filter: ProductionFilter(),
    
    // Format des logs
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    
    // Sortie par défaut
    output: ConsoleOutput(),
  );
}

/// Filtre qui n'affiche que les logs de niveau info et supérieur en production
class ProductionFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // En mode debug, afficher tous les logs
    assert(() {
      return true;
    }());
    
    // En mode production, filtrer les logs de niveau trop bas
    return event.level.index >= Level.info.index;
  }
}
