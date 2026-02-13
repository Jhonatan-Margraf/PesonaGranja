import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/lote.dart';
import '../../models/baia.dart';
import '../../providers/baia_provider.dart';
import '../../providers/lote_provider.dart';
import 'baia_form_screen.dart';
import 'baia_detail_screen.dart';

class BaiasListScreen extends StatefulWidget {
  final Lote lote;

  const BaiasListScreen({Key? key, required this.lote}) : super(key: key);

  @override
  State<BaiasListScreen> createState() => _BaiasListScreenState();
}

class _BaiasListScreenState extends State<BaiasListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<BaiaProvider>(context, listen: false)
          .carregarBaiasPorLote(widget.lote.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Baias - ${DateFormat('dd/MM/yyyy').format(widget.lote.dataAlojamento)}',
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Consumer<BaiaProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.baias.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.door_front_door_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma baia cadastrada',
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

          return Column(
            children: [
              if (provider.baias.isNotEmpty) _buildSummaryCard(provider),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: provider.baias.length,
                  itemBuilder: (context, index) {
                    final baia = provider.baias[index];
                    return _buildBaiaCard(context, baia, provider);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BaiaFormScreen(loteId: widget.lote.id),
            ),
          );
        },
        backgroundColor: Colors.green.shade700,
        label: const Text('Nova Baia'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(BaiaProvider provider) {
    final totalSuinos = provider.baias.fold<int>(
      0,
      (sum, baia) => sum + baia.quantidadeSuinos,
    );
    final totalMortos = provider.baias.fold<int>(
      0,
      (sum, baia) => sum + baia.leitoeMortos,
    );
    final pesoMedio = provider.getPesoMedioBaias();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Text(
            'Resumo das Baias',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Baias', '${provider.baias.length}', Icons.door_front_door),
              _buildSummaryItem('Suínos', '$totalSuinos', Icons.pets),
              _buildSummaryItem('Mortos', '$totalMortos', Icons.warning_amber),
              if (pesoMedio != null)
                _buildSummaryItem(
                  'Peso Médio',
                  '${pesoMedio.toStringAsFixed(1)} kg',
                  Icons.scale,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.green.shade700),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
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

  Widget _buildBaiaCard(BuildContext context, Baia baia, BaiaProvider provider) {
    final pesoMedio = baia.pesoMedioAtual;
    final hasWarning = baia.leitoeMortos > 0 || baia.quantidadeSuinos == 0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: hasWarning
            ? BorderSide(color: Colors.orange.shade300, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BaiaDetailScreen(baia: baia),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: baia.sexo == SexoBaia.macho
                          ? Colors.blue.shade100
                          : Colors.pink.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          baia.sexo == SexoBaia.macho ? Icons.male : Icons.female,
                          size: 16,
                          color: baia.sexo == SexoBaia.macho
                              ? Colors.blue.shade700
                              : Colors.pink.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Baia ${baia.numero}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: baia.sexo == SexoBaia.macho
                                ? Colors.blue.shade700
                                : Colors.pink.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasWarning)
                    Icon(Icons.warning, color: Colors.orange.shade700, size: 20),
                ],
              ),
              const Spacer(),
              _buildBaiaInfo('Suínos', '${baia.quantidadeSuinos}', Icons.pets),
              if (baia.leitoeMortos > 0)
                _buildBaiaInfo(
                  'Mortos',
                  '${baia.leitoeMortos}',
                  Icons.warning_amber,
                  Colors.red,
                ),
              if (pesoMedio != null)
                _buildBaiaInfo(
                  'Peso Médio',
                  '${pesoMedio.toStringAsFixed(1)} kg',
                  Icons.scale,
                  Colors.green,
                )
              else
                _buildBaiaInfo(
                  'Peso',
                  'Não medido',
                  Icons.scale,
                  Colors.grey,
                ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await provider.reverterMorte(baia.id);
                        await _atualizarMortalidadeLote(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      icon: const Icon(Icons.remove, size: 16),
                      label: const Text('', style: TextStyle(fontSize: 11)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await provider.adicionarMorte(baia.id);
                        await _atualizarMortalidadeLote(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('', style: TextStyle(fontSize: 11)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBaiaInfo(String label, String value, IconData icon, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? Colors.grey.shade600),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _atualizarMortalidadeLote(BuildContext context) async {
    final loteProvider = Provider.of<LoteProvider>(context, listen: false);
    await loteProvider.atualizarMortalidade(widget.lote.id);
  }
}
