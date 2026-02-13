import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../providers/lote_provider.dart';
import '../../models/lote.dart';

class LoteFormScreen extends StatefulWidget {
  final Lote? lote;

  const LoteFormScreen({Key? key, this.lote}) : super(key: key);

  @override
  State<LoteFormScreen> createState() => _LoteFormScreenState();
}

class _LoteFormScreenState extends State<LoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateFormat = DateFormat('dd/MM/yyyy');

  late TextEditingController _origemController;
  late TextEditingController _quantidadeController;
  late TextEditingController _pesoInicialController;
  late TextEditingController _gpdController;
  late TextEditingController _machosController;
  late TextEditingController _femeasController;
  late TextEditingController _linhaGeneticaController;

  DateTime _dataAlojamento = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _origemController = TextEditingController(text: widget.lote?.origem ?? '');
    _quantidadeController = TextEditingController(
      text: widget.lote?.quantidadeAlojada.toString() ?? '',
    );
    _pesoInicialController = TextEditingController(
      text: widget.lote?.pesoMedioInicial.toString() ?? '',
    );
    _gpdController = TextEditingController(
      text: widget.lote?.estimativaGPD.toString() ?? '0.995',
    );
    _machosController = TextEditingController(
      text: widget.lote?.machosAlojados.toString() ?? '',
    );
    _femeasController = TextEditingController(
      text: widget.lote?.femeasAlojadas.toString() ?? '',
    );
    _linhaGeneticaController = TextEditingController(
      text: widget.lote?.linhaGenetica ?? '',
    );

    if (widget.lote != null) {
      _dataAlojamento = widget.lote!.dataAlojamento;
    }
  }

  @override
  void dispose() {
    _origemController.dispose();
    _quantidadeController.dispose();
    _pesoInicialController.dispose();
    _gpdController.dispose();
    _machosController.dispose();
    _femeasController.dispose();
    _linhaGeneticaController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataAlojamento,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null && picked != _dataAlojamento) {
      setState(() {
        _dataAlojamento = picked;
      });
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Valida que machos + fêmeas = quantidade total
    final machos = int.parse(_machosController.text);
    final femeas = int.parse(_femeasController.text);
    final total = int.parse(_quantidadeController.text);

    if (machos + femeas != total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A soma de machos e fêmeas deve ser igual à quantidade total!',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final provider = Provider.of<LoteProvider>(context, listen: false);
    final dataDuplicada = provider.lotes.any((l) {
      if (l.id == widget.lote?.id) return false;
      return l.dataAlojamento.year == _dataAlojamento.year &&
          l.dataAlojamento.month == _dataAlojamento.month &&
          l.dataAlojamento.day == _dataAlojamento.day;
    });

    if (dataDuplicada) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Já existe um lote com a data ${_dateFormat.format(_dataAlojamento)}',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final lote = Lote(
      id: widget.lote?.id ?? const Uuid().v4(),
      dataAlojamento: _dataAlojamento,
      origem: _origemController.text,
      quantidadeAlojada: int.parse(_quantidadeController.text),
      mortalidade: widget.lote?.mortalidade ?? 0,
      pesoMedioInicial: double.parse(_pesoInicialController.text),
      estimativaGPD: double.parse(_gpdController.text),
      machosAlojados: machos,
      femeasAlojadas: femeas,
      linhaGenetica: _linhaGeneticaController.text,
    );

    try {
      if (widget.lote == null) {
        await provider.adicionarLote(lote);
      } else {
        await provider.atualizarLote(lote);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.lote == null
                  ? 'Lote cadastrado com sucesso!'
                  : 'Lote atualizado com sucesso!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao salvar lote'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lote == null ? 'Novo Lote' : 'Editar Lote'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle('Informações Básicas'),
            _buildDateField(),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _origemController,
              label: 'Origem dos Leitões',
              hint: 'Ex: Granja ABC',
              icon: Icons.location_on,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _linhaGeneticaController,
              label: 'Linha Genética',
              hint: 'Ex: DB90, Topigs',
              icon: Icons.science,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Quantidades'),
            _buildTextField(
              controller: _quantidadeController,
              label: 'Quantidade Alojada',
              hint: '0',
              icon: Icons.groups,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                if (int.tryParse(value) == null) {
                  return 'Valor inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _machosController,
                    label: 'Machos',
                    hint: '0',
                    icon: Icons.male,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obrigatório';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Inválido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _femeasController,
                    label: 'Fêmeas',
                    hint: '0',
                    icon: Icons.female,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obrigatório';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Inválido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Peso e Desempenho'),
            _buildTextField(
              controller: _pesoInicialController,
              label: 'Peso Médio Inicial (kg)',
              hint: '0.0',
              icon: Icons.scale,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                if (double.tryParse(value) == null) {
                  return 'Valor inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _gpdController,
              label: 'Estimativa de GPD (kg/dia)',
              hint: '0.995',
              icon: Icons.trending_up,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                if (double.tryParse(value) == null) {
                  return 'Valor inválido';
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
                      widget.lote == null ? 'CADASTRAR LOTE' : 'SALVAR ALTERAÇÕES',
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
      padding: const EdgeInsets.only(bottom: 16),
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

  Widget _buildDateField() {
    return InkWell(
      onTap: _selecionarData,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Data de Alojamento',
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(_dateFormat.format(_dataAlojamento)),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}
