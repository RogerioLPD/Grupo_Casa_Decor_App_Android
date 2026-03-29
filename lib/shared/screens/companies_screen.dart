// companies_screen.dart
import 'package:flutter/material.dart';
import 'package:nucleo_casa_decor_android/mobile/models/company.dart';
import 'package:nucleo_casa_decor_android/shared/services/enterprise_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'dart:io'; // Platform

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({super.key});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();

  final EnterpriseController _enterpriseController = EnterpriseController();

  List<Company> _allCompanies = [];
  List<Company> _filteredCompanies = [];
  String? _selectedCity;
  List<String> _cities = [];

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();

    // Stream de empresas
    _enterpriseController.companyStream.listen((companies) {
      setState(() {
        _allCompanies = companies;
        _filteredCompanies = companies;

        _cities = companies.map((c) => c.city ?? '').where((c) => c.isNotEmpty).toSet().toList();

        _cities.sort();
      });
    });

    // Stream de loading
    _enterpriseController.loadingStream.listen((loading) {
      setState(() {
        _isLoading = loading;
      });
    });

    // Stream de erro
    _enterpriseController.errorStream.listen((error) {
      setState(() {
        _errorMessage = error;
      });
    });

    // Buscar dados da API
    _enterpriseController.fetchCompanies();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _enterpriseController.dispose();
    super.dispose();
  }

  void _filterCompanies(String query) {
    setState(() {
      _filteredCompanies =
          _allCompanies.where((company) {
            final name = company.name.toLowerCase();
            final desc = company.description.toLowerCase();
            final city = (company.city ?? '').toLowerCase();

            final matchesSearch =
                name.contains(query.toLowerCase()) || desc.contains(query.toLowerCase());

            final matchesCity =
                _selectedCity == null || _selectedCity!.isEmpty
                    ? true
                    : city == _selectedCity!.toLowerCase();

            return matchesSearch && matchesCity;
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Empresas Parceiras',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterCompanies,
              decoration: InputDecoration(
                hintText: 'Buscar empresas...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedCity,
              hint: const Text("Filtrar por cidade"),
              items: [
                const DropdownMenuItem<String>(value: null, child: Text("Todas as cidades")),
                ..._cities.map((city) {
                  return DropdownMenuItem<String>(value: city, child: Text(city));
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCity = value;
                });
                _filterCompanies(_searchController.text);
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 8),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : _filteredCompanies.isEmpty
                    ? const Center(child: Text("Nenhuma empresa encontrada"))
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredCompanies.length,
                      itemBuilder: (context, index) {
                        final company = _filteredCompanies[index];
                        return AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            final animationValue = Tween<double>(begin: 0.0, end: 1.0).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
                              ),
                            );

                            return Transform.translate(
                              offset: Offset(0, 30 * (1 - animationValue.value)),
                              child: Opacity(
                                opacity: animationValue.value,
                                child: CompanyCard(company: company),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
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
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) {
                final theme = Theme.of(context);

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🔥 Barra de arrastar
                      Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      // 🔥 Imagem
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          company.imageUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Container(
                                height: 180,
                                color: Colors.grey[300],
                                child: const Icon(Icons.business, size: 60),
                              ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 🔥 Nome + rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              company.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 18),
                              const SizedBox(width: 4),
                              Text(company.rating.toString()),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // 🔥 Endereço
                      if (company.address != null && company.address!.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on, size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(company.address!)),
                          ],
                        ),

                      const SizedBox(height: 20),

                      // 🔥 Botões
                      Row(
                        children: [
                          // 📞 Ligar
                          if (company.phone != null && company.phone!.isNotEmpty)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final uri = Uri.parse("tel:${company.phone}");
                                  await launchUrl(uri);
                                },
                                icon: const Icon(Icons.phone),
                                label: const Text("Ligar"),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(width: 12),

                          // 📍 Maps
                          if (company.address != null && company.address!.isNotEmpty)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final query = Uri.encodeComponent(company.address!);

                                  final webUrl = Uri.parse(
                                    "https://www.google.com/maps/search/?api=1&query=$query",
                                  );

                                  try {
                                    if (kIsWeb) {
                                      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
                                      return;
                                    }

                                    if (Platform.isAndroid) {
                                      final geoUrl = Uri.parse("geo:0,0?q=$query");

                                      final success = await launchUrl(
                                        geoUrl,
                                        mode: LaunchMode.externalApplication,
                                      );

                                      if (!success) {
                                        await launchUrl(
                                          webUrl,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      }
                                      return;
                                    }

                                    if (Platform.isIOS) {
                                      final appleUrl = Uri.parse("maps:0,0?q=$query");

                                      final success = await launchUrl(
                                        appleUrl,
                                        mode: LaunchMode.externalApplication,
                                      );

                                      if (!success) {
                                        await launchUrl(
                                          webUrl,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      }
                                      return;
                                    }

                                    await launchUrl(webUrl, mode: LaunchMode.externalApplication);
                                  } catch (e) {
                                    await launchUrl(webUrl, mode: LaunchMode.externalApplication);
                                  }
                                },
                                icon: const Icon(Icons.map),
                                label: const Text("Mapa"),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest),
                  child: Image.network(
                    company.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: theme.colorScheme.surfaceContainerHighest,
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            company.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
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
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      company.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.verified, size: 16, color: theme.colorScheme.secondary),
                        const SizedBox(width: 4),
                        Text(
                          'Parceiro Verificado',
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
