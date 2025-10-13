// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nucleo_casa_decor_android/routes.dart';
import 'package:nucleo_casa_decor_android/shared/services/administrator_controller.dart';
import 'package:nucleo_casa_decor_android/shared/services/authenticator_controller.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'dart:typed_data';

class RegisterEspecificador extends StatefulWidget {
  const RegisterEspecificador({super.key});

  @override
  State<RegisterEspecificador> createState() => _RegisterEspecificadorState();
}

class _RegisterEspecificadorState extends State<RegisterEspecificador>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfCnpjController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool isLoading = false;
  bool visivelSenha = true;

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late MaskTextInputFormatter activeFormatter;

  final controller = AdministradorController();

  // Máscaras separadas
  final cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  final cnpjFormatter = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void initState() {
    activeFormatter = cpfFormatter;
    super.initState();
    AuthenticationController().doLogout();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      final success = await controller.createSpecified(
        name: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
        cpf: _cpfCnpjController.text.trim(), // mantém mascarado como antes
        bytes: Uint8List(0),
      );

      setState(() => isLoading = false);

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cadastro realizado com sucesso!')));
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Erro ao cadastrar. Verifique os dados.')));
      }
    }
  }

  void _toggleSenha() {
    setState(() => visivelSenha = !visivelSenha);
  }

  void _handleCpfCnpjMaskSwitch(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    setState(() {
      if (digits.length > 11) {
        activeFormatter = cnpjFormatter;
      } else {
        activeFormatter = cpfFormatter;
      }
    });
  }

  Widget _buildForm() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 10, 32, 32),
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Form(
              key: _formKey,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Opacity(
                      opacity: 0.99,
                      child: Image.asset(
                        'assets/images/Grupo.png',
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: 300,
                      ),
                    ),
                  ),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: Colors.white.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 10),
                          const Text(
                            '',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 120),
                          TextFormField(
                            controller: _nomeController,
                            decoration: const InputDecoration(labelText: 'Nome'),
                            validator:
                                (value) => value == null || value.isEmpty ? 'Informe o nome' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(labelText: 'E-mail'),
                            keyboardType: TextInputType.emailAddress,
                            validator:
                                (value) =>
                                    value == null || value.isEmpty ? 'Informe o e-mail' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _cpfCnpjController,
                            decoration: const InputDecoration(labelText: 'CPF/CNPJ'),
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly], // só números
                            onChanged: (value) {
                              final digits = value.replaceAll(RegExp(r'\D'), '');
                              if (digits.length <= 11) {
                                // aplica máscara CPF
                                final text = cpfFormatter.maskText(digits);
                                _cpfCnpjController.value = TextEditingValue(
                                  text: text,
                                  selection: TextSelection.collapsed(offset: text.length),
                                );
                              } else {
                                // aplica máscara CNPJ
                                final text = cnpjFormatter.maskText(digits);
                                _cpfCnpjController.value = TextEditingValue(
                                  text: text,
                                  selection: TextSelection.collapsed(offset: text.length),
                                );
                              }
                            },
                            validator: (value) {
                              final digits = value?.replaceAll(RegExp(r'\D'), '') ?? '';
                              if (digits.isEmpty) return 'Informe o CPF ou CNPJ';
                              if (digits.length != 11 && digits.length != 14) {
                                return 'CPF deve ter 11 dígitos ou CNPJ 14 dígitos';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _senhaController,
                            obscureText: visivelSenha,
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              suffixIcon: IconButton(
                                icon: Icon(visivelSenha ? Icons.visibility : Icons.visibility_off),
                                onPressed: _toggleSenha,
                              ),
                            ),
                            validator:
                                (value) =>
                                    value == null || value.isEmpty ? 'Informe a senha' : null,
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child:
                                isLoading
                                    ? const Center(child: CircularProgressIndicator())
                                    : ElevatedButton(
                                      onPressed: _submitForm,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.primary,
                                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text('CADASTRAR'),
                                    ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'VOLTAR',
                              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.inversePrimary.withValues(alpha: 0.1),
              Theme.of(context).colorScheme.inversePrimary.withValues(alpha: 0.1),
            ],
          ),
        ),
        child:
            isDesktop
                ? Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Image.asset("assets/images/Grupo.png", fit: BoxFit.contain),
                      ),
                    ),
                    Expanded(child: _buildForm()),
                  ],
                )
                : SafeArea(child: _buildForm()),
      ),
    );
  }
}
