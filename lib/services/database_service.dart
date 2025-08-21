import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transacao.dart';
import '../models/categoria.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Referência para a coleção de usuários
  CollectionReference get usersCollection => _db.collection('users');

  // Referência para transações do usuário atual
  CollectionReference? get transacoesCollection {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      return _db.collection('users').doc(userId).collection('transacoes');
    }
    return null;
  }

  // Referência para categorias do usuário atual
  CollectionReference? get categoriasCollection {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      return _db.collection('users').doc(userId).collection('categorias');
    }
    return null;
  }

  // CRUD para Transações

  /// Adiciona uma nova transação
  Future<String?> adicionarTransacao(Transacao transacao) async {
    try {
      if (transacoesCollection == null)
        throw Exception('Usuário não autenticado');

      DocumentReference docRef = await transacoesCollection!.add(
        transacao.toMap(),
      );
      return docRef.id;
    } catch (e) {
      print('Erro ao adicionar transação: $e');
      return null;
    }
  }

  /// Busca todas as transações do usuário
  Stream<List<Transacao>> obterTransacoes() {
    if (transacoesCollection == null) {
      return Stream.value([]);
    }

    return transacoesCollection!
        .orderBy('data', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Transacao.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  /// Busca transações por período
  Stream<List<Transacao>> obterTransacoesPorPeriodo(
    DateTime inicio,
    DateTime fim,
  ) {
    if (transacoesCollection == null) {
      return Stream.value([]);
    }

    return transacoesCollection!
        .where('data', isGreaterThanOrEqualTo: inicio.toIso8601String())
        .where('data', isLessThanOrEqualTo: fim.toIso8601String())
        .orderBy('data', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Transacao.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  /// Busca transações por categoria
  Stream<List<Transacao>> obterTransacoesPorCategoria(String categoria) {
    if (transacoesCollection == null) {
      return Stream.value([]);
    }

    return transacoesCollection!
        .where('categoria', isEqualTo: categoria)
        .orderBy('data', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Transacao.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  /// Atualiza uma transação
  Future<bool> atualizarTransacao(String id, Transacao transacao) async {
    try {
      if (transacoesCollection == null)
        throw Exception('Usuário não autenticado');

      await transacoesCollection!.doc(id).update(transacao.toMap());
      return true;
    } catch (e) {
      print('Erro ao atualizar transação: $e');
      return false;
    }
  }

  /// Deleta uma transação
  Future<bool> deletarTransacao(String id) async {
    try {
      if (transacoesCollection == null)
        throw Exception('Usuário não autenticado');

      await transacoesCollection!.doc(id).delete();
      return true;
    } catch (e) {
      print('Erro ao deletar transação: $e');
      return false;
    }
  }

  // CRUD para Categorias

  /// Adiciona uma nova categoria
  Future<String?> adicionarCategoria(Categoria categoria) async {
    try {
      if (categoriasCollection == null)
        throw Exception('Usuário não autenticado');

      DocumentReference docRef = await categoriasCollection!.add(
        categoria.toMap(),
      );
      return docRef.id;
    } catch (e) {
      print('Erro ao adicionar categoria: $e');
      return null;
    }
  }

  /// Busca todas as categorias do usuário
  Stream<List<Categoria>> obterCategorias() {
    if (categoriasCollection == null) {
      return Stream.value([]);
    }

    return categoriasCollection!.orderBy('nome').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Categoria.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  /// Atualiza uma categoria
  Future<bool> atualizarCategoria(String id, Categoria categoria) async {
    try {
      if (categoriasCollection == null)
        throw Exception('Usuário não autenticado');

      await categoriasCollection!.doc(id).update(categoria.toMap());
      return true;
    } catch (e) {
      print('Erro ao atualizar categoria: $e');
      return false;
    }
  }

  /// Deleta uma categoria
  Future<bool> deletarCategoria(String id) async {
    try {
      if (categoriasCollection == null)
        throw Exception('Usuário não autenticado');

      await categoriasCollection!.doc(id).delete();
      return true;
    } catch (e) {
      print('Erro ao deletar categoria: $e');
      return false;
    }
  }

  // Métodos de agregação para relatórios

  /// Calcula o total de receitas no período
  Future<double> calcularTotalReceitas(DateTime inicio, DateTime fim) async {
    try {
      if (transacoesCollection == null) return 0.0;

      QuerySnapshot snapshot = await transacoesCollection!
          .where('tipo', isEqualTo: 'receita')
          .where('data', isGreaterThanOrEqualTo: inicio.toIso8601String())
          .where('data', isLessThanOrEqualTo: fim.toIso8601String())
          .get();

      double total = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['valor'] as num).toDouble();
      }
      return total;
    } catch (e) {
      print('Erro ao calcular receitas: $e');
      return 0.0;
    }
  }

  /// Calcula o total de despesas no período
  Future<double> calcularTotalDespesas(DateTime inicio, DateTime fim) async {
    try {
      if (transacoesCollection == null) return 0.0;

      QuerySnapshot snapshot = await transacoesCollection!
          .where('tipo', isEqualTo: 'despesa')
          .where('data', isGreaterThanOrEqualTo: inicio.toIso8601String())
          .where('data', isLessThanOrEqualTo: fim.toIso8601String())
          .get();

      double total = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['valor'] as num).toDouble();
      }
      return total;
    } catch (e) {
      print('Erro ao calcular despesas: $e');
      return 0.0;
    }
  }

  /// Calcula despesas agrupadas por categoria
  Future<Map<String, double>> calcularDespesasPorCategoria(
    DateTime inicio,
    DateTime fim,
  ) async {
    try {
      if (transacoesCollection == null) return {};

      QuerySnapshot snapshot = await transacoesCollection!
          .where('tipo', isEqualTo: 'despesa')
          .where('data', isGreaterThanOrEqualTo: inicio.toIso8601String())
          .where('data', isLessThanOrEqualTo: fim.toIso8601String())
          .get();

      Map<String, double> despesasPorCategoria = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final categoria = data['categoria'] as String;
        final valor = (data['valor'] as num).toDouble();

        despesasPorCategoria[categoria] =
            (despesasPorCategoria[categoria] ?? 0.0) + valor;
      }

      return despesasPorCategoria;
    } catch (e) {
      print('Erro ao calcular despesas por categoria: $e');
      return {};
    }
  }

  // Configuração inicial do usuário

  /// Cria categorias padrão para um novo usuário
  Future<void> criarCategoriasIniciais() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final categoriasIniciais = [
      Categoria(
        nome: 'Educação',
        icone: 'school',
        cor: 'blue',
        usuarioId: userId,
      ),
      Categoria(nome: 'Casa', icone: 'home', cor: 'orange', usuarioId: userId),
      Categoria(
        nome: 'Alimentação',
        icone: 'fastfood',
        cor: 'green',
        usuarioId: userId,
      ),
      Categoria(nome: 'Lazer', icone: 'pool', cor: 'grey', usuarioId: userId),
      Categoria(
        nome: 'Streaming',
        icone: 'tv_sharp',
        cor: 'blue',
        usuarioId: userId,
      ),
      Categoria(
        nome: 'Transporte',
        icone: 'directions_car',
        cor: 'red',
        usuarioId: userId,
      ),
      Categoria(
        nome: 'Saúde',
        icone: 'health_and_safety',
        cor: 'purple',
        usuarioId: userId,
      ),
      Categoria(
        nome: 'Salário',
        icone: 'attach_money',
        cor: 'green',
        usuarioId: userId,
      ),
    ];

    try {
      for (var categoria in categoriasIniciais) {
        await adicionarCategoria(categoria);
      }
    } catch (e) {
      print('Erro ao criar categorias iniciais: $e');
    }
  }

  /// Limpa todas as transações do usuário
  Future<bool> limparTodasTransacoes() async {
    try {
      if (transacoesCollection == null)
        throw Exception('Usuário não autenticado');

      QuerySnapshot snapshot = await transacoesCollection!.get();

      WriteBatch batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Erro ao limpar transações: $e');
      return false;
    }
  }
}
