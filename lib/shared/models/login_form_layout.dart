import 'package:flutter/material.dart';

class LoginLayoutResponsivo extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController senhaController;
  final VoidCallback onLoginPressed;
  final VoidCallback onToggleSenha;
  final bool isSenhaVisivel;

  final VoidCallback onVoltar;
  final List<Widget>? extraFields;

  const LoginLayoutResponsivo({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.senhaController,
    required this.onLoginPressed,
    required this.onToggleSenha,
    required this.isSenhaVisivel,
    required this.onVoltar,
    this.extraFields,
  });

  @override
  State<LoginLayoutResponsivo> createState() => _LoginLayoutResponsivoState();
}

class _LoginLayoutResponsivoState extends State<LoginLayoutResponsivo>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

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

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            //Theme.of(context).colorScheme.secondaryContainer,
            Theme.of(context).colorScheme.inversePrimary.withAlpha(25),
            Theme.of(context).colorScheme.inversePrimary.withAlpha(25),
          ],
        ),
      ),
      // Imagem por cima do gradiente
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Image.asset(
                "assets/images/Grupo.png",
                fit: BoxFit.contain,
                // width: 300, // opcional
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.transparent, // pra deixar o gradiente visível atrás
              child: _buildForm(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.inversePrimary.withAlpha(25),
            Theme.of(context).colorScheme.inversePrimary.withAlpha(25),
          ],
        ),
      ),
      child: SafeArea(
        child: _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  key: widget.formKey,
                  child: Stack(
                    children: [
                      // Imagem de fundo
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

                      // Conteúdo do card
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Colors.white.withAlpha(25),
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 80),
                              Text(
                                '',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                              ),
                              const SizedBox(height: 32),
                              ...?widget.extraFields,
                              TextFormField(
                                controller: widget.emailController,
                                cursorColor: Theme.of(context).colorScheme.onSurface,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  hintText: 'Digite seu email',
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  hintStyle: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  labelStyle: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Digite seu e-mail';
                                  } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return 'Digite um e-mail válido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: widget.senhaController,
                                obscureText: !widget.isSenhaVisivel,
                                cursorColor: Theme.of(context).colorScheme.onSurface,
                                decoration: InputDecoration(
                                  labelText: 'Senha',
                                  hintText: 'Digite sua senha',
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      widget.isSenhaVisivel
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: widget.onToggleSenha,
                                  ),
                                  labelStyle: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  hintStyle: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Digite sua senha';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 42),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: widget.onLoginPressed,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('ENTRAR'),
                                ),
                              ),
                              const SizedBox(height: 24),
                              /*TextButton(
                                onPressed: widget.onVoltar,
                                child: const Text(
                                  'VOLTAR',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),*/
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Botão "Cadastre-se" fora do Form
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
