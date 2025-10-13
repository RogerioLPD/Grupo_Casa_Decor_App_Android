import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primaryContainer,
              theme.colorScheme.secondary.withAlpha(204),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text('Política de Privacidade'),
                centerTitle: true,
              ),
              const Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Última atualização: 28 de julho de 2025\n',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Esta Política de Privacidade descreve como seu aplicativo coleta, usa e compartilha informações pessoais quando você o utiliza.\n',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 24),
                      Text(
                        '1. Informações Coletadas',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Coletamos as seguintes informações pessoais fornecidas voluntariamente por você:',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                          '• Nome completo\n• Endereço de e-mail\n• Número de telefone\n• Outras informações fornecidas durante o uso do app',
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 24),
                      Text(
                        '2. Uso das Informações',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Usamos suas informações para:',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '• Fornecer e manter os serviços do aplicativo\n• Entrar em contato com você\n• Melhorar sua experiência como usuário\n• Cumprir com obrigações legais',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 24),
                      Text(
                        '3. Compartilhamento de Informações',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Não compartilhamos suas informações pessoais com terceiros, exceto quando exigido por lei ou com seu consentimento explícito.',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 24),
                      Text(
                        '4. Segurança',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Adotamos medidas técnicas e organizacionais adequadas para proteger suas informações pessoais.',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 24),
                      Text(
                        '5. Seus Direitos',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Você tem o direito de acessar, corrigir ou excluir suas informações pessoais a qualquer momento.',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 24),
                      Text(
                        '6. Contato',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Se você tiver dúvidas ou preocupações sobre esta política, entre em contato conosco pelo e-mail nucleocasadecor@gmail.com.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
