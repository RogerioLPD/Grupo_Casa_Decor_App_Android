// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:nucleo_casa_decor_android/mobile/models/company.dart';
import 'package:nucleo_casa_decor_android/shared/services/enterprise_controller.dart';
import 'package:nucleo_casa_decor_android/web/widgets/company_card.dart';

class CompaniesListView extends StatelessWidget {
  final List<Company> companies;
  final AnimationController animationController;
  final bool isLoading;
  final String? errorMessage;
  final EnterpriseController controller;

  const CompaniesListView({
    super.key,
    required this.companies,
    required this.animationController,
    required this.isLoading,
    required this.errorMessage,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    if (companies.isEmpty) {
      return const Center(child: Text("Nenhuma empresa encontrada"));
    }

    Future<void> confirmAndDelete(Company company) async {
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Excluir Empresa'),
              content: Text('Tem certeza que deseja excluir "${company.name}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Excluir'),
                ),
              ],
            ),
      );

      if (confirm == true) {
        final success = await controller.deleteCompany(company.id);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Empresa excluída com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
          await controller.fetchCompanies();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao excluir empresa'), backgroundColor: Colors.red),
          );
        }
      }
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: companies.length,
      itemBuilder: (context, index) {
        final company = companies[index];
        final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animationController,
            curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
          ),
        );

        return AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - animation.value)),
              child: Opacity(
                opacity: animation.value,
                child: CompanyCardDelete(
                  company: company,
                  controller: controller,
                  onDelete: () => confirmAndDelete(company),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
