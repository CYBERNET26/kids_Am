import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_am/core/constants/app_colors.dart';
import 'package:kids_am/core/services/teacher_voice_service.dart';
import 'package:kids_am/features/profile/presentation/providers/profile_provider.dart';
import 'package:kids_am/features/video_library/presentation/providers/video_library_provider.dart';

class ParentGateScreen extends StatefulWidget {
  const ParentGateScreen({super.key});

  @override
  State<ParentGateScreen> createState() => _ParentGateScreenState();
}

class _ParentGateScreenState extends State<ParentGateScreen> {
  bool _isLoading = true;
  bool _hasAccount = false;
  bool _isAuthenticated = false;

  // Controllers para Crear Cuenta
  final _createNameController = TextEditingController(text: 'Papá / Mamá');
  final _createEmailController = TextEditingController();
  final _createPasswordController = TextEditingController();
  final _createConfirmPasswordController = TextEditingController();
  bool _obscureCreatePass = true;

  // Controllers para Iniciar Sesión
  final _loginPasswordController = TextEditingController();
  bool _obscureLoginPass = true;
  String? _loginError;

  // Fallback Desafío Matemático para recuperar contraseña
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
        _hasAccount = false; // Permite crear una nueva contraseña
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
      backgroundColor: AppColors.softBackground,
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
          'Crea tu contraseña de acceso para administrar videos educativos, ver el progreso y configurar Kids Am.',
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
          'Ingresa tu contraseña parental para gestionar videos y configuraciones.',
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
  String _selectedCategory = 'Matemáticas';
  bool _voiceEnabled = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    super.dispose();
  }

  void _showAddVideoDialog() {
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
                      'Pega cualquier enlace de YouTube o archivo de video directo (MP4). ¡Se reproducirá seguro dentro de Kids Am!',
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
                                'Detectado enlace de YouTube. Se reproducirá sin anuncios en la app.',
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
                    if (title.isNotEmpty && url.isNotEmpty) {
                      ref.read(videoLibraryProvider.notifier).addVideo(
                            title: title,
                            url: url,
                            category: _selectedCategory,
                          );
                      _videoTitleController.clear();
                      _videoUrlController.clear();
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
      backgroundColor: AppColors.softBackground,
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
          tabs: const [
            Tab(icon: Icon(Icons.video_library), text: 'Videos'),
            Tab(icon: Icon(Icons.insights), text: 'Progreso'),
            Tab(icon: Icon(Icons.settings), text: 'Ajustes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVideosTab(),
          _buildProgressTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildVideosTab() {
    final videos = ref.watch(videoLibraryProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Videos Habilitados (${videos.length})',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              ElevatedButton.icon(
                onPressed: _showAddVideoDialog,
                icon: const Icon(Icons.add),
                label: const Text('Cargar Video'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
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
                        subtitle: Text('${video.category} • ${video.isYoutube ? "YouTube" : "Directo"}'),
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
    );
  }

  Widget _buildProgressTab() {
    final profile = ref.watch(childProfileProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.sunnyYellow,
                    child: Icon(Icons.face_5, size: 40, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${profile.totalStars} Estrellas Ganadas ⭐',
                          style: const TextStyle(fontSize: 16, color: Colors.orange, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Niveles por Disciplina:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
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
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    );
  }
}
