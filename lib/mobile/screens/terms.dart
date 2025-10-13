// Página Flutter criada a partir dos Termos e Condições em HTML original
import 'package:flutter/material.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Termos e Condições'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
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
        child: const SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Termos e Condições',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  'Estes termos e condições se aplicam ao aplicativo Grupo Casa Decor (doravante referido como "Aplicativo") para dispositivos móveis, criado por Rogério Luiz Pinheiro Dangui (doravante referido como "Prestador de Serviço") como um serviço gratuito.',
                ),
                SizedBox(height: 16),
                Text(
                  'Ao baixar ou utilizar o Aplicativo, você concorda automaticamente com os seguintes termos. É altamente recomendável que você leia e compreenda estes termos antes de usar o Aplicativo. É estritamente proibido copiar, modificar o Aplicativo ou qualquer parte dele, ou nossas marcas registradas. Qualquer tentativa de extrair o código-fonte, traduzir para outros idiomas ou criar versões derivadas não é permitida. Todos os direitos autorais, marcas registradas e direitos de propriedade intelectual continuam pertencendo ao Prestador de Serviço.',
                ),
                SizedBox(height: 16),
                Text(
                  'O Prestador de Serviço se compromete a garantir que o Aplicativo seja o mais útil e eficiente possível. Portanto, ele se reserva o direito de modificar o Aplicativo ou cobrar pelos seus serviços a qualquer momento e por qualquer motivo, sempre informando claramente qualquer cobrança.',
                ),
                SizedBox(height: 16),
                Text(
                  'O Aplicativo armazena e processa dados pessoais fornecidos por você para prestar o serviço. É sua responsabilidade manter seu dispositivo seguro e o acesso ao Aplicativo protegido. Não recomendamos fazer jailbreak ou root no dispositivo, pois isso pode comprometer a segurança e o funcionamento correto do Aplicativo.',
                ),
                SizedBox(height: 16),
                Text(
                  'Algumas funções do Aplicativo exigem conexão ativa com a internet. O Prestador de Serviço não se responsabiliza por falhas de funcionamento devido à falta de conexão ou uso de dados excedido.',
                ),
                SizedBox(height: 16),
                Text(
                  'Se estiver usando o Aplicativo fora de uma rede Wi-Fi, esteja ciente de que seu provedor de rede pode cobrar taxas adicionais. Ao utilizar o Aplicativo, você é responsável por tais cobranças, inclusive roaming. Se não for o titular da conta do dispositivo, presume-se que você tem permissão do titular.',
                ),
                SizedBox(height: 16),
                Text(
                  'É também sua responsabilidade manter seu dispositivo carregado. O Prestador de Serviço não pode ser responsabilizado se o dispositivo ficar sem bateria e o serviço não puder ser acessado.',
                ),
                SizedBox(height: 16),
                Text(
                  'O Prestador de Serviço se esforça para manter o Aplicativo atualizado e preciso, mas depende de terceiros para fornecer certas informações. Portanto, não se responsabiliza por perdas decorrentes do uso dessas funcionalidades.',
                ),
                SizedBox(height: 16),
                Text(
                  'O Aplicativo pode ser atualizado ou descontinuado a qualquer momento. Você concorda em aceitar atualizações quando oferecidas. Em caso de descontinuação, você deve parar de usar o Aplicativo e removê-lo do dispositivo.',
                ),
                SizedBox(height: 24),
                Text(
                  'Alterações nos Termos e Condições',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'O Prestador de Serviço pode atualizar estes termos periodicamente. Verifique esta página regularmente para acompanhar as mudanças.',
                ),
                SizedBox(height: 16),
                Text('Estes termos e condições são válidos a partir de 28/07/2025.'),
                SizedBox(height: 24),
                Text(
                  'Contato',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                    'Em caso de dúvidas ou sugestões, entre em contato pelo e-mail: nucleocasadecor@gmail.com.'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
