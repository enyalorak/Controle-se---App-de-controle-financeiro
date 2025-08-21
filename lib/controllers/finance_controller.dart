import 'package:get/get.dart';
import '../models/transacao.dart';
import '../models/categoria.dart';
import '../services/database_service.dart';

class FinanceController extends GetxController {
  final DatabaseService _dbService = DatabaseService();

  // Estados observáveis
  final RxList<Transacao> transacoes = <Transacao>[].obs;
  final RxList<Categoria> categorias = <Categoria>[].obs;
  final RxDouble totalReceitas = 0.0.obs;
  final RxDouble totalDespesas = 0.0.obs;
  final RxBool isLoading = false.obs;
  final RxMap<String, double> despesasPorCategoria = <String, double>{}.obs;

  // Getters calculados
  double get saldo => totalReceitas.value - totalDespesas.value;

  List<Transacao> get ultimasTransacoes => transacoes.take(5).toList();

  @override
  void onInit() {
    super.onInit();
    inicializarDados();
  }

  /// Inicializa os dados do usuário
  Future<void> inicializarDados() async {
    isLoading.value = true;

    try {
      await carregarCategorias();
      await carregarTransacoes();
      await calcularTotaisMesAtual();
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar dados: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Carrega as categorias do usuário
  Future<void> carregarCategorias() async {
    _dbService.obterCategorias().listen((categoriasLista) {
      categorias.assignAll(categoriasLista);

      // Se não há categorias, criar as iniciais
      if (categoriasLista.isEmpty) {
        _dbService.criarCategoriasIniciais();
      }
    });
  }

  /// Carrega as transações do usuário
  Future<void> carregarTransacoes() async {
    _dbService.obterTransacoes().listen((transacoesList) {
      transacoes.assignAll(transacoesList);
    });
  }

  /// Calcula os totais para o mês atual
  Future<void> calcularTotaisMesAtual() async {
    final agora = DateTime.now();
    final inicioMes = DateTime(agora.year, agora.month, 1);
    final fimMes = DateTime(agora.year, agora.month + 1, 0, 23, 59, 59);

    try {
      final receitas = await _dbService.calcularTotalReceitas(
        inicioMes,
        fimMes,
      );
      final despesas = await _dbService.calcularTotalDespesas(
        inicioMes,
        fimMes,
      );
      final despesasCategorias = await _dbService.calcularDespesasPorCategoria(
        inicioMes,
        fimMes,
      );

      totalReceitas.value = receitas;
      totalDespesas.value = despesas;
      despesasPorCategoria.assignAll(despesasCategorias);
    } catch (e) {
      print('Erro ao calcular totais: $e');
    }
  }

  /// Adiciona uma nova transação
  Future<bool> adicionarTransacao({
    required String descricao,
    required double valor,
    required String tipo,
    required String categoria,
  }) async {
    if (descricao.trim().isEmpty || valor <= 0) {
      Get.snackbar('Erro', 'Preencha todos os campos corretamente');
      return false;
    }

    try {
      final transacao = Transacao(
        descricao: descricao,
        valor: valor,
        tipo: tipo,
        data: DateTime.now(),
        categoria: categoria,
        usuarioId: '', // Será preenchido no DatabaseService
      );

      final id = await _dbService.adicionarTransacao(transacao);

      if (id != null) {
        Get.snackbar('Sucesso', 'Transação adicionada com sucesso!');
        await calcularTotaisMesAtual(); // Recalcula os totais
        return true;
      } else {
        Get.snackbar('Erro', 'Falha ao adicionar transação');
        return false;
      }
    } catch (e) {
      Get.snackbar('Erro', 'Erro inesperado: $e');
      return false;
    }
  }

  /// Atualiza uma transação existente
  Future<bool> atualizarTransacao(String id, Transacao transacao) async {
    try {
      final sucesso = await _dbService.atualizarTransacao(id, transacao);

      if (sucesso) {
        Get.snackbar('Sucesso', 'Transação atualizada com sucesso!');
        await calcularTotaisMesAtual();
        return true;
      } else {
        Get.snackbar('Erro', 'Falha ao atualizar transação');
        return false;
      }
    } catch (e) {
      Get.snackbar('Erro', 'Erro inesperado: $e');
      return false;
    }
  }

  /// Deleta uma transação
  Future<bool> deletarTransacao(String id) async {
    try {
      final sucesso = await _dbService.deletarTransacao(id);

      if (sucesso) {
        Get.snackbar('Sucesso', 'Transação removida com sucesso!');
        await calcularTotaisMesAtual();
        return true;
      } else {
        Get.snackbar('Erro', 'Falha ao remover transação');
        return false;
      }
    } catch (e) {
      Get.snackbar('Erro', 'Erro inesperado: $e');
      return false;
    }
  }

  /// Adiciona uma nova categoria
  Future<bool> adicionarCategoria({
    required String nome,
    required String icone,
    required String cor,
  }) async {
    if (nome.trim().isEmpty) {
      Get.snackbar('Erro', 'Nome da categoria não pode estar vazio');
      return false;
    }

    try {
      final categoria = Categoria(
        nome: nome,
        icone: icone,
        cor: cor,
        usuarioId: '', // Será preenchido no DatabaseService
      );

      final id = await _dbService.adicionarCategoria(categoria);

      if (id != null) {
        Get.snackbar('Sucesso', 'Categoria adicionada com sucesso!');
        return true;
      } else {
        Get.snackbar('Erro', 'Falha ao adicionar categoria');
        return false;
      }
    } catch (e) {
      Get.snackbar('Erro', 'Erro inesperado: $e');
      return false;
    }
  }

  /// Limpa todas as transações
  Future<void> limparTodasTransacoes() async {
    try {
      final sucesso = await _dbService.limparTodasTransacoes();

      if (sucesso) {
        totalReceitas.value = 0.0;
        totalDespesas.value = 0.0;
        despesasPorCategoria.clear();
        Get.snackbar('Sucesso', 'Todas as transações foram removidas');
      } else {
        Get.snackbar('Erro', 'Falha ao limpar transações');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Erro inesperado: $e');
    }
  }

  /// Filtra transações por período
  Future<void> filtrarTransacoesPorPeriodo(
    DateTime inicio,
    DateTime fim,
  ) async {
    _dbService.obterTransacoesPorPeriodo(inicio, fim).listen((transacoesList) {
      transacoes.assignAll(transacoesList);
    });
  }

  /// Filtra transações por categoria
  Future<void> filtrarTransacoesPorCategoria(String categoria) async {
    _dbService.obterTransacoesPorCategoria(categoria).listen((transacoesList) {
      transacoes.assignAll(transacoesList);
    });
  }

  /// Recarrega todos os dados
  Future<void> recarregarDados() async {
    await inicializarDados();
  }

  /// Obtém categoria por nome
  Categoria? obterCategoriaPorNome(String nome) {
    try {
      return categorias.firstWhere((categoria) => categoria.nome == nome);
    } catch (e) {
      return null;
    }
  }

  /// Valida se uma categoria existe
  bool categoriaExiste(String nome) {
    return categorias.any(
      (categoria) => categoria.nome.toLowerCase() == nome.toLowerCase(),
    );
  }

  /// Obtém estatísticas do mês
  Map<String, dynamic> obterEstatisticasMes() {
    return {
      'totalReceitas': totalReceitas.value,
      'totalDespesas': totalDespesas.value,
      'saldo': saldo,
      'numeroTransacoes': transacoes.length,
      'despesasPorCategoria': despesasPorCategoria,
    };
  }
}
