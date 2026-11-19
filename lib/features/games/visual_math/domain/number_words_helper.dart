class NumberWordsHelper {
  static const List<String> _units = [
    'cero',
    'uno',
    'dos',
    'tres',
    'cuatro',
    'cinco',
    'seis',
    'siete',
    'ocho',
    'nueve',
    'diez',
    'once',
    'doce',
    'trece',
    'catorce',
    'quince',
    'dieciséis',
    'diecisiete',
    'dieciocho',
    'diecinueve',
    'veinte',
    'veintiuno',
    'veintidós',
    'veintitrés',
    'veinticuatro',
    'veinticinco',
    'veintiséis',
    'veintisiete',
    'veintiocho',
    'veintinueve',
  ];

  static const List<String> _tens = [
    '',
    'diez',
    'veinte',
    'treinta',
    'cuarenta',
    'cincuenta',
    'sesenta',
    'setenta',
    'ochenta',
    'noventa',
  ];

  static const List<String> _hundreds = [
    '',
    'ciento',
    'doscientos',
    'trescientos',
    'cuatrocientos',
    'quinientos',
    'seiscientos',
    'setecientos',
    'ochocientos',
    'novecientos',
  ];

  /// Convierte un número entero (0 a 999) a su representación en palabras en español.
  static String toWords(int number) {
    if (number < 0) return 'menos ${toWords(number.abs())}';
    if (number < _units.length) return _units[number];
    if (number < 100) {
      final t = number ~/ 10;
      final u = number % 10;
      if (u == 0) return _tens[t];
      return '${_tens[t]} y ${_units[u]}';
    }
    if (number == 100) return 'cien';
    if (number < 1000) {
      final h = number ~/ 100;
      final rem = number % 100;
      if (rem == 0) {
        return h == 1 ? 'cien' : _hundreds[h];
      }
      return '${_hundreds[h]} ${toWords(rem)}';
    }
    return '$number';
  }

  /// Normaliza una cadena para comparar respuestas de niños sin frustración ortográfica
  /// (remueve tildes, diéresis, espacios duplicados y pasa a minúsculas).
  static String normalize(String text) {
    var s = text.trim().toLowerCase();
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    s = s.replaceAll('á', 'a');
    s = s.replaceAll('é', 'e');
    s = s.replaceAll('í', 'i');
    s = s.replaceAll('ó', 'o');
    s = s.replaceAll('ú', 'u');
    s = s.replaceAll('ü', 'u');
    return s;
  }

  /// Comprueba si la respuesta del niño coincide con el nombre del número
  static bool matches(String input, int number) {
    final cleanInput = normalize(input);
    final correctWord = normalize(toWords(number));

    if (cleanInput == correctWord) return true;

    // Permitir variantes comunes (ej. "veintiun" por "veintiuno", "uno" por "un")
    if (cleanInput == correctWord.replaceAll('uno', 'un') ||
        cleanInput == correctWord.replaceAll('un', 'uno')) {
      return true;
    }

    return false;
  }
}
