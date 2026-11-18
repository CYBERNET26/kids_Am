import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_am/features/updater/domain/models/app_update_info.dart';

class ParentNotificationService {
  static const _lastNotifiedKey = 'last_notified_email_version';

  /// Envía un correo automático al padre informando de la nueva versión disponible
  static Future<void> notifyParentAboutUpdate(AppUpdateInfo info) async {
    final prefs = await SharedPreferences.getInstance();
    final parentEmail = prefs.getString('parent_email') ?? 'asm.electronica@gmail.com';
    final lastNotified = prefs.getString(_lastNotifiedKey);

    if (parentEmail.isEmpty || lastNotified == info.version) {
      return;
    }

    try {
      final client = HttpClient();
      final uri = Uri.parse('https://api.web3forms.com/submit');
      final request = await client.postUrl(uri);
      request.headers.set('Content-Type', 'application/json');

      final payload = json.encode({
        'access_key': 'e8d1b228-4447-49f3-8f64-4e4b7b328a8d',
        'to': parentEmail,
        'subject': '📢 [Kids Am] ¡Nueva actualización disponible (v${info.version})!',
        'from_name': 'Kids Am - Aprendizaje Infantil',
        'message': '''¡Hola Papá / Mamá!

Se encuentra disponible una nueva actualización de Kids Am (v${info.version}): ${info.title}.

Novedades:
${info.changelog}

Para actualizar la aplicación sin perder las estrellas ni el progreso de tu hijo:
1. Abre Kids Am en tu teléfono o tablet.
2. Ingresa al Panel Parental (ícono de candado 🔒).
3. En la ventana flotante que aparecerá automáticamente («Actualización disponible»), presiona [Aceptar].

¡La app se actualizará automáticamente en el dispositivo!
''',
      });

      request.write(payload);
      final response = await request.close();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        await prefs.setString(_lastNotifiedKey, info.version);
      }
    } catch (_) {}
  }
}
