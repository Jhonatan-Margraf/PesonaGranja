import 'package:flutter/foundation.dart';
import '../models/baia.dart';
import '../models/medicao.dart';
import '../services/database_service.dart';

class BaiaProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<Baia> _baias = [];
  bool _isLoading = false;
  String? _loteIdAtual;

  List<Baia> get baias => _baias;
  bool get isLoading => _isLoading;

  Future<void> carregarBaiasPorLote(String loteId) async {
    _isLoading = true;
    _loteIdAtual = loteId;
    notifyListeners();

    _baias = await _dbService.getBaiasByLoteId(loteId);
    
    // Ordena por número da baia
    _baias.sort((a, b) {
      final numA = int.tryParse(a.numero) ?? 0;
      final numB = int.tryParse(b.numero) ?? 0;
      return numA.compareTo(numB);
    });

    _isLoading = false;
    notifyListeners();
  }

  Future<void> adicionarBaia(Baia baia) async {
    await _dbService.addBaia(baia);
    if (_loteIdAtual != null) {
      await carregarBaiasPorLote(_loteIdAtual!);
    }
  }

  Future<void> atualizarBaia(Baia baia) async {
    await _dbService.updateBaia(baia);
    if (_loteIdAtual != null) {
      await carregarBaiasPorLote(_loteIdAtual!);
    }
  }

  Future<void> deletarBaia(String id) async {
    await _dbService.deleteBaia(id);
    if (_loteIdAtual != null) {
      await carregarBaiasPorLote(_loteIdAtual!);
    }
  }

  Future<void> adicionarMorte(String baiaId) async {
    final baia = _baias.firstWhere((b) => b.id == baiaId);
    baia.adicionarMorte();
    await atualizarBaia(baia);
  }

  Future<void> reverterMorte(String baiaId) async {
    final baia = _baias.firstWhere((b) => b.id == baiaId);
    baia.reverterMorte();
    await atualizarBaia(baia);
  }

  Future<void> adicionarMedicao(String baiaId, Medicao medicao) async {
    final baia = _baias.firstWhere((b) => b.id == baiaId);
    baia.adicionarMedicao(medicao);
    await atualizarBaia(baia);
  }

  Baia? getBaiaById(String id) {
    try {
      return _baias.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  double? getPesoMedioBaias() {
    if (_baias.isEmpty) return null;
    
    final baiasComPeso = _baias.where((b) => b.pesoMedioAtual != null).toList();
    if (baiasComPeso.isEmpty) return null;

    final somaPesos = baiasComPeso.fold<double>(
      0,
      (sum, baia) => sum + (baia.pesoMedioAtual ?? 0),
    );

    return somaPesos / baiasComPeso.length;
  }
}
