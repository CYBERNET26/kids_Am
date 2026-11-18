import 'package:flutter/material.dart';
import 'package:kids_am/core/constants/app_colors.dart';
import 'package:kids_am/core/services/teacher_voice_service.dart';
import 'package:kids_am/features/parent_zone/domain/models/custom_exercise.dart';

class MathPreambleDialog extends StatefulWidget {
  final MathOperation initialOperation;
  final bool autoSpeak;

  const MathPreambleDialog({
    super.key,
    this.initialOperation = MathOperation.addition,
    this.autoSpeak = true,
  });

  static Future<void> show(
    BuildContext context, {
    MathOperation initialOperation = MathOperation.addition,
    bool autoSpeak = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => MathPreambleDialog(
        initialOperation: initialOperation,
        autoSpeak: autoSpeak,
      ),
    );
  }

  @override
  State<MathPreambleDialog> createState() => _MathPreambleDialogState();
}

class _MathPreambleDialogState extends State<MathPreambleDialog> {
  late MathOperation _currentOp;

  @override
  void initState() {
    super.initState();
    _currentOp = widget.initialOperation;
    if (widget.autoSpeak) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _speakCurrentExplanation();
      });
    }
  }

  void _speakCurrentExplanation() {
    final text = _getVoiceText(_currentOp);
    TeacherVoiceService.instance.speak(text);
  }

  String _getVoiceText(MathOperation op) {
    switch (op) {
      case MathOperation.addition:
        return '¡Vamos a aprender a sumar! Sumar significa juntar o agregar cosas. Por ejemplo, si tienes dos manzanas y te regalan una más, las juntamos todas en tu canasta y ahora tienes tres manzanas. ¡Sumar hace que tengamos más!';
      case MathOperation.subtraction:
        return '¡Aprendamos a restar! Restar es lo contrario de sumar: significa quitar, comer o regalar. Si tienes cuatro ricas galletas y te comes una, te quedan tres galletas. ¡Restar es saber cuánto nos queda!';
      case MathOperation.multiplication:
        return '¡Bienvenidos a la multiplicación! Multiplicar es un súper truco para sumar muy rápido el mismo número. Si tenemos tres grupos con dos estrellas cada uno, en vez de sumar dos más dos más dos, decimos: ¡tres por dos es igual a seis!';
      case MathOperation.division:
        return '¡Bienvenidos a la división! Dividir es repartir en partes iguales entre amigos para que todos tengan lo mismo. Si tenemos seis ricos caramelos y dos amigos, le tocan tres caramelos a cada uno. ¡Seis dividido dos es tres!';
    }
  }

  @override
  void dispose() {
    TeacherVoiceService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 620),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Selector de operaciones
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: MathOperation.values.map((op) {
                    final isSelected = _currentOp == op;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(
                          '${op.symbol} ${op.label}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppColors.textDark,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: _getOpColor(op),
                        backgroundColor: Colors.grey.shade100,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _currentOp = op);
                            _speakCurrentExplanation();
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 14),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildOperationContent(_currentOp),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _speakCurrentExplanation,
                    icon: const Icon(Icons.volume_up_rounded, color: AppColors.primaryBlue),
                    label: const Text('Escuchar'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        TeacherVoiceService.instance.stop();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getOpColor(_currentOp),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        '¡Entendido, a jugar! 🚀',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getOpColor(MathOperation op) {
    switch (op) {
      case MathOperation.addition:
        return const Color(0xFF4CAF50);
      case MathOperation.subtraction:
        return const Color(0xFFE91E63);
      case MathOperation.multiplication:
        return const Color(0xFF9C27B0);
      case MathOperation.division:
        return const Color(0xFF00ACC1);
    }
  }

  Widget _buildOperationContent(MathOperation op) {
    switch (op) {
      case MathOperation.addition:
        return _buildAdditionCard();
      case MathOperation.subtraction:
        return _buildSubtractionCard();
      case MathOperation.multiplication:
        return _buildMultiplicationCard();
      case MathOperation.division:
        return _buildDivisionCard();
    }
  }

  Widget _buildAdditionCard() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.shade200, width: 2),
          ),
          child: Column(
            children: [
              const Row(
                children: [
                  Text('➕', style: TextStyle(fontSize: 28)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '¿Qué es Sumar? ¡Juntar y Agregar!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Sumar es poner cosas juntas para saber cuántas tenemos en total.',
                style: TextStyle(fontSize: 14, color: AppColors.textDark, height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Text('Ejemplo:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🍎 🍎', style: TextStyle(fontSize: 24)),
                        SizedBox(width: 8),
                        Text('+', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                        SizedBox(width: 8),
                        Text('🍏', style: TextStyle(fontSize: 24)),
                        SizedBox(width: 8),
                        Text('=', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        Text('🍎 🍎 🍏', style: TextStyle(fontSize: 24)),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      '2 manzanas + 1 manzana = 3 manzanas',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubtractionCard() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.pink.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.pink.shade200, width: 2),
          ),
          child: Column(
            children: [
              const Row(
                children: [
                  Text('➖', style: TextStyle(fontSize: 28)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '¿Qué es Restar? ¡Quitar y saber qué queda!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pink),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Restar es quitar, comerse o regalar cosas y contar cuántas nos sobran.',
                style: TextStyle(fontSize: 14, color: AppColors.textDark, height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Text('Ejemplo:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink)),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🍪 🍪 🍪 🍪', style: TextStyle(fontSize: 22)),
                        SizedBox(width: 8),
                        Text('−', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pink)),
                        SizedBox(width: 8),
                        Text('🍪', style: TextStyle(fontSize: 22)),
                        SizedBox(width: 8),
                        Text('=', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        Text('🍪 🍪 🍪', style: TextStyle(fontSize: 22)),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      '4 galletas − 1 galleta comida = 3 galletas',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMultiplicationCard() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.purple.shade200, width: 2),
          ),
          child: Column(
            children: [
              const Row(
                children: [
                  Text('✖️', style: TextStyle(fontSize: 28)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nivel 3+: ¿Qué es Multiplicar? ¡Sumar Rápido!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Multiplicar es sumar el mismo número varias veces en grupos iguales.',
                style: TextStyle(fontSize: 14, color: AppColors.textDark, height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text('Ejemplo: 3 × 2 (3 grupos de 2)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildMiniGroup(['⭐️', '⭐️']),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text('+', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                        _buildMiniGroup(['⭐️', '⭐️']),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text('+', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                        _buildMiniGroup(['⭐️', '⭐️']),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text('=', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                        const Text(' 6', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '¡2 + 2 + 2 es igual a 6! En vez de sumar 3 veces, decimos: 3 × 2 = 6.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivisionCard() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.cyan.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.cyan.shade200, width: 2),
          ),
          child: Column(
            children: [
              const Row(
                children: [
                  Text('➗', style: TextStyle(fontSize: 28)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nivel 6+: ¿Qué es Dividir? ¡Repartir en partes iguales!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00838F)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Dividir es repartir cosas en grupos exactamente iguales entre amigos para que nadie se quede sin nada.',
                style: TextStyle(fontSize: 14, color: AppColors.textDark, height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text('Ejemplo: 6 ÷ 2 (6 caramelos entre 2 amigos)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00838F))),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            const Text('Amigo 1 👦', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            _buildMiniGroup(['🍬', '🍬', '🍬']),
                          ],
                        ),
                        const SizedBox(width: 14),
                        const Text('y', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(width: 14),
                        Column(
                          children: [
                            const Text('Amigo 2 👧', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            _buildMiniGroup(['🍬', '🍬', '🍬']),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '¡A cada amigo le tocan 3 caramelos!\n6 ÷ 2 = 3',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMiniGroup(List<String> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items.map((e) => Text(e, style: const TextStyle(fontSize: 18))).toList(),
      ),
    );
  }
}
