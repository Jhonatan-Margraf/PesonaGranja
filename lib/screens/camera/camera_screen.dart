import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
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
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isProcessing = false;
  File? _capturedImage;
  double? _pesoAnalisado;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nenhuma câmera disponível'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Erro ao inicializar câmera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao acessar câmera: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _tirarFoto() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      setState(() {
        _isProcessing = true;
      });

      final XFile foto = await _controller!.takePicture();
      final File imageFile = File(foto.path);

      setState(() {
        _capturedImage = imageFile;
      });

      // Analisa a foto com a API
      await _analisarPeso(imageFile);
    } catch (e) {
      print('Erro ao tirar foto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao tirar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _analisarPeso(File imageFile) async {
    try {
      setState(() {
        _isProcessing = true;
      });

      // Mostra diálogo de carregamento
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
                Text('Analisando imagem...'),
              ],
            ),
          ),
        );
      }

      // MODO SIMULADO - Remover em produção
      // Para desenvolvimento, usa peso simulado
      final peso = await _apiService.simularAnalise();

      // MODO REAL - Descomentar em produção
      // final peso = await _apiService.analisarPesoSuino(imageFile);

      if (mounted) {
        Navigator.pop(context); // Fecha diálogo de carregamento
      }

      setState(() {
        _pesoAnalisado = peso;
      });

      if (mounted) {
        _mostrarResultado(peso, imageFile);
      }
    } catch (e) {
      print('Erro ao analisar peso: $e');
      if (mounted) {
        Navigator.pop(context); // Fecha diálogo de carregamento
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao analisar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _mostrarResultado(double peso, File imageFile) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Peso Analisado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: Colors.green.shade700,
            ),
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
            const Text(
              'Deseja salvar esta medição?',
              textAlign: TextAlign.center,
            ),
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
      // Volta para a câmera
      setState(() {
        _capturedImage = null;
        _pesoAnalisado = null;
      });
    }
  }

  Future<void> _salvarMedicao(double peso, File imageFile) async {
    try {
      // Salva a imagem permanentemente
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = path.join(
        directory.path,
        'medicoes',
        '${const Uuid().v4()}.jpg',
      );

      final imageDir = Directory(path.dirname(imagePath));
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }

      await imageFile.copy(imagePath);

      // Cria a medição
      final medicao = Medicao(
        id: const Uuid().v4(),
        baiaId: widget.baia.id,
        dataHora: DateTime.now(),
        peso: peso,
        imagemPath: imagePath,
      );

      // Salva no provider
      final provider = Provider.of<BaiaProvider>(context, listen: false);
      await provider.adicionarMedicao(widget.baia.id, medicao);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medição salva com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        // Volta para a tela anterior
        Navigator.pop(context);
      }
    } catch (e) {
      print('Erro ao salvar medição: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _refazerFoto() {
    setState(() {
      _capturedImage = null;
      _pesoAnalisado = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized && _capturedImage == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Câmera'),
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Baia ${widget.baia.numero} - Medir Peso'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Preview da câmera ou imagem capturada
          if (_capturedImage != null)
            Center(
              child: Image.file(_capturedImage!),
            )
          else if (_controller != null && _controller!.value.isInitialized)
            Center(
              child: CameraPreview(_controller!),
            ),

          // Guias de enquadramento
          if (_capturedImage == null)
            CustomPaint(
              painter: FrameGuidesPainter(),
              child: Container(),
            ),

          // Instruções
          if (_capturedImage == null)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.info_outline, color: Colors.white),
                    SizedBox(height: 8),
                    Text(
                      'Posicione o porco dentro do quadro',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Tire a foto de lado, mostrando o corpo completo',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

          // Controles
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.black87,
              ),
              child: _capturedImage == null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FloatingActionButton(
                          onPressed: _isProcessing ? null : _tirarFoto,
                          backgroundColor: Colors.white,
                          child: _isProcessing
                              ? const CircularProgressIndicator()
                              : const Icon(Icons.camera_alt, color: Colors.black),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _refazerFoto,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refazer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        if (_pesoAnalisado != null)
                          ElevatedButton.icon(
                            onPressed: () => _salvarMedicao(_pesoAnalisado!, _capturedImage!),
                            icon: const Icon(Icons.save),
                            label: const Text('Salvar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white,
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
}

class FrameGuidesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.8,
      height: size.height * 0.5,
    );

    // Desenha os cantos do frame
    final cornerLength = 40.0;

    // Canto superior esquerdo
    canvas.drawLine(rect.topLeft, Offset(rect.left + cornerLength, rect.top), paint);
    canvas.drawLine(rect.topLeft, Offset(rect.left, rect.top + cornerLength), paint);

    // Canto superior direito
    canvas.drawLine(rect.topRight, Offset(rect.right - cornerLength, rect.top), paint);
    canvas.drawLine(rect.topRight, Offset(rect.right, rect.top + cornerLength), paint);

    // Canto inferior esquerdo
    canvas.drawLine(rect.bottomLeft, Offset(rect.left + cornerLength, rect.bottom), paint);
    canvas.drawLine(rect.bottomLeft, Offset(rect.left, rect.bottom - cornerLength), paint);

    // Canto inferior direito
    canvas.drawLine(rect.bottomRight, Offset(rect.right - cornerLength, rect.bottom), paint);
    canvas.drawLine(rect.bottomRight, Offset(rect.right, rect.bottom - cornerLength), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
