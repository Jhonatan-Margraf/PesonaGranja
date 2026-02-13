import 'package:flutter/foundation.dart';
import '../models/lote.dart';
import '../services/database_service.dart';

class LoteProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<Lote> _lotes = [];
  bool _isLoading = false;

  List<Lote> get lotes => _lotes;
  bool get isLoading => _isLoading;

  Future<void> carregarLotes() async {
    _isLoading = true;
    notifyListeners();

    _lotes = await _dbService.getLotes();
    
    // Ordena por data de alojamento (mais recente primeiro)
    _lotes.sort((a, b) => b.dataAlojamento.compareTo(a.dataAlojamento));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> adicionarLote(Lote lote) async {
    await _dbService.addLote(lote);
    await carregarLotes();
  }

  Future<void> atualizarLote(Lote lote) async {
    await _dbService.updateLote(lote);
    await carregarLotes();
  }

  Future<void> deletarLote(String id) async {
    await _dbService.deleteLote(id);
    await carregarLotes();
  }

  Future<void> atualizarMortalidade(String loteId) async {
    final lote = _lotes.firstWhere((l) => l.id == loteId);
    final totalMortalidade = await _dbService.getTotalMortalidadeLote(loteId);
    
    final loteAtualizado = lote.copyWith(mortalidade: totalMortalidade);
    await atualizarLote(loteAtualizado);
  }

  Lote? getLoteById(String id) {
    try {
      return _lotes.firstWhere((l) => l.id == id);
    } catch (e) {
      return null;
    }
  }
}
