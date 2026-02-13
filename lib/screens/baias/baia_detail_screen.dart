import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/baia.dart';
import '../../providers/baia_provider.dart';
import '../../providers/lote_provider.dart';
import '../camera/camera_screen.dart';
import 'baia_form_screen.dart';

class BaiaDetailScreen extends StatefulWidget {
  final Baia baia;

  const BaiaDetailScreen({Key? key, required this.baia}) : super(key: key);

  @override
  State<BaiaDetailScreen> createState() => _BaiaDetailScreenState();
}

class _BaiaDetailScreenState extends State<BaiaDetailScreen> {
  late TextEditingController _pesoController;

  @override
  void initState() {
    super.initState();
    _pesoController = TextEditingController(
      text: widget.baia.pesoManualMedio?.toStringAsFixed(1) ?? '',
    );
  }

  @override
  void dispose() {
    _pesoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Baia ${widget.baia.numero}'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BaiaFormScreen(
                    loteId: widget.baia.loteId,
                    baia: widget.baia,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmarExclusao(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildInfoSection(),
            _buildWeightSection(),
            _buildHistorySection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CameraScreen(baia: widget.baia),
            ),
          );
        },
        backgroundColor: Colors.green.shade700,
        icon: const Icon(Icons.camera_alt),
        label: const Text('MEDIR PESO'),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.baia.sexo == SexoBaia.macho ? Colors.blue.shade700 : Colors.pink.shade700,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.baia.sexo == SexoBaia.macho ? Icons.male : Icons.female,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BAIA',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      widget.baia.numero,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.baia.sexo == SexoBaia.macho ? 'Machos' : 'Fêmeas',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Informações'),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Suínos Atuais',
                  '${widget.baia.quantidadeSuinos}',
                  Icons.pets,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  'Mortalidade',
                  '${widget.baia.leitoeMortos}',
                  Icons.warning_amber,
                  widget.baia.leitoeMortos > 0 ? Colors.red : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightSection() {
    final pesoMedio = widget.baia.pesoMedioAtual;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Peso Atual'),
          Card(
            elevation: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.scale,
                    size: 64,
                    color: pesoMedio != null ? Colors.green.shade700 : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    pesoMedio != null
                        ? '${pesoMedio.toStringAsFixed(1)} kg'
                        : 'Não medido',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: pesoMedio != null ? Colors.green.shade700 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pesoMedio != null ? 'Peso médio atual' : 'Realize a primeira medição',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // [FUNCIONALIDADE DE DESENVOLVEDOR]
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      border: Border.all(color: Colors.orange.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.code, size: 16, color: Colors.orange.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'FUNCIONALIDADE DE DESENVOLVEDOR',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _pesoController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Adicionar Medida Manual (kg)',
                            hintText: '0.0',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onChanged: (value) {
                            if (value.isEmpty) {
                              widget.baia.pesoManualMedio = null;
                            } else {
                              final peso = double.tryParse(value);
                              if (peso != null) {
                                widget.baia.pesoManualMedio = peso;
                              }
                            }
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            onPressed: () async {
                              final peso = double.tryParse(_pesoController.text);
                              if (peso != null && peso > 0) {
                                final baiaProvider = context.read<BaiaProvider>();
                                final loteProvider = context.read<LoteProvider>();
                                
                                final baiaAtualizada = widget.baia.copyWith(
                                  pesoManualMedio: peso,
                                );
                                await baiaProvider.atualizarBaia(baiaAtualizada);
                                
                                // Calcula a média de peso real das baias após atualizar
                                // (aguarda um pouco para garantir que a baia foi atualizada)
                                await Future.delayed(const Duration(milliseconds: 500));
                                final pesoMedioReal = baiaProvider.getPesoMedioRealManual();
                                
                                if (pesoMedioReal != null) {
                                  // Busca o lote correspondente
                                  final lote = loteProvider.getLoteById(widget.baia.loteId);
                                  if (lote != null) {
                                    final loteAtualizado = lote.copyWith(
                                      pesoMedioReal: pesoMedioReal,
                                      dataPesagemReal: DateTime.now(),
                                    );
                                    await loteProvider.atualizarLote(loteAtualizado);
                                  }
                                }
                                
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Medida manual ${peso.toStringAsFixed(1)} kg salva e lote atualizado'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Digite um peso válido'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            child: const Text('Salvar Medida'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    if (widget.baia.medicoes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Histórico de Medições'),
            Card(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhuma medição realizada',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Agrupa medições por data
    final medicoesAgrupadas = <String, List<double>>{};
    final dateFormat = DateFormat('dd/MM/yyyy');

    for (var medicao in widget.baia.medicoes) {
      final dataStr = dateFormat.format(medicao.dataHora);
      if (!medicoesAgrupadas.containsKey(dataStr)) {
        medicoesAgrupadas[dataStr] = [];
      }
      medicoesAgrupadas[dataStr]!.add(medicao.peso);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle('Histórico de Medições'),
              Text(
                '${widget.baia.medicoes.length} medições',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: medicoesAgrupadas.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final data = medicoesAgrupadas.keys.toList()[index];
                final pesos = medicoesAgrupadas[data]!;
                final pesoMedio = pesos.reduce((a, b) => a + b) / pesos.length;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: Icon(
                      Icons.scale,
                      color: Colors.green.shade700,
                    ),
                  ),
                  title: Text(
                    '${pesoMedio.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '$data • ${pesos.length} medição${pesos.length > 1 ? 'ões' : ''}',
                  ),
                  trailing: pesos.length > 1
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Mín: ${pesos.reduce((a, b) => a < b ? a : b).toStringAsFixed(1)}',
                              style: const TextStyle(fontSize: 11),
                            ),
                            Text(
                              'Máx: ${pesos.reduce((a, b) => a > b ? a : b).toStringAsFixed(1)}',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green.shade700,
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarExclusao(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text(
          'Tem certeza que deseja excluir esta baia? '
          'Todo o histórico de medições será perdido.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () async {
              final provider = Provider.of<BaiaProvider>(context, listen: false);
              await provider.deletarBaia(widget.baia.id);
              if (context.mounted) {
                Navigator.pop(context); // Fecha o diálogo
                Navigator.pop(context); // Volta para lista
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Baia excluída com sucesso'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('EXCLUIR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
