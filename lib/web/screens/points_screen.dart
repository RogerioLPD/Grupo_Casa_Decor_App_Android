import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'package:cpf_cnpj_validator/cnpj_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nucleo_casa_decor_android/mobile/models/user_details.dart';
import 'package:nucleo_casa_decor_android/shared/services/releases_controller.dart';
import 'package:nucleo_casa_decor_android/shared/services/specifier_controller.dart';
import 'package:nucleo_casa_decor_android/web/widgets/animated_card.dart';

class PointsScreen extends ConsumerStatefulWidget {
  const PointsScreen({super.key});

  @override
  ConsumerState<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends ConsumerState<PointsScreen> with TickerProviderStateMixin {
  final _documentController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late AnimationController _successAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _successScaleAnimation;
  late Animation<double> _cardSlideAnimation;

  final _specifierController = SpecifierController();
  final _releasesController = ReleasesController();

  List<Map<String, dynamic>> _results = [];
  Map<String, dynamic>? _selectedClient;
  Timer? _debounce;
  bool _isSearching = false;

  double _calculatedPoints = 0;
  double? _lastPoints; // guarda o último valor lançado para exibir no dialog
  bool _isLoading = false;
  bool _showSuccess = false;

  String? _loggedUserName; // nome do usuário logado

  @override
  void initState() {
    super.initState();

    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _successScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _successAnimationController, curve: Curves.elasticOut));

    _cardSlideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _cardAnimationController, curve: Curves.easeOutCubic));

    _cardAnimationController.forward();
    _amountController.addListener(_calculatePoints);

    _loadLoggedUserName();
  }

  Future<void> _loadLoggedUserName() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      _loggedUserName = sp.getString('user_name') ?? 'Desconhecido';
    });
  }

  @override
  void dispose() {
    _documentController.dispose();
    _amountController.dispose();
    _successAnimationController.dispose();
    _cardAnimationController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _calculatePoints() {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;
    setState(() {
      _calculatedPoints = amount / 1000.0;
    });
  }

  void _onDocumentChanged(String _) {
    _selectedClient = null;
    _results = [];
    _debounce?.cancel();

    final clean = _documentController.text.replaceAll(RegExp(r'\D'), '');
    if (clean.length < 4) {
      setState(() {});
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () {
      _searchClient();
    });
  }

  Future<void> _searchClient() async {
    final raw = _documentController.text.trim();
    final cpfOuCnpj = raw.replaceAll(RegExp(r'\D'), '');
    if (cpfOuCnpj.isEmpty) return;

    setState(() {
      _isSearching = true;
      _results = [];
      _selectedClient = null;
    });

    try {
      final UserDetails? data = await _specifierController.getUser(cpfOuCnpj);
      List<Map<String, dynamic>> parsed = [];
      if (data != null) {
        parsed = [data.toJson()];
      }

      setState(() {
        _results = parsed;
        if (_results.length == 1) {
          _selectedClient = _results.first;
        }
      });

      if (_results.isEmpty) {
        _showError('Cliente não encontrado. Verifique o CPF ou CNPJ.');
      }
    } catch (e) {
      _showError('Erro ao buscar cliente. Verifique o CPF/CNPJ e tente novamente.');
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccessDialog(double points) {
    setState(() {
      _lastPoints = points;
      _showSuccess = true;
    });
    _successAnimationController.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _successAnimationController.reverse();
        setState(() {
          _showSuccess = false;
        });
      }
    });
  }

  Future<void> _processTransaction() async {
    if (!_formKey.currentState!.validate() || _selectedClient == null) return;

    setState(() => _isLoading = true);

    try {
      final amount = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;
      final points = double.parse((_calculatedPoints).toStringAsFixed(2));

      final especificadorId = _selectedClient!['id'] as int;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      int empresaId = 0;

      if (token != null) {
        var url = Uri.parse('https://apicasadecor.com/api/usuario/1');
        var response = await http.get(
          url,
          headers: {'Authorization': token, 'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          var userData = jsonDecode(response.body);
          empresaId = userData['id'] ?? 0;
        } else {
          _showError('Não foi possível obter o usuário logado.');
          return;
        }
      }

      print(
        'Enviando transação: { valor informado: $amount, pontos calculados: $points, empresa: $empresaId, especificador: $especificadorId }',
      );

      final ok = await _releasesController.doRelease(
        valor: points.toString(),
        empresa: empresaId,
        especificador: especificadorId,
      );

      if (ok) {
        _showSuccessDialog(points);

        _documentController.clear();
        _amountController.clear();
        setState(() {
          _selectedClient = null;
          _results = [];
          _calculatedPoints = 0;
        });
      } else {
        _showError('Erro ao processar a transação. Tente novamente.');
      }
    } catch (e) {
      _showError('Erro ao processar a transação: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 32 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme, isDesktop),
              const SizedBox(height: 32),
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildTransactionForm(theme, isDesktop)),
                    const SizedBox(width: 32),
                    Expanded(child: _buildSidebar(theme, isDesktop)),
                  ],
                )
              else
                Column(
                  children: [
                    _buildTransactionForm(theme, isDesktop),
                    const SizedBox(height: 24),
                    _buildSidebar(theme, isDesktop),
                  ],
                ),
            ],
          ),
        ),
        if (_showSuccess && _lastPoints != null)
          AnimatedBuilder(
            animation: _successScaleAnimation,
            builder: (context, child) {
              return Container(
                color: Colors.black54,
                child: Center(
                  child: Transform.scale(
                    scale: _successScaleAnimation.value,
                    child: Container(
                      margin: const EdgeInsets.all(32),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 64, color: Colors.green),
                          const SizedBox(height: 16),
                          Text(
                            '🎉 Pontos Lançados!',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_lastPoints!.toStringAsFixed(2)} pontos adicionados com sucesso!',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDesktop) {
    return AnimatedBuilder(
      animation: _cardSlideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _cardSlideAnimation.value)),
          child: Opacity(
            opacity: _cardSlideAnimation.value,
            child: GradientCard(
              gradientColors: [
                theme.colorScheme.secondary,
                theme.colorScheme.secondary.withValues(alpha: 0.8),
              ],
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '💳 Lançamento de Pontos',
                          style: (isDesktop
                                  ? theme.textTheme.headlineMedium
                                  : theme.textTheme.titleLarge)
                              ?.copyWith(
                                color: theme.colorScheme.onSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Registre vendas e acumule pontos para seus clientes',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSecondary.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSecondary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_card_rounded,
                      size: isDesktop ? 48 : 32,
                      color: theme.colorScheme.onSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionForm(ThemeData theme, bool isDesktop) {
    return AnimatedBuilder(
      animation: _cardSlideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _cardSlideAnimation.value)),
          child: Opacity(
            opacity: _cardSlideAnimation.value,
            child: AnimatedCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📋 Dados da Transação',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Document Field
                    TextFormField(
                      controller: _documentController,
                      decoration: InputDecoration(
                        labelText: 'CPF ou CNPJ do Cliente',
                        hintText: 'Digite o CPF ou CNPJ',
                        prefixIcon: const Icon(Icons.badge_rounded),
                        suffixIcon: IconButton(
                          icon:
                              _isSearching
                                  ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                  : const Icon(Icons.search_rounded),
                          onPressed: _isSearching ? null : _searchClient,
                          tooltip: 'Buscar cliente',
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _DocumentFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Campo obrigatório';

                        final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');

                        if (cleanValue.length == 11) {
                          // Para teste, aceita qualquer CPF
                          // if (!CPFValidator.isValid(cleanValue)) return 'CPF inválido';
                        } else if (cleanValue.length == 14) {
                          // Para teste, aceita qualquer CNPJ
                          // if (!CNPJValidator.isValid(cleanValue)) return 'CNPJ inválido';
                        } else {
                          return 'CPF ou CNPJ inválido';
                        }

                        return null;
                      },

                      // ====== Validator atualizado ======
                      /*validator: (value) {
                        if (value == null || value.isEmpty) return 'Campo obrigatório';

                        // limpa caracteres não numéricos
                        final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');

                        if (cleanValue.length == 11) {
                          if (!CPFValidator.isValid(cleanValue)) return 'CPF inválido';
                        } else if (cleanValue.length == 14) {
                          if (!CNPJValidator.isValid(cleanValue)) return 'CNPJ inválido';
                        } else {
                          return 'CPF ou CNPJ inválido';
                        }
                        return null;
                      },*/
                      onChanged: _onDocumentChanged,
                    ),

                    const SizedBox(height: 8),

                    // ====== NOVO: lista de resultados da busca ======
                    if (_results.isNotEmpty && _selectedClient == null)
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
                        ),
                        child: ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _results.length,
                          separatorBuilder:
                              (_, __) =>
                                  Divider(height: 1, color: theme.dividerColor.withOpacity(0.2)),
                          itemBuilder: (_, i) {
                            final u = _results[i];
                            final nome = (u['nome'] ?? '').toString();
                            final cpf = (u['cpf'] ?? '').toString();
                            final cnpj = (u['cnpj'] ?? '').toString();

                            return ListTile(
                              leading: const Icon(Icons.person),
                              title: Text(nome.isEmpty ? '(Sem nome)' : nome),
                              subtitle: Text(
                                cpf.isNotEmpty
                                    ? 'CPF: $cpf'
                                    : (cnpj.isNotEmpty ? 'CNPJ: $cnpj' : '-'),
                              ),
                              // ====== Ajuste ao preencher o campo com o cliente selecionado ======
                              trailing: IconButton(
                                icon: const Icon(Icons.check_circle_outline),
                                onPressed: () {
                                  setState(() {
                                    _selectedClient = u;
                                    // preenche o campo com doc limpo (apenas números)
                                    final docToFill = cpf.isNotEmpty ? cpf : cnpj;
                                    if (docToFill.isNotEmpty) {
                                      _documentController.text = docToFill.replaceAll(
                                        RegExp(r'[^\d]'),
                                        '',
                                      );
                                    }
                                    _results = [];
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Client Info
                    if (_selectedClient != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person_rounded, color: Colors.green),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (_selectedClient!['nome'] ?? '').toString(),
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green,
                                    ),
                                  ),
                                  if ((_selectedClient!['email'] ?? '').toString().isNotEmpty)
                                    Text(
                                      (_selectedClient!['email'] ?? '').toString(),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.green.withValues(alpha: 0.8),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (_selectedClient != null) const SizedBox(height: 16),

                    // Amount Field
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Valor da Venda (R\$)',
                        hintText: '0,00',
                        prefixIcon: const Icon(Icons.attach_money_rounded),
                        prefixText: 'R\$ ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo obrigatório';
                        }
                        final amount = double.tryParse(value.replaceAll(',', '.'));
                        if (amount == null || amount <= 0) {
                          return 'Valor inválido';
                        }
                        if (amount < 10) {
                          return 'Valor mínimo R\$ 10,00';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed:
                            _isLoading || _selectedClient == null ? null : _processTransaction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.add_rounded),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Lançar Pontos',
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.onPrimary,
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
        );
      },
    );
  }

  Widget _buildSidebar(ThemeData theme, bool isDesktop) {
    return Column(
      children: [
        // Points Calculator
        AnimatedBuilder(
          animation: _cardSlideAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 70 * (1 - _cardSlideAnimation.value)),
              child: Opacity(
                opacity: _cardSlideAnimation.value,
                child: AnimatedCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.calculate_rounded, color: theme.colorScheme.primary),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Calculadora de Pontos',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withValues(alpha: 0.1),
                              theme.colorScheme.primary.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _calculatedPoints.toStringAsFixed(2),
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            Text(
                              _calculatedPoints == 1 ? 'ponto' : 'pontos',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // Conversion Info
        AnimatedBuilder(
          animation: _cardSlideAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 90 * (1 - _cardSlideAnimation.value)),
              child: Opacity(
                opacity: _cardSlideAnimation.value,
                child: AnimatedCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.info_outline_rounded,
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Como Funciona',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoItem(
                        icon: Icons.monetization_on_rounded,
                        title: 'Conversão',
                        subtitle: 'R\$ 1.000 = 1 ponto',
                        theme: theme,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoItem(
                        icon: Icons.card_giftcard_rounded,
                        title: 'Prêmios',
                        subtitle: 'Troque pontos por prêmios',
                        theme: theme,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoItem(
                        icon: Icons.trending_up_rounded,
                        title: 'Sem Limite',
                        subtitle: 'Acumule quantos pontos quiser',
                        theme: theme,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ====== Formatter atualizado para exibir máscara apenas ======
class _DocumentFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    String formatted = digits;

    if (digits.length <= 11) {
      // CPF
      if (digits.length > 3) formatted = '${digits.substring(0, 3)}.${digits.substring(3)}';
      if (digits.length > 6) formatted = '${formatted.substring(0, 7)}.${formatted.substring(7)}';
      if (digits.length > 9) formatted = '${formatted.substring(0, 11)}-${formatted.substring(11)}';
    } else {
      // CNPJ
      if (digits.length > 2) formatted = '${digits.substring(0, 2)}.${digits.substring(2)}';
      if (digits.length > 5) formatted = '${formatted.substring(0, 6)}.${formatted.substring(6)}';
      if (digits.length > 8) formatted = '${formatted.substring(0, 10)}/${formatted.substring(10)}';
      if (digits.length > 12)
        formatted = '${formatted.substring(0, 15)}-${formatted.substring(15)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
