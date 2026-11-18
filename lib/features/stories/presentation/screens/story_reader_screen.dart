import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:kids_am/core/constants/app_colors.dart';
import 'package:kids_am/core/services/teacher_voice_service.dart';
import 'package:kids_am/core/widgets/playful_background.dart';
import 'package:kids_am/features/profile/presentation/providers/profile_provider.dart';
import 'package:kids_am/features/stories/domain/models/story_item.dart';
import 'package:kids_am/features/stories/presentation/providers/stories_provider.dart';

class StoryReaderScreen extends ConsumerStatefulWidget {
  final StoryItem story;

  const StoryReaderScreen({super.key, required this.story});

  @override
  ConsumerState<StoryReaderScreen> createState() => _StoryReaderScreenState();
}

class _StoryReaderScreenState extends ConsumerState<StoryReaderScreen> {
  bool _isQuizMode = false;
  bool _isReadingAloud = false;

  // Quiz state
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _hasAnswered = false;
  int _correctAnswersCount = 0;
  int _totalEarnedStars = 0;
  bool _quizFinished = false;

  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
  }

  @override
  void dispose() {
    TeacherVoiceService.instance.stop();
    _confettiController.dispose();
    super.dispose();
  }

  void _toggleReadAloud() {
    if (_isReadingAloud) {
      TeacherVoiceService.instance.stop();
      setState(() => _isReadingAloud = false);
    } else {
      setState(() => _isReadingAloud = true);
      final fullText = '${widget.story.title}. ${widget.story.paragraphs.join(' ')}. Moraleja: ${widget.story.moral}';
      TeacherVoiceService.instance.speak(fullText);
    }
  }

  void _startQuiz() {
    TeacherVoiceService.instance.stop();
    setState(() {
      _isQuizMode = true;
      _currentQuestionIndex = 0;
      _selectedOptionIndex = null;
      _hasAnswered = false;
      _correctAnswersCount = 0;
      _totalEarnedStars = 0;
      _quizFinished = false;
    });

    final profile = ref.read(childProfileProvider);
    TeacherVoiceService.instance.speak(
      '¡Muy bien ${profile.name}! Ahora vamos a responder las preguntas del cuento para ganar estrellas.',
    );
  }

  void _handleOptionSelect(int index) {
    if (_hasAnswered) return;

    final question = widget.story.questions[_currentQuestionIndex];
    final isCorrect = index == question.correctIndex;
    final starsPerQuestion = ref.read(storiesProvider).starsPerCorrectQuestion;

    setState(() {
      _selectedOptionIndex = index;
      _hasAnswered = true;
      if (isCorrect) {
        _correctAnswersCount++;
        _totalEarnedStars += starsPerQuestion;
      }
    });

    if (isCorrect) {
      TeacherVoiceService.instance.speak(
        '¡Excelente! ¡Respuesta correcta! Ganaste $starsPerQuestion estrella${starsPerQuestion > 1 ? 's' : ''}.',
      );
    } else {
      final correctText = question.options[question.correctIndex];
      TeacherVoiceService.instance.speak('¡Casi! La respuesta correcta era: $correctText.');
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex + 1 < widget.story.questions.length) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        _hasAnswered = false;
      });
    } else {
      // Quiz terminado
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    setState(() {
      _quizFinished = true;
    });

    if (_totalEarnedStars > 0) {
      ref.read(childProfileProvider.notifier).addStars(_totalEarnedStars);
      ref.read(storiesProvider.notifier).markStoryCompleted(widget.story.id);
      _confettiController.play();
    }

    final profile = ref.read(childProfileProvider);
    final speech =
        '¡Felicitaciones ${profile.name}! Completaste las preguntas de comprensión y ganaste $_totalEarnedStars estrellas brillantes.';
    TeacherVoiceService.instance.speak(speech);
  }

  @override
  Widget build(BuildContext context) {
    final storiesState = ref.watch(storiesProvider);

    return Scaffold(
      body: PlayfulBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Encabezado
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark),
                          onPressed: () {
                            if (_isQuizMode && !_quizFinished) {
                              setState(() => _isQuizMode = false);
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          tooltip: 'Volver',
                        ),
                        Expanded(
                          child: Text(
                            widget.story.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        if (!_isQuizMode)
                          IconButton(
                            icon: Icon(
                              _isReadingAloud ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                              color: AppColors.primaryBlue,
                              size: 26,
                            ),
                            tooltip: _isReadingAloud ? 'Detener lectura' : 'Leer en voz alta',
                            onPressed: _toggleReadAloud,
                          ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: _isQuizMode
                        ? _buildQuizView(storiesState.starsPerCorrectQuestion)
                        : _buildReadingView(storiesState.starsPerCorrectQuestion),
                  ),
                ],
              ),

              // Confeti para celebración
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // VISTA 1: LECTURA DEL CUENTO
  // ---------------------------------------------------------------------------
  Widget _buildReadingView(int starsPerQuestion) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          children: [
            // Portada / Cabecera de la historia
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(widget.story.emoji, style: const TextStyle(fontSize: 54)),
                  const SizedBox(height: 8),
                  Text(
                    widget.story.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.story.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '⏱️ ${widget.story.readingTimeMinutes} minutos de lectura',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '⭐ +$starsPerQuestion por respuesta',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Párrafos del cuento
            ...widget.story.paragraphs.map(
              (p) => Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  p,
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.6,
                    color: AppColors.textDark,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),

            // Moraleja
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.amber.shade300, width: 1.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Moraleja del Cuento:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.story.moral,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontStyle: FontStyle.italic,
                            color: Colors.brown,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Botón para pasar a las preguntas
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _startQuiz,
                icon: const Icon(Icons.quiz_rounded, size: 24),
                label: const Text(
                  '¡Ya leí el cuento! Responder Preguntas ⭐',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.playfulGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 3,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // VISTA 2: CUESTIONARIO DE COMPRENSIÓN LECTORA
  // ---------------------------------------------------------------------------
  Widget _buildQuizView(int starsPerQuestion) {
    if (_quizFinished) {
      return _buildQuizResultView();
    }

    final question = widget.story.questions[_currentQuestionIndex];
    final totalQuestions = widget.story.questions.length;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          children: [
            // Barra de progreso de preguntas
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (_currentQuestionIndex + 1) / totalQuestions,
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${_currentQuestionIndex + 1} de $totalQuestions',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Tarjeta de la Pregunta
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Pregunta ${_currentQuestionIndex + 1}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded, color: AppColors.primaryBlue),
                        onPressed: () {
                          TeacherVoiceService.instance.speak(question.question);
                        },
                        tooltip: 'Escuchar pregunta',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    question.question,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Opciones de respuesta
            ...List.generate(question.options.length, (optIndex) {
              final optText = question.options[optIndex];
              final isSelected = _selectedOptionIndex == optIndex;
              final isCorrect = optIndex == question.correctIndex;

              Color bgColor = Colors.white;
              Color borderColor = Colors.grey.shade300;
              Color textColor = AppColors.textDark;
              IconData? icon;

              if (_hasAnswered) {
                if (isCorrect) {
                  bgColor = Colors.green.shade50;
                  borderColor = Colors.green;
                  textColor = Colors.green.shade900;
                  icon = Icons.check_circle_rounded;
                } else if (isSelected) {
                  bgColor = Colors.red.shade50;
                  borderColor = Colors.red;
                  textColor = Colors.red.shade900;
                  icon = Icons.cancel_rounded;
                }
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  elevation: isSelected ? 3 : 1,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _hasAnswered ? null : () => _handleOptionSelect(optIndex),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor, width: isSelected || (_hasAnswered && isCorrect) ? 2 : 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: (_hasAnswered && isCorrect)
                                  ? Colors.green
                                  : (isSelected && !isCorrect)
                                      ? Colors.red
                                      : Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: icon != null
                                ? Icon(icon, color: Colors.white, size: 20)
                                : Text(
                                    String.fromCharCode(65 + optIndex), // A, B, C, D
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                                  ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              optText,
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: isSelected || (_hasAnswered && isCorrect) ? FontWeight.bold : FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

            // Explicación didáctica
            if (_hasAnswered) ...[
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.primaryBlue, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        question.explanation,
                        style: const TextStyle(fontSize: 13.5, color: AppColors.textDark),
                      ),
                    ),
                  ],
                ),
              ),

              // Botón Siguiente / Finalizar
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _nextQuestion,
                  icon: Icon(
                    _currentQuestionIndex + 1 < totalQuestions ? Icons.arrow_forward_rounded : Icons.star_rounded,
                  ),
                  label: Text(
                    _currentQuestionIndex + 1 < totalQuestions ? 'Siguiente Pregunta ➡️' : '¡Ver Mis Estrellas! 🏆',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // VISTA 3: RESULTADO FINAL DEL CUESTIONARIO
  // ---------------------------------------------------------------------------
  Widget _buildQuizResultView() {
    final profile = ref.read(childProfileProvider);
    final totalQuestions = widget.story.questions.length;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 12),
              Text(
                '¡Excelente trabajo, ${profile.name}!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Respondiste correctamente $_correctAnswersCount de $totalQuestions preguntas.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.sunnyYellow.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.shade300, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.orange, size: 36),
                    const SizedBox(width: 10),
                    Text(
                      '+$_totalEarnedStars Estrellas Ganadas',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.menu_book_rounded),
                  label: const Text(
                    'Volver al Rincón de Cuentos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
