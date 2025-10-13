// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nucleo_casa_decor_android/mobile/models/user_details.dart';
import 'package:nucleo_casa_decor_android/shared/services/specifier_controller.dart';
import 'package:image_picker/image_picker.dart';

class UpdateEspecificador extends StatefulWidget {
  final int especificadorId; // ID para atualizar
  final SpecifierController controller;

  const UpdateEspecificador({Key? key, required this.especificadorId, required this.controller})
    : super(key: key);

  @override
  State<UpdateEspecificador> createState() => _UpdateEspecificadorState();
}

class _UpdateEspecificadorState extends State<UpdateEspecificador> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _seguimentoController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _celularController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _numeroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  XFile? _pickedImage;
  String? _currentImageUrl; // URL da imagem carregada
  final ImagePicker _picker = ImagePicker();

  var regexTextAnNumber = FilteringTextInputFormatter.allow(
    RegExp(r'[a-zA-Z0-9 àèìòùÀÈÌÒÙáéíóúýÁÉÍÓÚÝâêîôûÂÊÎÔÛãñõÃÑÕäëïöüÿÄËÏÖÜŸçÇßØøÅåÆæœ]'),
  );
  var regexNumberOnly = FilteringTextInputFormatter.allow(RegExp(r'[0-9]'));

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await widget.controller.getGetUser(); // carrega o usuário e envia para o stream

    widget.controller.userController.stream.first
        .then((user) {
          setState(() {
            _seguimentoController.text = user?.segment ?? '';
            _telefoneController.text = user?.phone ?? '';
            _celularController.text = user?.cellPhone ?? '';
            _enderecoController.text = user?.address ?? '';
            _numeroController.text = user?.number ?? '';
            _bairroController.text = user?.district ?? '';
            _cidadeController.text = user?.city ?? '';
            _estadoController.text = user?.state ?? '';
          });
        })
        .catchError((e) {
          //log('Erro ao carregar usuário: $e');
        });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _seguimentoController.dispose();
    _telefoneController.dispose();
    _celularController.dispose();
    _enderecoController.dispose();
    _numeroController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (image != null) {
      setState(() {
        _pickedImage = image;
        _currentImageUrl = null; // Limpa URL da imagem ao escolher nova
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Atualizar Especificador',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            StreamBuilder<UserDetails?>(
                              stream: widget.controller.userController.stream,
                              builder: (context, snapshot) {
                                final user = snapshot.data;

                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return CircleAvatar(
                                    radius: 60,
                                    backgroundColor: theme.colorScheme.surface,
                                    child: CircularProgressIndicator(
                                      color: theme.colorScheme.primary,
                                    ),
                                  );
                                }

                                final image =
                                    _pickedImage != null
                                        ? FileImage(File(_pickedImage!.path)) as ImageProvider
                                        : (user != null &&
                                            user.photo != null &&
                                            user.photo!.isNotEmpty)
                                        ? NetworkImage(user.photo!)
                                        : null;

                                return CircleAvatar(
                                  radius: 60,
                                  backgroundColor: theme.colorScheme.primaryContainer,
                                  backgroundImage: image,
                                  child:
                                      (_pickedImage == null &&
                                              (user == null ||
                                                  user.photo == null ||
                                                  user.photo!.isEmpty))
                                          ? Icon(
                                            Icons.person,
                                            size: 60,
                                            color: theme.colorScheme.onPrimaryContainer,
                                          )
                                          : null,
                                );
                              },
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: InkWell(
                                onTap: _pickImage,
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: theme.colorScheme.onPrimary),
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _seguimentoController,
                          inputFormatters: [regexTextAnNumber],
                          decoration: const InputDecoration(
                            labelText: 'Segmento',
                            prefixIcon: Icon(Icons.segment),
                            border: OutlineInputBorder(),
                          ),
                          validator:
                              (value) =>
                                  (value == null || value.isEmpty) ? 'Digite seu Segmento' : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _telefoneController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [regexNumberOnly],
                                decoration: const InputDecoration(
                                  labelText: 'Telefone',
                                  prefixIcon: Icon(Icons.phone),
                                  border: OutlineInputBorder(),
                                ),
                                validator:
                                    (value) =>
                                        (value == null || value.isEmpty)
                                            ? 'Digite seu Telefone'
                                            : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _celularController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [regexNumberOnly],
                                decoration: const InputDecoration(
                                  labelText: 'Celular',
                                  prefixIcon: Icon(Icons.phone_android),
                                  border: OutlineInputBorder(),
                                ),
                                validator:
                                    (value) =>
                                        (value == null || value.isEmpty)
                                            ? 'Digite seu Celular'
                                            : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _enderecoController,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(20),
                                  regexTextAnNumber,
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Endereço',
                                  prefixIcon: Icon(Icons.place),
                                  border: OutlineInputBorder(),
                                ),
                                validator:
                                    (value) =>
                                        (value == null || value.isEmpty)
                                            ? 'Digite seu Endereço'
                                            : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                controller: _numeroController,
                                inputFormatters: [regexNumberOnly],
                                decoration: const InputDecoration(
                                  labelText: 'Número',
                                  prefixIcon: Icon(Icons.confirmation_number),
                                  border: OutlineInputBorder(),
                                ),
                                validator:
                                    (value) =>
                                        (value == null || value.isEmpty) ? 'Digite o Número' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _bairroController,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(20),
                                  regexTextAnNumber,
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Bairro',
                                  prefixIcon: Icon(Icons.map),
                                  border: OutlineInputBorder(),
                                ),
                                validator:
                                    (value) =>
                                        (value == null || value.isEmpty) ? 'Digite o Bairro' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _cidadeController,
                                inputFormatters: [regexTextAnNumber],
                                decoration: const InputDecoration(
                                  labelText: 'Cidade',
                                  prefixIcon: Icon(Icons.location_city),
                                  border: OutlineInputBorder(),
                                ),
                                validator:
                                    (value) =>
                                        (value == null || value.isEmpty) ? 'Digite a Cidade' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _estadoController,
                          inputFormatters: [regexTextAnNumber],
                          decoration: const InputDecoration(
                            labelText: 'Estado',
                            prefixIcon: Icon(Icons.flag),
                            border: OutlineInputBorder(),
                          ),
                          validator:
                              (value) =>
                                  (value == null || value.isEmpty) ? 'Digite o Estado' : null,
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.update),
                            label: Text(
                              'Atualizar',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final updatedUser = UserDetails(
                                  id: widget.especificadorId,
                                  segment: _seguimentoController.text,
                                  phone: _telefoneController.text,
                                  cellPhone: _celularController.text,
                                  address: _enderecoController.text,
                                  number: _numeroController.text,
                                  district: _bairroController.text,
                                  city: _cidadeController.text,
                                  state: _estadoController.text,
                                  photo: _currentImageUrl,
                                );

                                final success = await widget.controller.updateUserData(
                                  updatedUser,
                                  imageFile: _pickedImage,
                                );

                                if (success) {
                                  if (!mounted) return;
                                  Navigator.pop(context);
                                } else {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Erro ao atualizar')),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'VOLTAR',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
