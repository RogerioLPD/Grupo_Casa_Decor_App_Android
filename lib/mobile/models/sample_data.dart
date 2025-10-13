import '../models/company.dart';
import '../models/transaction.dart';
import '../models/user_score.dart';

class SampleData {
  static const userScore = UserScore(
    totalPoints: 2750,
    userName: 'João Silva',
    userLevel: 'Gold',
  );

  static final List<PointTransaction> transactions = [
    PointTransaction(
      id: '1',
      description: 'Compra no McDonald\'s',
      points: 150,
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: TransactionType.earned,
      companyName: 'McDonald\'s',
      valor: 0,
    ),
    PointTransaction(
      id: '2',
      description: 'Resgate de desconto',
      points: -100,
      date: DateTime.now().subtract(const Duration(days: 2)),
      type: TransactionType.spent,
      companyName: 'Nike',
      valor: 0,
    ),
    PointTransaction(
      id: '3',
      description: 'Compra na Starbucks',
      points: 200,
      date: DateTime.now().subtract(const Duration(days: 3)),
      type: TransactionType.earned,
      companyName: 'Starbucks',
      valor: 0,
    ),
    PointTransaction(
      id: '4',
      description: 'Compra na Amazon',
      points: 300,
      date: DateTime.now().subtract(const Duration(days: 5)),
      type: TransactionType.earned,
      companyName: 'Amazon',
      valor: 0,
    ),
    PointTransaction(
      id: '5',
      description: 'Resgate de produto grátis',
      points: -250,
      date: DateTime.now().subtract(const Duration(days: 7)),
      type: TransactionType.spent,
      companyName: 'Burger King',
      valor: 0,
    ),
  ];

  static const List<Company> companies = [
    Company(
      id: '1',
      name: 'McDonald\'s',
      description: 'Rede de fast food com lanches deliciosos e pontuação em todas as compras.',
      imageUrl: 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=400',
      rating: 4.2,
    ),
    Company(
      id: '2',
      name: 'Starbucks',
      description: 'Cafeteria premium com café de qualidade e programa de fidelidade exclusivo.',
      imageUrl: 'https://images.unsplash.com/photo-1521017432531-fbd92d768814?w=400',
      rating: 4.5,
    ),
    Company(
      id: '3',
      name: 'Nike',
      description: 'Marca esportiva líder mundial em calçados e roupas esportivas.',
      imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
      rating: 4.7,
    ),
    Company(
      id: '4',
      name: 'Amazon',
      description: 'Marketplace online com milhões de produtos e entrega rápida.',
      imageUrl: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=400',
      rating: 4.4,
    ),
    Company(
      id: '5',
      name: 'Burger King',
      description: 'Rede de hambúrgueres grelhados com sabor único e ofertas especiais.',
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
      rating: 4.0,
    ),
    Company(
      id: '6',
      name: 'Apple',
      description: 'Tecnologia inovadora em smartphones, tablets e computadores.',
      imageUrl: 'https://images.unsplash.com/photo-1611532736597-de2d4265fba3?w=400',
      rating: 4.8,
    ),
  ];

  /*static const List<Reward> rewards = [
    Reward(
      id: '1',
      name: 'Big Mac Grátis',
      description: 'Um delicioso Big Mac sem custo adicional.',
      requiredPoints: 500,
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
      companyName: 'McDonald\'s',
    ),
    Reward(
      id: '2',
      name: '20% de Desconto',
      description: 'Desconto de 20% em qualquer produto Nike.',
      requiredPoints: 800,
      imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
      companyName: 'Nike',
    ),
    Reward(
      id: '3',
      name: 'Café Grande Grátis',
      description: 'Um café grande da sua escolha sem custo.',
      requiredPoints: 300,
      imageUrl: 'https://images.unsplash.com/photo-1521017432531-fbd92d768814?w=400',
      companyName: 'Starbucks',
    ),
    Reward(
      id: '4',
      name: 'Frete Grátis Amazon',
      description: 'Frete grátis em compras acima de R\$ 50.',
      requiredPoints: 200,
      imageUrl: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=400',
      companyName: 'Amazon',
    ),
    Reward(
      id: '5',
      name: 'Whopper Grátis',
      description: 'Um Whopper completo sem custo adicional.',
      requiredPoints: 600,
      imageUrl: 'https://images.unsplash.com/photo-1550317138-10000687a72b?w=400',
      companyName: 'Burger King',
    ),
    Reward(
      id: '6',
      name: 'AirPods com Desconto',
      description: '15% de desconto em AirPods Pro.',
      requiredPoints: 1500,
      imageUrl: 'https://images.unsplash.com/photo-1606220588913-b3aacb4d2f46?w=400',
      companyName: 'Apple',
    ),
  ];*/
}
