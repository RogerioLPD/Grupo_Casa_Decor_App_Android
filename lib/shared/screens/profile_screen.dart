// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nucleo_casa_decor_android/mobile/models/sample_data.dart';
import 'package:nucleo_casa_decor_android/mobile/models/user_score.dart';
import 'package:nucleo_casa_decor_android/mobile/models/user_details.dart';
import 'package:nucleo_casa_decor_android/mobile/screens/privacy.dart';
import 'package:nucleo_casa_decor_android/mobile/screens/terms.dart';
import 'package:nucleo_casa_decor_android/routes.dart';
import 'package:nucleo_casa_decor_android/shared/services/administrator_controller.dart';
import 'package:nucleo_casa_decor_android/shared/services/authenticator_controller.dart';
import 'package:nucleo_casa_decor_android/shared/services/specifier_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final SpecifierController controller;

  const ProfileScreen({super.key, required this.controller});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  UserDetails? _currentUserDetails;
  late StreamSubscription _userSubscription;

  @override
  void initState() {
    super.initState();

    widget.controller.initValues();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();

    _userSubscription = widget.controller.userController.stream.listen((userDetails) {
      if (mounted) {
        setState(() {
          _currentUserDetails = userDetails;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _userSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const userScore = SampleData.userScore;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Meu Perfil',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // ✅ Passa userDetails
                    ProfileHeader(
                      userScore: userScore,
                      controller: widget.controller,
                      userDetails: _currentUserDetails,
                    ),
                    const SizedBox(height: 24),
                    ProfileStats(userScore: userScore, controller: widget.controller),
                    const SizedBox(height: 24),
                    ProfileSettings(
                      authController: AuthenticationController(),
                      adminController: AdministradorController(),
                      usuarioId: _currentUserDetails?.id ?? 0,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProfileHeader extends StatefulWidget {
  final UserScore userScore;
  final SpecifierController controller;
  final UserDetails? userDetails;

  const ProfileHeader({
    super.key,
    required this.userScore,
    required this.controller,
    required this.userDetails,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

  int _getUserLevel(double totalPoints) {
    if (totalPoints >= 1000) return 5;
    if (totalPoints >= 750) return 4;
    if (totalPoints >= 500) return 3;
    if (totalPoints >= 250) return 2;
    return 1;
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);

    if (image != null && widget.userDetails != null) {
      final success = await widget.controller.updateUserData(widget.userDetails!, imageFile: image);

      if (success) {
        setState(() {
          _pickedImage = image;
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto atualizada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        await widget.controller.getGetUser();
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao atualizar a imagem.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = widget.userDetails;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
            // begin: Alignment.topLeft,
            // end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: CircleAvatar(
                    key: ValueKey(_pickedImage?.path ?? user?.photo),
                    radius: 50,
                    backgroundColor: theme.colorScheme.surface,
                    backgroundImage:
                        _pickedImage != null
                            ? FileImage(File(_pickedImage!.path))
                            : (user?.photo != null && user!.photo!.isNotEmpty
                                ? NetworkImage(user.photo!) as ImageProvider
                                : null),
                    child:
                        (_pickedImage == null && (user?.photo == null || user!.photo!.isEmpty))
                            ? Icon(Icons.person, size: 50, color: theme.colorScheme.primary)
                            : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _pickImage,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.edit, size: 20, color: theme.colorScheme.onPrimary),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Nome
            Text(
              user?.nome?.split(' ').first ?? 'Usuário',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Nível
            StreamBuilder<double>(
              stream: widget.controller.pointsController.stream,
              builder: (context, snapshot) {
                final totalPoints = double.parse((snapshot.data ?? 0.0).toStringAsFixed(2));
                final userLevel = _getUserLevel(totalPoints);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: theme.colorScheme.onSecondary, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        'Nível $userLevel',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Pontuação
            StreamBuilder<double>(
              stream: widget.controller.pointsController.stream,
              builder: (context, snapshot) {
                final totalPoints = double.parse((snapshot.data ?? 0.0).toStringAsFixed(2));
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: theme.colorScheme.onPrimary.withAlpha(200),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${totalPoints.toStringAsFixed(2)} pontos',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileStats extends StatelessWidget {
  final UserScore userScore;
  final SpecifierController controller;
  const ProfileStats({super.key, required this.userScore, required this.controller});

  int _getUserLevel(double totalPoints) {
    if (totalPoints >= 1000) return 5;
    if (totalPoints >= 750) return 4;
    if (totalPoints >= 500) return 3;
    if (totalPoints >= 250) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estatísticas',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StreamBuilder<double>(
                    stream: controller.pointsController.stream,
                    builder: (context, snapshot) {
                      final totalPoints = double.parse((snapshot.data ?? 0.0).toStringAsFixed(2));
                      final userLevel = _getUserLevel(totalPoints);

                      // Formata os valores
                      String displayPoints = totalPoints.toStringAsFixed(2).replaceAll('.', '.');
                      String displayLevel = userLevel.toString();

                      return Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              icon: Icons.trending_up,
                              title: 'Pontos Ganhos',
                              value: displayPoints,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              icon: Icons.star,
                              title: 'Nível',
                              value: displayLevel,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ProfileSettings extends StatelessWidget {
  final AuthenticationController authController;
  final AdministradorController adminController;
  final int usuarioId; // ID do usuário atual

  const ProfileSettings({
    super.key,
    required this.authController,
    required this.adminController,
    required this.usuarioId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configurações',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SettingsItem(
              icon: Icons.privacy_tip,
              title: 'Política de Privacidade',
              subtitle: 'Veja nossa política de privacidade',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                );
              },
            ),
            SettingsItem(
              icon: Icons.article,
              title: 'Termos e Condições',
              subtitle: 'Leia nossos termos de uso',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TermsConditionsPage()),
                );
              },
            ),
            SettingsItem(
              icon: Icons.logout,
              title: 'Sair',
              subtitle: 'Fazer logout da conta',
              onTap: () async {
                await authController.doLogout();

                // Voltar à tela de login ou à tela inicial
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (route) => false);
                }
              },
              isDestructive: true,
            ),
            const SizedBox(height: 20),
            SettingsItem(
              icon: Icons.delete,
              title: 'Excluir Conta',
              subtitle: 'Excluir permanentemente sua conta',
              onTap: () async {
                bool? confirm = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Confirmar exclusão'),
                        content: const Text(
                          'Você tem certeza que deseja excluir sua conta? Essa ação não pode ser desfeita.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(
                              'Cancelar',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(
                              'Excluir',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                );

                if (confirm == true) {
                  bool success = await adminController.deleteUsuario(usuarioId);

                  if (success) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Conta excluída com sucesso.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }

                    // Espera 2 segundos para o usuário ver o SnackBar
                    await Future.delayed(const Duration(seconds: 2));

                    // Limpa o token
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.remove('token');

                    // Navega para a tela de login, limpando toda a pilha
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (route) => false);
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Erro ao excluir conta. Tente novamente.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const SettingsItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isDestructive
                  ? theme.colorScheme.error.withValues(alpha: 0.1)
                  : theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive ? theme.colorScheme.error : theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: isDestructive ? theme.colorScheme.error : theme.colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
