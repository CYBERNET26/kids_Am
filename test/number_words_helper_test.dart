import 'package:flutter_test/flutter_test.dart';
import 'package:kids_am/features/games/visual_math/domain/number_words_helper.dart';

void main() {
  group('NumberWordsHelper tests', () {
    test('Conversión de unidades y números menores a 30', () {
      expect(NumberWordsHelper.toWords(0), 'cero');
      expect(NumberWordsHelper.toWords(1), 'uno');
      expect(NumberWordsHelper.toWords(8), 'ocho');
      expect(NumberWordsHelper.toWords(15), 'quince');
      expect(NumberWordsHelper.toWords(16), 'dieciséis');
      expect(NumberWordsHelper.toWords(20), 'veinte');
      expect(NumberWordsHelper.toWords(24), 'veinticuatro');
    });

    test('Conversión de decenas y centenas', () {
      expect(NumberWordsHelper.toWords(30), 'treinta');
      expect(NumberWordsHelper.toWords(35), 'treinta y cinco');
      expect(NumberWordsHelper.toWords(100), 'cien');
      expect(NumberWordsHelper.toWords(108), 'ciento ocho');
      expect(NumberWordsHelper.toWords(150), 'ciento cincuenta');
    });

    test('Validación tolerante a ortografía y tildes para niños de 6 años', () {
      // Coincidencia exacta
      expect(NumberWordsHelper.matches('quince', 15), isTrue);
      // Coincidencia con mayúsculas y espacios
      expect(NumberWordsHelper.matches('  QUINCE  ', 15), isTrue);
      // Coincidencia sin tildes (dieciseis vs dieciséis)
      expect(NumberWordsHelper.matches('dieciseis', 16), isTrue);
      expect(NumberWordsHelper.matches('dieciséis', 16), isTrue);
      expect(NumberWordsHelper.matches('veintitres', 23), isTrue);
      expect(NumberWordsHelper.matches('veintitrés', 23), isTrue);
      // Respuesta incorrecta
      expect(NumberWordsHelper.matches('catorce', 15), isFalse);
    });
  });
}
