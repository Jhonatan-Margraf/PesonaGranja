import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lote.dart';
import '../providers/lote_provider.dart';

class StatisticsDetailScreen extends StatelessWidget {
  final String loteId;

  const StatisticsDetailScreen({Key? key, required this.loteId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LoteProvider>(
      builder: (context, provider, child) {
        final lote = provider.getLoteById(loteId);
        if (lote == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Estatisticas do Lote'),
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: Text(
                'Lote nao encontrado',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Estatisticas do Lote'),
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeaderCard(context, lote),
              const SizedBox(height: 16),
              _buildChartCard(
                title: 'Curva de engorda (projecao)',
                subtitle: 'Baseado em peso inicial e GPD estimado',
                child: _buildImagePlaceholder(),
              ),
              const SizedBox(height: 16),
              _buildChartCard(
                title: 'Animais atuais x mortalidade',
                subtitle: 'Demonstrativo com base no lote',
                child: _buildImagePlaceholder(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImagePlaceholder() {
    return SizedBox(
      height: 200,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade400,
            width: 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                'Espaço para imagem',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, Lote lote) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Origem: ${lote.origem}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Peso inicial: ${lote.pesoMedioInicial.toStringAsFixed(1)} kg',
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              'GPD estimado: ${lote.estimativaGPD.toStringAsFixed(3)} kg/dia',
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

