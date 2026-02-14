// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nucleo_casa_decor_android/mobile/models/company.dart';
import 'package:nucleo_casa_decor_android/shared/services/administrator_controller.dart';
import 'package:nucleo_casa_decor_android/shared/services/enterprise_controller.dart';
import 'package:nucleo_casa_decor_android/web/models/company_model.dart';
import 'package:nucleo_casa_decor_android/web/widgets/company_list.dart';
import 'package:nucleo_casa_decor_android/web/widgets/responsive_layout.dart';
import 'package:http/http.dart' as http;

class CompanyRegistrationScreen extends StatefulWidget {
  const CompanyRegistrationScreen({super.key});

  @override
  State<CompanyRegistrationScreen> createState() => _CompanyRegistrationScreenState();
}

class _CompanyRegistrationScreenState extends State<CompanyRegistrationScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Controllers dos campos
  final _nameController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  late String _selectedCategory; // 🔹 inicializado no initState

  bool _isActive = true;
  bool _senhaVisivel = false;

  // Para armazenar bytes da imagem selecionada
  Uint8List? _imageBytes;

  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _categories = [
    'Aço inox e vidros',
    'Colchões',
    'Climatização',
    'Automação',
    'Elevadores',
    'Iluminação',
    'Materiais de acabamento',
    'Móveis planejados',
    'Revestimentos',
    'Construtoras',
    'Soluções em segurança',
    'Energia solar, aquecimento solar e a gas',
    'Ferragens para construção',
    'Locações de equipamentos',
    'Esquadrias e Vidros',
    'Esquadrias',
    'Piscinas',
    'Marmores, granitos e pedras',
    'Decoração',
    'Móveis soltos',
    'Móveis e Decoração',
    'Cortinas',
    'Materiais de Construção',
    'Serviços elétricos',
    'Lareiras',
    'Lajes',
    'Madereiras',
    'Materiais Elétricos',
    'Paisagismo',
    'Impermeabilização',
    'Pisos e blocos de concreto',
  ];

  final EnterpriseController _enterpriseController = EnterpriseController();
  final AdministradorController _adminController = AdministradorController();

  // Variáveis locais para armazenar empresas
  List<Company> _allCompanies = [];
  List<Company> _filteredCompanies = [];

  List<dynamic> estados = [];
  List<dynamic> cidades = [];
  String? estadoSelecionado;
  String? cidadeSelecionada;

  @override
  void initState() {
    super.initState();
    _categories.sort(
      (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
    ); // 🔥 ordena ignorando maiúsculas

    // 🔹 Inicializa categoria selecionada
    _selectedCategory = _categories.first;

    _initializeAnimations();
    _fetchEstados();
    // Escuta das streams
    _enterpriseController.companyStream.listen((companies) {
      setState(() {
        _allCompanies = companies.cast<Company>();
        _filteredCompanies = companies.cast<Company>();
        _errorMessage = null;
      });
    });

    _enterpriseController.loadingStream.listen((loading) {
      setState(() {
        _isLoading = loading;
      });
    });

    _enterpriseController.errorStream.listen((error) {
      setState(() {
        _errorMessage = error;
      });
    });

    _enterpriseController.fetchCompanies();
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

  Future<void> _fetchEstados() async {
    final response = await http.get(
      Uri.parse('https://servicodados.ibge.gov.br/api/v1/localidades/estados'),
    );
    if (response.statusCode == 200) {
      setState(() {
        estados = json.decode(response.body);
        estados.sort((a, b) => a['nome'].compareTo(b['nome'])); // Ordena
      });
    }
  }

  Future<void> _fetchCidades(String uf) async {
    final response = await http.get(
      Uri.parse('https://servicodados.ibge.gov.br/api/v1/localidades/estados/$uf/municipios'),
    );
    if (response.statusCode == 200) {
      setState(() {
        cidades = json.decode(response.body);
        cidades.sort((a, b) => a['nome'].compareTo(b['nome']));
      });
    }
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
      log('Unsupported operation: $e');
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _cnpjController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();

    _enterpriseController.dispose();
    super.dispose();
  }

  void _filterCompanies(String query) {
    setState(() {
      _filteredCompanies =
          _allCompanies.where((company) {
            final name = company.name.toLowerCase();
            final desc = (company.description).toLowerCase();
            return name.contains(query.toLowerCase()) || desc.contains(query.toLowerCase());
          }).toList();
    });
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
                  final isSmallScreen = context.isMobile;

                  return isSmallScreen ? _buildMobileLayout() : _buildDesktopLayout();
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildRegistrationForm(),
          const SizedBox(height: 32),
          _buildSearchField(),
          const SizedBox(height: 16),
          CompaniesListView(
            companies: _filteredCompanies,
            animationController: _animationController,
            isLoading: _isLoading,
            errorMessage: _errorMessage,
            controller: _enterpriseController,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Formulário com altura máxima e scroll interno
              Expanded(
                flex: 2,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 800),
                  child: SingleChildScrollView(child: _buildRegistrationForm()),
                ),
              ),
              const SizedBox(width: 32),
              // Lista com rolagem própria
              Expanded(
                flex: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchField(),
                      const SizedBox(height: 16),
                      // Scroll individual aqui
                      Expanded(
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: ListView(
                            children: [
                              CompaniesListView(
                                companies: _filteredCompanies,
                                animationController: _animationController,
                                isLoading: _isLoading,
                                errorMessage: _errorMessage,
                                controller: _enterpriseController,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Buscar empresas...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onChanged: _filterCompanies,
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cadastro de Empresas',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Gerencie as empresas parceiras do programa de pontuação',
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
              'Nova Empresa',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),

            // Campo Nome
            _buildTextField(
              controller: _nameController,
              label: 'Nome da Empresa',
              icon: Icons.business_rounded,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Nome é obrigatório';
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Campo CNPJ
            _buildTextField(
              controller: _cnpjController,
              label: 'CNPJ',
              icon: Icons.assignment_ind_rounded,
              validator: (value) {
                if (value == null || value.isEmpty) return 'CNPJ é obrigatório';
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Campo Email
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Email é obrigatório';
                if (!value.contains('@')) return 'Email inválido';
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Campo Senha
            _buildTextField(
              controller: _passwordController,
              label: 'Senha',
              icon: Icons.lock_rounded,
              isPassword: true, // 🔹 ativa o botão de mostrar/ocultar
              validator: (value) {
                if (value == null || value.isEmpty) return 'Senha é obrigatória';
                if (value.length < 6) return 'Senha deve ter ao menos 6 caracteres';
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Campo Telefone
            _buildTextField(
              controller: _phoneController,
              label: 'Telefone',
              icon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 16),

            // Campo Endereço
            _buildTextField(
              controller: _addressController,
              label: 'Endereço',
              icon: Icons.location_on_rounded,
            ),

            const SizedBox(height: 16),

            // Linha com Cidade e Estado usando Dropdown
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: isWide ? (constraints.maxWidth / 2) - 8 : double.infinity,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Cidade',
                          prefixIcon: const Icon(Icons.location_city_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                        ),
                        value: cidadeSelecionada,
                        items:
                            cidades.map<DropdownMenuItem<String>>((cidade) {
                              return DropdownMenuItem<String>(
                                value: cidade['nome'],
                                child: Text(cidade['nome'], overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            cidadeSelecionada = value;
                            _cityController.text = value ?? '';
                          });
                        },
                      ),
                    ),

                    SizedBox(
                      width: isWide ? (constraints.maxWidth / 2) - 8 : double.infinity,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Estado',
                          prefixIcon: const Icon(Icons.map_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                        ),
                        value: estadoSelecionado,
                        items:
                            estados.map<DropdownMenuItem<String>>((estado) {
                              return DropdownMenuItem<String>(
                                value: estado['sigla'],
                                child: Text(estado['nome'], overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            estadoSelecionado = value;
                            _stateController.text = value ?? '';
                            cidadeSelecionada = null;
                            cidades.clear();
                          });
                          if (value != null) {
                            _fetchCidades(value);
                          }
                        },
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            _buildCategoryDropdown(),

            const SizedBox(height: 16),

            _buildActiveSwitch(),

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
    bool obscureText = false,
    bool isPassword = false, // 🔹 novo parâmetro
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword ? !_senhaVisivel : obscureText, // 🔹 controla visibilidade
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon:
            isPassword
                ? IconButton(
                  icon: Icon(_senhaVisivel ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _senhaVisivel = !_senhaVisivel;
                    });
                  },
                )
                : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Categoria',
        prefixIcon: const Icon(Icons.category_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      items:
          _categories.map((category) {
            return DropdownMenuItem(value: category, child: Text(category));
          }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value!;
        });
      },
    );
  }

  Widget _buildActiveSwitch() {
    final theme = Theme.of(context);

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 8,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.toggle_on_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text('Empresa Ativa', style: theme.textTheme.bodyLarge),
          ],
        ),
        Switch(
          value: _isActive,
          onChanged: (value) {
            setState(() {
              _isActive = value;
            });
          },
        ),
      ],
    );
  }

  // Widget para selecionar a imagem da empresa
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
                    'Clique para selecionar a imagem da empresa',
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
                : const Text('Cadastrar Empresa'),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma imagem da empresa.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool success = await _adminController.createEnterprise(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      cpf: _cnpjController.text,
      seguimento: _selectedCategory,
      telefone: _phoneController.text,
      celular: '', // pode ajustar se quiser um campo para celular
      endereco: _addressController.text,
      numero: '', // não está na UI, pode deixar vazio
      bairro: '', // idem
      cidade: _cityController.text,
      estado: _stateController.text,
      bytes: _imageBytes,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      final newCompany = CompanyModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        cnpj: _cnpjController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        city: _cityController.text,
        state: _stateController.text,
        category: _selectedCategory,
        isActive: _isActive,
        createdAt: DateTime.now(),
      );

      await _enterpriseController.fetchCompanies(); // recarrega os dados reais
      setState(() {
        _isLoading = false;
      });

      _clearForm();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Empresa ${newCompany.name} cadastrada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Falha ao cadastrar empresa. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _cnpjController.clear();
    _emailController.clear();
    _passwordController.clear();
    _phoneController.clear();
    _addressController.clear();
    _cityController.clear();
    _stateController.clear();
    setState(() {
      _selectedCategory = _categories.first;
      _isActive = true;
      _imageBytes = null;
    });
  }
}

class CompanyCard extends StatelessWidget {
  final Company company;

  const CompanyCard({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Visualizar ${company.name}'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// IMAGEM
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: Image.network(
                    company.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.business,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      );
                    },
                  ),
                ),
              ),

              /// CONTEÚDO
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// NOME + RATING
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            company.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, size: 16, color: theme.colorScheme.secondary),
                                const SizedBox(width: 4),
                                Text(
                                  company.rating.toString(),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    /// DESCRIÇÃO
                    Text(
                      company.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// TAG VERIFICADO (AGORA À PROVA DE OVERFLOW)
                    Wrap(
                      spacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Icon(Icons.verified, size: 16, color: theme.colorScheme.secondary),
                        Text(
                          'Parceiro Verificado',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
