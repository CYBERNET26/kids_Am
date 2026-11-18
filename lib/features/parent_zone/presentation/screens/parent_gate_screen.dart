import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_am/core/constants/app_colors.dart';
import 'package:kids_am/core/services/teacher_voice_service.dart';
import 'package:kids_am/core/widgets/playful_background.dart';
import 'package:kids_am/features/profile/presentation/providers/profile_provider.dart';
import 'package:kids_am/features/video_library/presentation/providers/video_library_provider.dart';
import 'package:kids_am/features/rewards/domain/models/reward_item.dart';
import 'package:kids_am/features/rewards/presentation/providers/rewards_provider.dart';
import 'package:kids_am/features/parent_zone/domain/models/custom_exercise.dart';
import 'package:kids_am/features/parent_zone/presentation/providers/custom_exercises_provider.dart';
import 'package:kids_am/features/parent_zone/domain/models/background_settings.dart';
import 'package:kids_am/features/parent_zone/presentation/providers/background_settings_provider.dart';
import 'package:kids_am/features/parent_zone/presentation/widgets/background_customizer_dialog.dart';

class ParentGateScreen extends StatefulWidget {
  const ParentGateScreen({super.key});

  @override
  State<ParentGateScreen> createState() => _ParentGateScreenState();
}

class _ParentGateScreenState extends State<ParentGateScreen> {
  bool _isLoading = true;
  bool _hasAccount = false;
  bool _isAuthenticated = false;

  final _createNameController = TextEditingController(text: 'Papá / Mamá');
  final _createEmailController = TextEditingController();
  final _createPasswordController = TextEditingController();
  final _createConfirmPasswordController = TextEditingController();
  bool _obscureCreatePass = true;

  final _loginPasswordController = TextEditingController();
  bool _obscureLoginPass = true;
  String? _loginError;

  bool _isRecovering = false;
  late int _firstNum;
  late int _secondNum;
  late int _mathResult;
  final _recoverAnswerController = TextEditingController();
  String? _recoverError;

  @override
  void initState() {
    super.initState();
    _checkExistingAccount();
  }

  Future<void> _checkExistingAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('parent_password');
    setState(() {
      _hasAccount = savedPassword != null && savedPassword.isNotEmpty;
      _isLoading = false;
    });
  }

  void _generateRecoverChallenge() {
    final rand = Random();
    _firstNum = rand.nextInt(7) + 3;
    _secondNum = rand.nextInt(7) + 3;
    _mathResult = _firstNum * _secondNum;
    _recoverAnswerController.clear();
    _recoverError = null;
    setState(() {
      _isRecovering = true;
    });
  }

  Future<void> _createAccount() async {
    final password = _createPasswordController.text.trim();
    final confirm = _createConfirmPasswordController.text.trim();

    if (password.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La contraseña debe tener al menos 4 caracteres.')),
      );
      return;
    }
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden.')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('parent_name', _createNameController.text.trim());
    await prefs.setString('parent_email', _createEmailController.text.trim());
    await prefs.setString('parent_password', password);
    await prefs.setBool('parent_voice_enabled', true);

    setState(() {
      _hasAccount = true;
      _isAuthenticated = true;
    });
  }

  Future<void> _login() async {
    final inputPassword = _loginPasswordController.text.trim();
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('parent_password') ?? '';

    if (inputPassword == savedPassword) {
      setState(() {
        _isAuthenticated = true;
        _loginError = null;
      });
    } else {
      setState(() {
        _loginError = 'Contraseña incorrecta. Inténtalo nuevamente.';
      });
    }
  }

  void _verifyRecovery() {
    final parsed = int.tryParse(_recoverAnswerController.text.trim());
    if (parsed == _mathResult) {
      setState(() {
        _isRecovering = false;
        _hasAccount = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Identidad verificada. Por favor crea una nueva contraseña.')),
      );
    } else {
      setState(() {
        _recoverError = 'Cálculo incorrecto. Intenta con este nuevo desafío.';
        _generateRecoverChallenge();
      });
    }
  }

  @override
  void dispose() {
    _createNameController.dispose();
    _createEmailController.dispose();
    _createPasswordController.dispose();
    _createConfirmPasswordController.dispose();
    _loginPasswordController.dispose();
    _recoverAnswerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
      );
    }

    if (_isAuthenticated) {
      return const _ParentDashboardView();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zona Exclusiva para Padres'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: PlayfulBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 440),
              padding: const EdgeInsets.all(28.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: _isRecovering
                  ? _buildRecoveryView()
                  : (_hasAccount ? _buildLoginView() : _buildCreateAccountView()),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateAccountView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.security_rounded, size: 64, color: AppColors.primaryBlue),
        const SizedBox(height: 12),
        const Text(
          'Configurar Cuenta Parental',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        const SizedBox(height: 6),
        const Text(
          'Crea tu contraseña de acceso para administrar videos, premios y el nombre del niño.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textMuted),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _createNameController,
          decoration: InputDecoration(
            labelText: 'Nombre o Rol (ej: Mamá, Papá)',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _createEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Correo de contacto (opcional)',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _createPasswordController,
          obscureText: _obscureCreatePass,
          decoration: InputDecoration(
            labelText: 'Contraseña o PIN Parental',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_obscureCreatePass ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscureCreatePass = !_obscureCreatePass),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _createConfirmPasswordController,
          obscureText: _obscureCreatePass,
          decoration: InputDecoration(
            labelText: 'Confirmar Contraseña',
            prefixIcon: const Icon(Icons.lock_reset),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _createAccount,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Crear Cuenta y Entrar', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildLoginView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.lock_outline_rounded, size: 64, color: AppColors.primaryBlue),
        const SizedBox(height: 12),
        const Text(
          'Acceso al Control Parental',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        const SizedBox(height: 6),
        const Text(
          'Ingresa tu contraseña parental para gestionar videos, premios y configuraciones.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textMuted),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _loginPasswordController,
          obscureText: _obscureLoginPass,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Contraseña o PIN Parental',
            prefixIcon: const Icon(Icons.password_rounded),
            errorText: _loginError,
            suffixIcon: IconButton(
              icon: Icon(_obscureLoginPass ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscureLoginPass = !_obscureLoginPass),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onSubmitted: (_) => _login(),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _login,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Iniciar Sesión', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _generateRecoverChallenge,
          child: const Text('¿Olvidaste tu contraseña? (Desafío Adulto)'),
        ),
      ],
    );
  }

  Widget _buildRecoveryView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.help_outline_rounded, size: 60, color: Colors.orange),
        const SizedBox(height: 12),
        const Text(
          'Recuperación de Contraseña',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        const SizedBox(height: 8),
        const Text(
          'Para restablecer tu contraseña, resuelve esta operación para verificar que eres un adulto:',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textMuted),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.softBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '$_firstNum × $_secondNum = ?',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _recoverAnswerController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Resultado',
            errorText: _recoverError,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onSubmitted: (_) => _verifyRecovery(),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _verifyRecovery,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Verificar y Restablecer'),
        ),
        TextButton(
          onPressed: () => setState(() => _isRecovering = false),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}

class _ParentDashboardView extends ConsumerStatefulWidget {
  const _ParentDashboardView();

  @override
  ConsumerState<_ParentDashboardView> createState() => _ParentDashboardViewState();
}

class _ParentDashboardViewState extends ConsumerState<_ParentDashboardView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _videoTitleController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _videoStarsController = TextEditingController(text: '3');
  String _selectedCategory = 'Matemáticas';

  late TextEditingController _childNameController;

  final _rewardTitleController = TextEditingController();
  final _rewardStarsController = TextEditingController(text: '10');
  final _rewardDescController = TextEditingController();
  String _selectedRewardIcon = '🎁';

  bool _voiceEnabled = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    final profile = ref.read(childProfileProvider);
    _childNameController = TextEditingController(text: profile.name);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _voiceEnabled = prefs.getBool('parent_voice_enabled') ?? true;
      TeacherVoiceService.instance.isEnabled = _voiceEnabled;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _videoTitleController.dispose();
    _videoUrlController.dispose();
    _videoStarsController.dispose();
    _childNameController.dispose();
    _rewardTitleController.dispose();
    _rewardStarsController.dispose();
    _rewardDescController.dispose();
    super.dispose();
  }

  void _showAddRewardDialog() {
    _rewardTitleController.clear();
    _rewardStarsController.text = '10';
    _rewardDescController.clear();
    _selectedRewardIcon = '🎁';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final icons = ['🎁', '🍦', '🍕', '🎠', '🍿', '🎮', '🎨', '⚽️', '🚴', '🛹', '🍫'];

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Row(
                children: [
                  Icon(Icons.card_giftcard_rounded, color: AppColors.primaryBlue),
                  SizedBox(width: 8),
                  Text('Nuevo Premio por Estrellas'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Define el premio y cuántas estrellas necesita el niño para canjearlo.',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _rewardTitleController,
                      decoration: InputDecoration(
                        labelText: 'Nombre del premio',
                        hintText: 'Ej: Un Helado, Ir al cine',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _rewardStarsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Costo en Estrellas ⭐',
                        hintText: 'Ej: 10, 20',
                        prefixIcon: const Icon(Icons.star_rounded, color: Colors.orange),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _rewardDescController,
                      decoration: InputDecoration(
                        labelText: 'Detalles o condición (opcional)',
                        hintText: 'Ej: Elige tu sabor preferido',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Elige un icono divertido:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: icons.map((icon) {
                        final isSelected = _selectedRewardIcon == icon;
                        return InkWell(
                          onTap: () => setDialogState(() => _selectedRewardIcon = icon),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.sunnyYellow.withValues(alpha: 0.5)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? Colors.orange : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Text(icon, style: const TextStyle(fontSize: 24)),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final title = _rewardTitleController.text.trim();
                    final stars = int.tryParse(_rewardStarsController.text.trim()) ?? 10;
                    if (title.isNotEmpty && stars > 0) {
                      ref.read(rewardsProvider.notifier).addReward(
                            title: title,
                            costStars: stars,
                            icon: _selectedRewardIcon,
                            description: _rewardDescController.text.trim(),
                          );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('¡Premio creado con éxito!')),
                      );
                    }
                  },
                  child: const Text('Guardar Premio'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditRewardDialog(RewardItem reward) {
    _rewardTitleController.text = reward.title;
    _rewardStarsController.text = reward.costStars.toString();
    _rewardDescController.text = reward.description;
    _selectedRewardIcon = reward.icon;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final icons = ['🎁', '🍦', '🍕', '🎠', '🍿', '🎮', '🎨', '⚽️', '🚴', '🛹', '🍫'];

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Row(
                children: [
                  Icon(Icons.edit_rounded, color: AppColors.primaryBlue),
                  SizedBox(width: 8),
                  Text('Modificar Premio'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _rewardTitleController,
                      decoration: InputDecoration(
                        labelText: 'Nombre del premio',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _rewardStarsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Costo en Estrellas ⭐',
                        prefixIcon: const Icon(Icons.star_rounded, color: Colors.orange),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _rewardDescController,
                      decoration: InputDecoration(
                        labelText: 'Detalles o condición (opcional)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Icono:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: icons.map((icon) {
                        final isSelected = _selectedRewardIcon == icon;
                        return InkWell(
                          onTap: () => setDialogState(() => _selectedRewardIcon = icon),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.sunnyYellow.withValues(alpha: 0.5)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? Colors.orange : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Text(icon, style: const TextStyle(fontSize: 24)),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.playfulGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final title = _rewardTitleController.text.trim();
                    final stars = int.tryParse(_rewardStarsController.text.trim()) ?? 10;
                    if (title.isNotEmpty && stars > 0) {
                      ref.read(rewardsProvider.notifier).updateReward(
                            id: reward.id,
                            title: title,
                            costStars: stars,
                            icon: _selectedRewardIcon,
                            description: _rewardDescController.text.trim(),
                          );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('¡Premio modificado con éxito!')),
                      );
                    }
                  },
                  child: const Text('Guardar Cambios'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddVideoDialog() {
    _videoTitleController.clear();
    _videoUrlController.clear();
    _videoStarsController.text = '3';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final inputUrl = _videoUrlController.text;
            final isYoutube = inputUrl.contains('youtube.com') || inputUrl.contains('youtu.be');

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Row(
                children: [
                  Icon(Icons.video_library_rounded, color: AppColors.primaryBlue),
                  SizedBox(width: 8),
                  Text('Agregar Video Educativo'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pega cualquier enlace de YouTube o video directo (MP4). Asigna cuántas estrellas ganará el niño por verlo completo.',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _videoTitleController,
                      decoration: InputDecoration(
                        labelText: 'Título del video',
                        hintText: 'Ej: Canción de los Números',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _videoUrlController,
                      onChanged: (_) => setDialogState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Enlace del video (YouTube o MP4)',
                        hintText: 'https://www.youtube.com/watch?v=... o https://youtu.be/...',
                        prefixIcon: Icon(
                          isYoutube ? Icons.play_arrow : Icons.link,
                          color: isYoutube ? Colors.red : AppColors.primaryBlue,
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _videoStarsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Estrellas al ver el video completo ⭐',
                        hintText: 'Ej: 3, 5',
                        prefixIcon: const Icon(Icons.star_rounded, color: Colors.orange),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    if (isYoutube) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.red, size: 16),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Detectado enlace de YouTube. Se reproducirá seguro en la app.',
                                style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Categoría educativa',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Matemáticas', child: Text('Matemáticas')),
                        DropdownMenuItem(value: 'Geometría', child: Text('Geometría')),
                        DropdownMenuItem(value: 'Ajedrez', child: Text('Ajedrez')),
                        DropdownMenuItem(value: 'Ciencias', child: Text('Ciencias')),
                        DropdownMenuItem(value: 'Lectura', child: Text('Lectura y Cuentos')),
                        DropdownMenuItem(value: 'Música', child: Text('Música y Baile')),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => _selectedCategory = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final title = _videoTitleController.text.trim();
                    final url = _videoUrlController.text.trim();
                    final stars = int.tryParse(_videoStarsController.text.trim()) ?? 3;
                    if (title.isNotEmpty && url.isNotEmpty) {
                      ref.read(videoLibraryProvider.notifier).addVideo(
                            title: title,
                            url: url,
                            category: _selectedCategory,
                            rewardStars: stars,
                          );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('¡Video educativo añadido con éxito!')),
                      );
                    }
                  },
                  child: const Text('Guardar Video'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Control Parental 🛡️'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primaryBlue,
          indicatorWeight: 3,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.video_library), text: 'Videos'),
            Tab(icon: Icon(Icons.calculate_rounded), text: 'Ejercicios'),
            Tab(icon: Icon(Icons.card_giftcard), text: 'Premios'),
            Tab(icon: Icon(Icons.person_pin), text: 'Perfil'),
            Tab(icon: Icon(Icons.settings), text: 'Ajustes'),
          ],
        ),
      ),
      body: PlayfulBackground(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildVideosTab(),
            _buildExercisesTab(),
            _buildRewardsTab(),
            _buildProfileTab(),
            _buildSettingsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideosTab() {
    final videos = ref.watch(videoLibraryProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _showAddVideoDialog,
                      icon: const Icon(Icons.add_rounded, size: 22),
                      label: const Text(
                        'Cargar Video',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryBlue, size: 24),
                      tooltip: 'Recargar videos por defecto (desde default_videos.dart)',
                      onPressed: () {
                        ref.read(videoLibraryProvider.notifier).restoreDefaults();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('¡Videos por defecto recargados!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: videos.isEmpty
                  ? const Center(child: Text('No hay videos cargados aún.'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: videos.length,
                      itemBuilder: (context, index) {
                        final video = videos[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: video.isYoutube
                                  ? Colors.red.withValues(alpha: 0.15)
                                  : AppColors.primaryBlue.withValues(alpha: 0.15),
                              child: Icon(
                                video.isYoutube ? Icons.play_arrow : Icons.videocam,
                                color: video.isYoutube ? Colors.red : AppColors.primaryBlue,
                              ),
                            ),
                            title: Text(video.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${video.category} • ⭐ +${video.rewardStars} estrellas • ${video.isYoutube ? "YouTube" : "Directo"}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              tooltip: 'Eliminar video',
                              onPressed: () {
                                ref.read(videoLibraryProvider.notifier).removeVideo(video.id);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomExerciseDialog([CustomExercise? exercise]) {
    final isEditing = exercise != null;
    MathOperation selectedOp = exercise?.operation ?? MathOperation.addition;
    final numAController = TextEditingController(text: exercise != null ? '${exercise.firstNum}' : '5');
    final numBController = TextEditingController(text: exercise != null ? '${exercise.secondNum}' : '3');
    final noteController = TextEditingController(text: exercise?.note ?? '');

    int calculateAutoResult(MathOperation op, int a, int b) {
      switch (op) {
        case MathOperation.addition:
          return a + b;
        case MathOperation.subtraction:
          return a - b;
        case MathOperation.multiplication:
          return a * b;
        case MathOperation.division:
          return b != 0 ? a ~/ b : 0;
      }
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final a = int.tryParse(numAController.text.trim()) ?? 0;
            final b = int.tryParse(numBController.text.trim()) ?? 0;
            final autoResult = calculateAutoResult(selectedOp, a, b);

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit : Icons.add_circle,
                    color: AppColors.primaryBlue,
                  ),
                  const SizedBox(width: 8),
                  Text(isEditing ? 'Editar Ejercicio' : 'Crear Ejercicio'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Diseña un ejercicio personalizado para que tu hijo lo resuelva en Mundo Matemático:',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 16),
                    const Text('Operación:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: MathOperation.values.map((op) {
                        final isSel = selectedOp == op;
                        return ChoiceChip(
                          label: Text('${op.symbol} ${op.label}'),
                          selected: isSel,
                          selectedColor: AppColors.primaryBlue.withValues(alpha: 0.25),
                          onSelected: (val) {
                            if (val) setDialogState(() => selectedOp = op);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: numAController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Primer Número',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onChanged: (_) => setDialogState(() {}),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            selectedOp.symbol,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: numBController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Segundo Número',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onChanged: (_) => setDialogState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Resultado:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(
                            '$a ${selectedOp.symbol} $b = $autoResult',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: noteController,
                      decoration: InputDecoration(
                        labelText: 'Mensaje especial o pista (opcional)',
                        hintText: 'Ej: ¡Práctica para la prueba escolar!',
                        prefixIcon: const Icon(Icons.favorite, color: Colors.pinkAccent),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    final first = int.tryParse(numAController.text.trim()) ?? 0;
                    final second = int.tryParse(numBController.text.trim()) ?? 0;
                    if (selectedOp == MathOperation.division && second == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No es posible dividir por 0.')),
                      );
                      return;
                    }
                    final res = calculateAutoResult(selectedOp, first, second);
                    if (isEditing) {
                      ref.read(customExercisesProvider.notifier).updateExercise(
                            id: exercise.id,
                            operation: selectedOp,
                            firstNum: first,
                            secondNum: second,
                            correctResult: res,
                            note: noteController.text.trim(),
                          );
                    } else {
                      ref.read(customExercisesProvider.notifier).addExercise(
                            operation: selectedOp,
                            firstNum: first,
                            secondNum: second,
                            correctResult: res,
                            note: noteController.text.trim(),
                          );
                    }
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEditing ? '¡Ejercicio actualizado con éxito!' : '¡Ejercicio creado con éxito!')),
                    );
                  },
                  child: Text(isEditing ? 'Guardar Cambios' : 'Crear Ejercicio'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildExercisesTab() {
    final exercises = ref.watch(customExercisesProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () => _showCustomExerciseDialog(),
                  icon: const Icon(Icons.add_rounded, size: 22),
                  label: const Text(
                    'Crear Ejercicio',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                  ),
                ),
              ),
            ),
            Expanded(
              child: exercises.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.calculate_outlined, size: 64, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            const Text(
                              'No hay ejercicios creados aún.',
                              style: TextStyle(fontSize: 16, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Puedes diseñar sumas, restas, multiplicaciones o divisiones a medida para que tu hijo las resuelva.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => _showCustomExerciseDialog(),
                              icon: const Icon(Icons.add),
                              label: const Text('Crear Primer Ejercicio'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        final item = exercises[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 2,
                          child: ListTile(
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  item.operation.symbol,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              '${item.firstNum} ${item.operation.symbol} ${item.secondNum} = ${item.correctResult}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (item.note.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    item.note,
                                    style: const TextStyle(color: Colors.pinkAccent, fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                ],
                                const SizedBox(height: 2),
                                Text(
                                  item.isCompleted ? '✅ Resuelto por el niño' : '⏳ Pendiente de resolver',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: item.isCompleted ? Colors.green : Colors.orange.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_rounded, color: Colors.blue),
                                  tooltip: 'Editar',
                                  onPressed: () => _showCustomExerciseDialog(item),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  tooltip: 'Eliminar',
                                  onPressed: () {
                                    ref.read(customExercisesProvider.notifier).deleteExercise(item.id);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsTab() {
    final rewards = ref.watch(rewardsProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: _showAddRewardDialog,
                  icon: const Icon(Icons.add_rounded, size: 22),
                  label: const Text(
                    'Crear Premio',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.playfulGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                  ),
                ),
              ),
            ),
            Expanded(
              child: rewards.isEmpty
                  ? const Center(child: Text('No hay premios configurados.'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: rewards.length,
                      itemBuilder: (context, index) {
                        final reward = rewards[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.sunnyYellow.withValues(alpha: 0.35),
                              child: Text(reward.icon, style: const TextStyle(fontSize: 24)),
                            ),
                            title: Text(reward.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              reward.description.isNotEmpty
                                  ? '${reward.description} • ⭐ ${reward.costStars} estrellas'
                                  : '⭐ ${reward.costStars} estrellas',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (reward.timesRedeemed > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.playfulGreen.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Canjeado: ${reward.timesRedeemed}x',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.playfulGreen),
                                    ),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: AppColors.primaryBlue),
                                  tooltip: 'Modificar premio',
                                  onPressed: () => _showEditRewardDialog(reward),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  tooltip: 'Eliminar premio',
                                  onPressed: () {
                                    ref.read(rewardsProvider.notifier).removeReward(reward.id);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    final profile = ref.watch(childProfileProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nombre del Niño / Explorador',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                  const SizedBox(height: 6),
                  const Text(
                    'La maestra usará este nombre para saludarlo y felicitarlo al jugar.',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _childNameController,
                          decoration: InputDecoration(
                            hintText: 'Nombre del niño/a',
                            prefixIcon: const Icon(Icons.edit, color: AppColors.primaryBlue),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          final newName = _childNameController.text.trim();
                          if (newName.isNotEmpty) {
                            ref.read(childProfileProvider.notifier).updateName(newName);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('¡Nombre actualizado a "$newName"!')),
                            );
                          }
                        },
                        child: const Text('Guardar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.sunnyYellow,
                    child: Icon(Icons.star_rounded, size: 36, color: Colors.orange),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${profile.totalStars} Estrellas Disponibles',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                        const Text(
                          'Tu hijo/a puede canjearlas por los premios que configuraste.',
                          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),
          const Text('Niveles Actuales por Disciplina:', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildLevelCard(
            title: 'Mundo Matemático',
            currentLevel: profile.mathLevel,
            maxLevel: 10,
            icon: Icons.calculate,
            color: const Color(0xFFFF9233),
          ),
          _buildLevelCard(
            title: 'Mini-Ajedrez Táctico',
            currentLevel: profile.chessLevel,
            maxLevel: 6,
            icon: Icons.castle,
            color: const Color(0xFF8E44AD),
          ),
          _buildLevelCard(
            title: 'Rompecabezas Cognitivo',
            currentLevel: profile.puzzleLevel,
            maxLevel: 5,
            icon: Icons.extension,
            color: const Color(0xFF5CD85A),
          ),
        ],
      ),
    ),
  ),
);
}

  Widget _buildLevelCard({
    required String title,
    required int currentLevel,
    required int maxLevel,
    required IconData icon,
    required Color color,
  }) {
    final progress = (currentLevel / maxLevel).clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                Text('Nivel $currentLevel de $maxLevel', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    final bgSettings = ref.watch(backgroundSettingsProvider);
    final bgNotifier = ref.read(backgroundSettingsProvider.notifier);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            // SECCIÓN 1: COLOR DEL FONDO DE LOS JUEGOS
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.palette_rounded, color: AppColors.primaryBlue, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Color de Fondo de los Juegos',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Personaliza el color suave del fondo para toda la app:',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: BackgroundColorTheme.values.map((theme) {
                        final isSel = bgSettings.colorTheme == theme;
                        return InkWell(
                          onTap: () => bgNotifier.setColorTheme(theme),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? AppColors.primaryBlue.withValues(alpha: 0.15)
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSel ? AppColors.primaryBlue : Colors.grey.shade300,
                                width: isSel ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: theme.previewColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey.shade400, width: 1),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  theme.name,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                    color: isSel ? AppColors.primaryBlue : AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // SECCIÓN 2: DIBUJOS DECORATIVOS EN LUGARES FIJOS (SIN PISARSE)
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded, color: Colors.orange, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Dibujos y Personajes en el Fondo',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Aparecen en lugares fijos sin solaparse ni tapar nada del juego:',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: BackgroundDrawingTheme.values.map((theme) {
                        final isSel = bgSettings.drawingTheme == theme;
                        return ChoiceChip(
                          label: Text(theme.label),
                          selected: isSel,
                          selectedColor: Colors.orange.withValues(alpha: 0.25),
                          onSelected: (val) {
                            if (val) bgNotifier.setDrawingTheme(theme);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () => BackgroundCustomizerDialog.show(context),
                      icon: const Icon(Icons.tune_rounded),
                      label: const Text('Personalizar Lugares Fijos (Evita Solapamientos)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // SECCIÓN 3: CONFIGURACIÓN GENERAL
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: SwitchListTile(
                title: const Text('Voz de Maestra (Profe Sofía)', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Instrucciones, correcciones y felicitaciones con voz didáctica'),
                value: _voiceEnabled,
                activeTrackColor: AppColors.playfulGreen,
                onChanged: (val) async {
                  setState(() => _voiceEnabled = val);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('parent_voice_enabled', val);
                  TeacherVoiceService.instance.isEnabled = val;
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: ListTile(
                leading: const Icon(Icons.card_giftcard, color: AppColors.playfulGreen),
                title: const Text('Restaurar Premios Sugeridos'),
                subtitle: const Text('Restaura la lista de premios predeterminados'),
                onTap: () {
                  ref.read(rewardsProvider.notifier).restoreDefaults();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Premios predeterminados restaurados')),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: ListTile(
                leading: const Icon(Icons.restore, color: AppColors.primaryBlue),
                title: const Text('Restaurar Videos por Defecto'),
                subtitle: const Text('Vuelve a cargar los videos seguros iniciales'),
                onTap: () {
                  ref.read(videoLibraryProvider.notifier).restoreDefaults();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Videos por defecto restaurados')),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.red),
                title: const Text('Cerrar Sesión Parental'),
                subtitle: const Text('Volver a la pantalla infantil'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
