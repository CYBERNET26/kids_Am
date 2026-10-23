import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kids_am/core/constants/app_colors.dart';
import 'package:kids_am/features/profile/presentation/providers/profile_provider.dart';
import 'package:kids_am/features/video_library/presentation/providers/video_library_provider.dart';

class ParentGateScreen extends StatefulWidget {
  const ParentGateScreen({super.key});

  @override
  State<ParentGateScreen> createState() => _ParentGateScreenState();
}

class _ParentGateScreenState extends State<ParentGateScreen> {
  late int _firstNumber;
  late int _secondNumber;
  late int _correctAnswer;
  final TextEditingController _answerController = TextEditingController();
  bool _isUnlocked = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _generateChallenge();
  }

  void _generateChallenge() {
    final random = Random();
    // Desafío de multiplicación pensado para que un niño de 6 años no lo desbloquee por accidente
    _firstNumber = random.nextInt(6) + 4; // 4 a 9
    _secondNumber = random.nextInt(6) + 4; // 4 a 9
    _correctAnswer = _firstNumber * _secondNumber;
    _answerController.clear();
    _errorMessage = null;
  }

  void _verifyAnswer() {
    final parsed = int.tryParse(_answerController.text.trim());
    if (parsed == _correctAnswer) {
      setState(() {
        _isUnlocked = true;
      });
    } else {
      setState(() {
        _errorMessage = 'Respuesta incorrecta. Inténtalo de nuevo.';
        _generateChallenge();
      });
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isUnlocked) {
      return const _ParentDashboardView();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zona Exclusiva para Padres'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_outlined, size: 64, color: AppColors.primaryBlue),
                const SizedBox(height: 16),
                const Text(
                  'Control Parental',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Para continuar, por favor resuelve la siguiente operación matemática:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: AppColors.textMuted),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  decoration: BoxDecoration(
                    color: AppColors.softBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '$_firstNumber × $_secondNumber = ?',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _answerController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  autofocus: true,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: 'Tu respuesta',
                    errorText: _errorMessage,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onSubmitted: (_) => _verifyAnswer(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _verifyAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Entrar al Panel', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ParentDashboardView extends ConsumerStatefulWidget {
  const _ParentDashboardView();

  @override
  ConsumerState<_ParentDashboardView> createState() => _ParentDashboardViewState();
}

class _ParentDashboardViewState extends ConsumerState<_ParentDashboardView> {
  final _videoTitleController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final String _selectedCategory = 'Matemáticas';

  @override
  void dispose() {
    _videoTitleController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  void _addVideoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar Video Seguro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _videoTitleController,
              decoration: const InputDecoration(labelText: 'Título del video'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _videoUrlController,
              decoration: const InputDecoration(labelText: 'URL directa de video (MP4/HLS)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_videoTitleController.text.isNotEmpty && _videoUrlController.text.isNotEmpty) {
                ref.read(videoLibraryProvider.notifier).addVideo(
                      title: _videoTitleController.text.trim(),
                      url: _videoUrlController.text.trim(),
                      category: _selectedCategory,
                    );
                _videoTitleController.clear();
                _videoUrlController.clear();
                Navigator.pop(ctx);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(childProfileProvider);
    final videos = ref.watch(videoLibraryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Configuración Parental'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Progreso de tu hijo/a',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text('Nombre: ${profile.name} (Edad: ${profile.age} años)'),
                  Text('Estrellas Acumuladas: ${profile.totalStars} ⭐'),
                  const Divider(height: 24),
                  const Text('Ajuste de Niveles de Dificultad:'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Matemáticas: Nivel ${profile.mathLevel}'),
                      Slider(
                        value: profile.mathLevel.toDouble(),
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: '${profile.mathLevel}',
                        onChanged: (val) {
                          ref.read(childProfileProvider.notifier).setLevels(math: val.toInt());
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Rompecabezas: Nivel ${profile.puzzleLevel}'),
                      Slider(
                        value: profile.puzzleLevel.toDouble(),
                        min: 1,
                        max: 3,
                        divisions: 2,
                        label: '${profile.puzzleLevel}',
                        onChanged: (val) {
                          ref.read(childProfileProvider.notifier).setLevels(puzzle: val.toInt());
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ajedrez: Nivel ${profile.chessLevel}'),
                      Slider(
                        value: profile.chessLevel.toDouble(),
                        min: 1,
                        max: 4,
                        divisions: 3,
                        label: '${profile.chessLevel}',
                        onChanged: (val) {
                          ref.read(childProfileProvider.notifier).setLevels(chess: val.toInt());
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Videos Permitidos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _addVideoDialog,
                icon: const Icon(Icons.add),
                label: const Text('Nuevo Video'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...videos.map((vid) => Card(
                child: ListTile(
                  leading: const Icon(Icons.video_collection, color: AppColors.primaryBlue),
                  title: Text(vid.title),
                  subtitle: Text('${vid.category} • ${vid.urlOrAssetPath}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      ref.read(videoLibraryProvider.notifier).removeVideo(vid.id);
                    },
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

