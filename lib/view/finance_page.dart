import 'package:controlese/controllers/finance_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/transacao.dart';

class FinanceHomePage extends StatefulWidget {
  const FinanceHomePage({super.key});

  @override
  State<FinanceHomePage> createState() => _FinanceHomePageState();
}

class _FinanceHomePageState extends State<FinanceHomePage> {
  final FinanceController financeController = Get.put(FinanceController());

  final List<String> meses = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  void _confirmarLimpar() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Limpar tudo?'),
          content: const Text(
            'Deseja apagar todas as receitas e despesas? Esta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                financeController.limparTodasTransacoes();
                Navigator.of(context).pop();
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final mesAtual = meses[now.month - 1];

    return Scaffold(
      appBar: AppBar(
        title: Text('$mesAtual - Finanças Pessoais'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => financeController.recarregarDados(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _confirmarLimpar,
          ),
          IconButton(icon: const Icon(Icons.account_circle), onPressed: () {}),
        ],
      ),
      body: Obx(() {
        if (financeController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => financeController.recarregarDados(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Saldo em contas
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Saldo em contas',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'R\$${financeController.saldo.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: financeController.saldo >= 0
                                ? Colors.green[700]
                                : Colors.red[700],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Receitas',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  'R\$${financeController.totalReceitas.value.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Despesas',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  'R\$${financeController.totalDespesas.value.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.red[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Despesas por categoria
                const Text(
                  'Despesas por categoria',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 100,
                  child: financeController.categorias.isNotEmpty
                      ? ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: financeController.categorias.length,
                          itemBuilder: (context, index) {
                            final categoria =
                                financeController.categorias[index];
                            final valor =
                                financeController.despesasPorCategoria[categoria
                                    .nome] ??
                                0.0;

                            return _buildCategoryItem(
                              _getIconData(categoria.icone),
                              categoria.nome,
                              _getColor(categoria.cor),
                              valor,
                            );
                          },
                        )
                      : const Center(
                          child: Text('Nenhuma categoria encontrada'),
                        ),
                ),

                const SizedBox(height: 20),

                // Cartões de crédito (placeholder - você pode implementar depois)
                const Text(
                  'Cartões de crédito',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        const ListTile(
                          title: Text('Nubank'),
                          subtitle: Text('Vence amanhã'),
                          trailing: Text(
                            'R\$30,00',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          title: const Text('Caixa'),
                          subtitle: const Text('Vence amanhã'),
                          trailing: Text(
                            'R\$0,00',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Últimas transações
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Últimas transações',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Ver todas'),
                    ),
                  ],
                ),

                ...financeController.ultimasTransacoes
                    .map((transacao) => _buildTransactionItem(transacao))
                    .toList(),
              ],
            ),
          ),
        );
      }),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'addReceita',
            onPressed: () => _mostrarDialogo(context, 'receita'),
            label: const Text('Adicionar Receita'),
            icon: const Icon(Icons.add_circle_outline),
            backgroundColor: Colors.green,
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'addDespesa',
            onPressed: () => _mostrarDialogo(context, 'despesa'),
            label: const Text('Adicionar Despesa'),
            icon: const Icon(Icons.remove_circle_outline),
            backgroundColor: Colors.red,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: 'Cartões',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Relatórios',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Config'),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    IconData icon,
    String label,
    Color color,
    double valor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: GestureDetector(
        onTap: () {
          // Navegar para detalhes da categoria ou filtrar por categoria
          financeController.filtrarTransacoesPorCategoria(label);
        },
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.2),
                  radius: 30,
                  child: Icon(icon, color: color, size: 30),
                ),
                if (valor > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        'R\${valor.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Transacao transacao) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          transacao.tipo == 'receita'
              ? Icons.arrow_downward
              : Icons.arrow_upward,
          color: transacao.tipo == 'receita' ? Colors.green : Colors.red,
        ),
        title: Text(transacao.descricao),
        subtitle: Text(
          '${transacao.categoria} • ${_formatarData(transacao.data)}',
        ),
        trailing: Text(
          'R\${transacao.valor.toStringAsFixed(2)}',
          style: TextStyle(
            color: transacao.tipo == 'receita' ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          _mostrarOpcoesTransacao(transacao);
        },
      ),
    );
  }

  void _mostrarOpcoesTransacao(Transacao transacao) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar'),
              onTap: () {
                Navigator.pop(context);
                _mostrarDialogoEdicao(transacao);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Excluir', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmarExclusao(transacao);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancelar'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  void _confirmarExclusao(Transacao transacao) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: Text('Deseja excluir a transação "${transacao.descricao}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                financeController.deletarTransacao(transacao.id!);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Excluir',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _mostrarDialogo(BuildContext context, String tipo) async {
    final TextEditingController valorController = TextEditingController();
    final TextEditingController descricaoController = TextEditingController();
    String? categoriaSelecionada;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            tipo == 'receita' ? 'Adicionar Receita' : 'Adicionar Despesa',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: valorController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Valor (ex: 1500.00)',
                    border: OutlineInputBorder(),
                    prefixText: 'R\$ ',
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() {
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Categoria',
                      border: OutlineInputBorder(),
                    ),
                    items: financeController.categorias
                        .map(
                          (categoria) => DropdownMenuItem(
                            value: categoria.nome,
                            child: Text(categoria.nome),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      categoriaSelecionada = value;
                    },
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Adicionar'),
              onPressed: () {
                final valor = double.tryParse(
                  valorController.text.replaceAll(',', '.'),
                );
                final descricao = descricaoController.text.trim();

                if (valor != null &&
                    valor > 0 &&
                    descricao.isNotEmpty &&
                    categoriaSelecionada != null) {
                  financeController.adicionarTransacao(
                    descricao: descricao,
                    valor: valor,
                    tipo: tipo,
                    categoria: categoriaSelecionada!,
                  );
                  Navigator.of(context).pop();
                } else {
                  Get.snackbar(
                    'Erro',
                    'Preencha todos os campos corretamente',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _mostrarDialogoEdicao(Transacao transacao) async {
    final TextEditingController valorController = TextEditingController(
      text: transacao.valor.toString(),
    );
    final TextEditingController descricaoController = TextEditingController(
      text: transacao.descricao,
    );
    String categoriaSelecionada = transacao.categoria;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Transação'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: valorController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Valor',
                    border: OutlineInputBorder(),
                    prefixText: 'R\$ ',
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() {
                  return DropdownButtonFormField<String>(
                    value: categoriaSelecionada,
                    decoration: const InputDecoration(
                      labelText: 'Categoria',
                      border: OutlineInputBorder(),
                    ),
                    items: financeController.categorias
                        .map(
                          (categoria) => DropdownMenuItem(
                            value: categoria.nome,
                            child: Text(categoria.nome),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) categoriaSelecionada = value;
                    },
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Salvar'),
              onPressed: () {
                final valor = double.tryParse(
                  valorController.text.replaceAll(',', '.'),
                );
                final descricao = descricaoController.text.trim();

                if (valor != null && valor > 0 && descricao.isNotEmpty) {
                  final transacaoAtualizada = Transacao(
                    id: transacao.id,
                    descricao: descricao,
                    valor: valor,
                    tipo: transacao.tipo,
                    data: transacao.data,
                    categoria: categoriaSelecionada,
                    usuarioId: transacao.usuarioId,
                  );

                  financeController.atualizarTransacao(
                    transacao.id!,
                    transacaoAtualizada,
                  );
                  Navigator.of(context).pop();
                } else {
                  Get.snackbar(
                    'Erro',
                    'Preencha todos os campos corretamente',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'school':
        return Icons.school;
      case 'home':
        return Icons.home;
      case 'fastfood':
        return Icons.fastfood;
      case 'pool':
        return Icons.pool;
      case 'tv_sharp':
        return Icons.tv;
      case 'directions_car':
        return Icons.directions_car;
      case 'health_and_safety':
        return Icons.health_and_safety;
      case 'attach_money':
        return Icons.attach_money;
      default:
        return Icons.category;
    }
  }

  Color _getColor(String colorName) {
    switch (colorName) {
      case 'blue':
        return Colors.blue;
      case 'orange':
        return Colors.orange;
      case 'green':
        return Colors.green;
      case 'grey':
        return Colors.grey;
      case 'red':
        return Colors.red;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }
}
