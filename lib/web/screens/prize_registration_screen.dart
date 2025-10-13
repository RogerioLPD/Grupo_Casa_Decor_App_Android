// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nucleo_casa_decor_android/shared/services/administrator_controller.dart';
import 'package:nucleo_casa_decor_android/shared/services/rewards_controller.dart';
import 'package:nucleo_casa_decor_android/web/widgets/reward_grid_widget.dart';

class PrizeRegistrationScreen extends StatefulWidget {
  final RewardsController controller;
  const PrizeRegistrationScreen({super.key, required this.controller});

  @override
  State<PrizeRegistrationScreen> createState() => _PrizeRegistrationScreenState();
}

class _PrizeRegistrationScreenState extends State<PrizeRegistrationScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pointsController = TextEditingController();
  final _quantityController = TextEditingController();
  final _imageUrlController = TextEditingController();

  bool _isLoading = false;

  Uint8List? _imageBytes;

  // Controller e pontos do usuário
  final RewardsController _rewardsController = RewardsController();
  final double _currentUserPoints = 3000;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'heic'],
        onFileLoading: (FilePickerStatus status) => print(status),
        withData: true, // IMPORTANTE para ter os bytes
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _imageBytes = result.files.first.bytes; // Atribui os bytes para exibir a imagem
        });
      }
    } on PlatformException catch (e) {
      log('Unsupported operation: $e' as num);
    } catch (e) {
      log(e.toString() as num);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    _quantityController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // Função utilitária para detectar tablet
  bool isTabletScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1024;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isSmallScreen = isTabletScreen(context);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 32),
                        if (isSmallScreen)
                          Column(
                            children: [
                              _buildRegistrationForm(),
                              const SizedBox(height: 32),
                              SizedBox(
                                height: 600,
                                child: RewardGridWidget(
                                  controller: _rewardsController,
                                  userPoints: _currentUserPoints,
                                  onDelete: (reward) {
                                    setState(() {});
                                  },
                                ),
                              ),
                            ],
                          )
                        else
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 2, child: _buildRegistrationForm()),
                              const SizedBox(width: 32),
                              Expanded(
                                flex: 2,
                                child: SizedBox(
                                  height: 800,
                                  child: RewardGridWidget(
                                    controller: _rewardsController,
                                    userPoints: _currentUserPoints,
                                    onDelete: (reward) {
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cadastro de Prêmios',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Gerencie os prêmios disponíveis para troca de pontos',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Novo Prêmio',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _nameController,
              label: 'Nome do Prêmio',
              icon: Icons.card_giftcard_rounded,
              validator: (value) => value == null || value.isEmpty ? 'Nome é obrigatório' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: 'Descrição',
              icon: Icons.description_rounded,
              maxLines: 3,
              validator:
                  (value) => value == null || value.isEmpty ? 'Descrição é obrigatória' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _pointsController,
              label: 'Pontos Necessários',
              icon: Icons.star_rounded,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Pontos são obrigatórios';
                if (int.tryParse(value) == null) return 'Digite um número válido';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildImagePicker(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _imageBytes == null ? Colors.grey : Theme.of(context).colorScheme.primary,
            width: 2,
          ),
          image:
              _imageBytes != null
                  ? DecorationImage(image: MemoryImage(_imageBytes!), fit: BoxFit.cover)
                  : null,
        ),
        child:
            _imageBytes == null
                ? Center(
                  child: Text(
                    'Clique para selecionar a imagem do prêmio',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
                : null,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child:
            _isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Text('Cadastrar Prêmio'),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final adminController = AdministradorController();

      final success = await adminController.createReward(
        points: _pointsController.text,
        title: _nameController.text,
        description: _descriptionController.text,
        bytes: _imageBytes,
      );

      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Prêmio cadastrado com sucesso!')));

        // Atualiza a lista de prêmios no RewardsController
        await widget.controller.fetchAwards();

        // Não é necessário acessar _filteredRewards aqui;
        // o RewardGridWidget que observa o controller vai atualizar sozinho.

        _clearForm();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Erro ao cadastrar prêmio.')));
      }
    }
  }

  // Limpa campos, incluindo imagem
  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _pointsController.clear();
    setState(() {
      _imageBytes = null;
    });
  }
}
