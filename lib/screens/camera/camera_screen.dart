import 'dart:io'; // Necessário para File() no Mobile
import 'package:flutter/foundation.dart' show kIsWeb; // Verifica se é Web
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';

import '../../models/baia.dart';
import '../../models/medicao.dart';
import '../../providers/baia_provider.dart';
import '../../services/api_service.dart';

class CameraScreen extends StatefulWidget {
  final Baia baia;

  const CameraScreen({Key? key, required this.baia}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isProcessing = false;
  XFile? _capturedImage; // Usamos XFile para compatibilidade total
  double? _pesoAnalisado;

  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  Future<void> _fazerUpload(ImageSource source) async {
    try {
      final XFile? imagem = await _picker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (imagem != null) {
        setState(() {
          _capturedImage = imagem;
          _pesoAnalisado = null;
        });
        _analisarPeso(imagem);
      }
    } catch (e) {
      _showError('Erro ao selecionar imagem: $e');
    }
  }

  Future<void> _analisarPeso(XFile imageFile) async {
    try {
      setState(() => _isProcessing = true);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('IA analisando peso...'),
              ],
            ),
          ),
        );
      }

      final peso = await _apiService.analisarPesoSuino(imageFile);

      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      setState(() {
        _pesoAnalisado = peso;
        _isProcessing = false;
      });

      if (mounted && peso != null) {
        _mostrarResultado(peso, imageFile);
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      _showError('Erro na análise: $e');
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _mostrarResultado(double peso, XFile imageFile) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Peso Analisado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green.shade700),
            const SizedBox(height: 16),
            Text(
              '${peso.toStringAsFixed(1)} kg',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Deseja salvar esta medição?',
                textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('DESCARTAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('SALVAR'),
          ),
        ],
      ),
    );

    if (resultado == true) {
      await _salvarMedicao(peso, imageFile);
    } else {
      _resetarSelecao();
    }
  }

  Future<void> _salvarMedicao(double peso, XFile imageFile) async {
    try {
      String finalPath = imageFile.path;

      if (!kIsWeb) {
        // Lógica exclusiva do Mobile
        final directory = await getApplicationDocumentsDirectory();
        final fileName = '${const Uuid().v4()}.jpg';
        final savedPath = path.join(directory.path, 'medicoes', fileName);

        final imageDir = Directory(path.dirname(savedPath));
        if (!await imageDir.exists()) {
          await imageDir.create(recursive: true);
        }

        await File(imageFile.path).copy(savedPath);
        finalPath = savedPath;
      }
      // Na Web, salvamos o path do blob temporário (ou faríamos upload para nuvem)

      final medicao = Medicao(
        id: const Uuid().v4(),
        baiaId: widget.baia.id,
        dataHora: DateTime.now(),
        peso: peso,
        imagemPath: finalPath,
      );

      final provider = Provider.of<BaiaProvider>(context, listen: false);
      await provider.adicionarMedicao(widget.baia.id, medicao);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Medição salva!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('Erro ao salvar: $e');
    }
  }

  void _resetarSelecao() {
    setState(() {
      _capturedImage = null;
      _pesoAnalisado = null;
      _isProcessing = false;
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // --- WIDGET PARA EXIBIR IMAGEM COM SEGURANÇA NA WEB ---
  Widget _buildImageDisplay() {
    if (_capturedImage == null) return Container();

    if (kIsWeb) {
      // WEB: Usa Image.network com o caminho do blob
      return Image.network(
        _capturedImage!.path,
        fit: BoxFit.contain,
        errorBuilder: (ctx, err, stack) =>
            const Icon(Icons.broken_image, size: 50, color: Colors.grey),
      );
    } else {
      // MOBILE: Usa Image.file com dart:io File
      return Image.file(
        File(_capturedImage!.path),
        fit: BoxFit.contain,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Medição: Baia ${widget.baia.numero}'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _capturedImage == null ? _buildUploadUI() : _buildReviewUI(),
        ),
      ),
    );
  }

  Widget _buildUploadUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_upload_outlined,
            size: 100, color: Colors.blue.shade200),
        const SizedBox(height: 24),
        const Text(
          'Análise de Peso por Foto',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Selecione uma imagem clara do animal.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed:
                _isProcessing ? null : () => _fazerUpload(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('ABRIR GALERIA', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: OutlinedButton.icon(
            onPressed:
                _isProcessing ? null : () => _fazerUpload(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label:
                const Text('TIRAR FOTO AGORA', style: TextStyle(fontSize: 16)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.blue.shade700),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Imagem Selecionada",
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 350,
            width: double.infinity,
            color: Colors.grey[200],
            // AQUI CHAMAMOS A FUNÇÃO SEGURA
            child: _buildImageDisplay(),
          ),
        ),
        const SizedBox(height: 24),
        if (_isProcessing)
          const Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text("Processando imagem..."),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _resetarSelecao,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text('DESCARTAR',
                      style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              if (_pesoAnalisado != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _salvarMedicao(_pesoAnalisado!, _capturedImage!),
                    icon: const Icon(Icons.save),
                    label: const Text('SALVAR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}