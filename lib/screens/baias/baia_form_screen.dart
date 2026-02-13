import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/baia.dart';
import '../../providers/baia_provider.dart';
import '../../providers/lote_provider.dart';

class BaiaFormScreen extends StatefulWidget {
  final String loteId;
  final Baia? baia;

  const BaiaFormScreen({
    Key? key,
    required this.loteId,
    this.baia,
  }) : super(key: key);

  @override
  State<BaiaFormScreen> createState() => _BaiaFormScreenState();
}

class _BaiaFormScreenState extends State<BaiaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _numeroController;
  late TextEditingController _quantidadeController;

  SexoBaia _sexoSelecionado = SexoBaia.macho;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _numeroController = TextEditingController(text: widget.baia?.numero ?? '');
    _quantidadeController = TextEditingController(
      text: widget.baia?.quantidadeSuinos.toString() ?? '',
    );

    if (widget.baia != null) {
      _sexoSelecionado = widget.baia!.sexo;
    }
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final baia = Baia(
      id: widget.baia?.id ?? const Uuid().v4(),
      loteId: widget.loteId,
      numero: _numeroController.text,
      sexo: _sexoSelecionado,
      quantidadeSuinos: int.parse(_quantidadeController.text),
      leitoeMortos: widget.baia?.leitoeMortos ?? 0,
      medicoes: widget.baia?.medicoes ?? [],
    );

    final provider = Provider.of<BaiaProvider>(context, listen: false);

    try {
      if (widget.baia == null) {
        await provider.adicionarBaia(baia);
      } else {
        await provider.atualizarBaia(baia);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.baia == null
                  ? 'Baia cadastrada com sucesso!'
                  : 'Baia atualizada com sucesso!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao salvar baia'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final baiaProvider = Provider.of<BaiaProvider>(context, listen: false);
    final loteProvider = Provider.of<LoteProvider>(context, listen: false);
    final lote = loteProvider.getLoteById(widget.loteId);
    final totalOutrasBaias = baiaProvider.baias
        .where((b) => b.id != widget.baia?.id)
        .fold<int>(0, (sum, b) => sum + b.quantidadeSuinos);
    final maximoDisponivel = lote == null
        ? null
        : (lote.animaisAtuais - totalOutrasBaias).clamp(0, lote.animaisAtuais);
    final numeroJaExiste = (String value) {
      final normalized = value.trim().toLowerCase();
      return baiaProvider.baias.any(
        (b) => b.id != widget.baia?.id && b.numero.trim().toLowerCase() == normalized,
      );
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.baia == null ? 'Nova Baia' : 'Editar Baia'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle('Identificação'),
            TextFormField(
              controller: _numeroController,
              decoration: InputDecoration(
                labelText: 'Número da Baia',
                hintText: 'Ex: 1, 2, A1, B2',
                prefixIcon: const Icon(Icons.door_front_door),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                if (numeroJaExiste(value)) {
                  return 'Já existe uma baia com esse número';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Sexo dos Animais'),
            _buildSexoSelector(),
            const SizedBox(height: 24),
            _buildSectionTitle('Quantidade'),
            TextFormField(
              controller: _quantidadeController,
              decoration: InputDecoration(
                labelText: 'Quantidade de Suínos',
                hintText: '0',
                helperText: maximoDisponivel == null
                    ? null
                    : 'Máximo disponível no lote: $maximoDisponivel',
                prefixIcon: const Icon(Icons.pets),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                if (int.tryParse(value) == null) {
                  return 'Valor inválido';
                }
                final parsedValue = int.parse(value);
                if (parsedValue < 0) {
                  return 'Valor deve ser maior ou igual a zero';
                }
                if (maximoDisponivel != null && parsedValue > maximoDisponivel) {
                  return 'Valor excede o máximo disponível no lote';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _salvar,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      widget.baia == null ? 'CADASTRAR BAIA' : 'SALVAR ALTERAÇÕES',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
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

  Widget _buildSexoSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildSexoOption(
            SexoBaia.macho,
            'Machos',
            Icons.male,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSexoOption(
            SexoBaia.femea,
            'Fêmeas',
            Icons.female,
            Colors.pink,
          ),
        ),
      ],
    );
  }

  Widget _buildSexoOption(
    SexoBaia sexo,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _sexoSelecionado == sexo;

    return InkWell(
      onTap: () {
        setState(() {
          _sexoSelecionado = sexo;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: isSelected ? color : Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
