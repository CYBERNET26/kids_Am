import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kids_am/main.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Carga inicial de KidsAmApp y muestra la bienvenida al explorador', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: KidsAmApp(),
      ),
    );
    await tester.pump();

    expect(find.textContaining('¡Hola,'), findsOneWidget);
    expect(find.text('Elige tu Aventura 🚀'), findsOneWidget);

    // Drenar el timer de comprobación de actualizaciones de fondo
    await tester.pump(const Duration(seconds: 4));
  });
}
