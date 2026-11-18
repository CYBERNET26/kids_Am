import '../models/tutor_context.dart';

abstract class ITutorService {
  /// Genera una explicación o felicitación pedagógica para el niño
  Future<TutorFeedback> generateFeedback(TutorContext context);

  /// Verifica si el servicio está operativo y disponible
  Future<bool> isAvailable();
}
