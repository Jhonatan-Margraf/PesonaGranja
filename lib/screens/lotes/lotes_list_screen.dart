import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/lote_provider.dart';
import '../../models/lote.dart';
import 'lote_form_screen.dart';
import 'lote_detail_screen.dart';
import '../statistics_screen.dart';
import '../settings_screen.dart';

class LotesListScreen extends StatefulWidget {
  const LotesListScreen({Key? key}) : super(key: key);

  @override
  State<LotesListScreen> createState() => _LotesListScreenState();
}

class _LotesListScreenState extends State<LotesListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<LoteProvider>(context, listen: false).carregarLotes(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Lotes'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green.shade700,
              ),
              child: const Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Gerenciar Lotes'),
              selected: true,
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Estatisticas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const StatisticsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuracoes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Consumer<LoteProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.lotes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum lote cadastrado',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toque no botão + para adicionar',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.lotes.length,
            itemBuilder: (context, index) {
              final lote = provider.lotes[index];
              return _buildLoteCard(context, lote);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoteFormScreen(),
            ),
          );
        },
        backgroundColor: Colors.green.shade700,
        label: const Text('Novo Lote'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLoteCard(BuildContext context, Lote lote) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final diasDesdeAlojamento = DateTime.now().difference(lote.dataAlojamento).inDays;
    final nomeLote = dateFormat.format(lote.dataAlojamento);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoteDetailScreen(lote: lote),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lote - $nomeLote',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Origem: ${lote.origem}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$diasDesdeAlojamento dias',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Alojados',
                      '${lote.quantidadeAlojada}',
                      Icons.groups,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'Atuais',
                      '${lote.animaisAtuais}',
                      Icons.pets,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'Mortalidade',
                      '${lote.mortalidade}',
                      Icons.warning_amber,
                      color: lote.mortalidade > 0 ? Colors.red : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Peso Inicial',
                      '${lote.pesoMedioInicial.toStringAsFixed(1)} kg',
                      Icons.scale,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'Peso Atual (Est.)',
                      '${lote.pesoMedioAtualEstimado.toStringAsFixed(1)} kg',
                      Icons.trending_up,
                    ),
                  ),
                ],
              ),              // Mostra peso real se disponível
              if (lote.temMedicaoReal)
                Column(
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            'Peso Atual (Real)',
                            '${lote.pesoMedioReal!.toStringAsFixed(1)} kg',
                            Icons.check_circle,
                            color: Colors.blue,
                          ),
                        ),
                        Expanded(
                          child: _buildInfoItem(
                            'GPD Real',
                            '${lote.gpdReal.toStringAsFixed(3)}',
                            Icons.speed,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),              const SizedBox(height: 8),
              Text(
                'Alojado em: ${dateFormat.format(lote.dataAlojamento)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon,
      {Color? color}) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: color ?? Colors.grey.shade600,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
