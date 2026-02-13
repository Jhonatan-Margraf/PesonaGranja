import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lote.dart';
import '../models/baia.dart';

class DatabaseService {
  static const String _lotesKey = 'lotes';
  static const String _baiasKey = 'baias';

  // Lotes
  Future<List<Lote>> getLotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? lotesJson = prefs.getString(_lotesKey);
    
    if (lotesJson == null) return [];
    
    final List<dynamic> decoded = jsonDecode(lotesJson);
    return decoded.map((json) => Lote.fromJson(json)).toList();
  }

  Future<void> saveLotes(List<Lote> lotes) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(lotes.map((l) => l.toJson()).toList());
    await prefs.setString(_lotesKey, encoded);
  }

  Future<void> addLote(Lote lote) async {
    final lotes = await getLotes();
    lotes.add(lote);
    await saveLotes(lotes);
  }

  Future<void> updateLote(Lote lote) async {
    final lotes = await getLotes();
    final index = lotes.indexWhere((l) => l.id == lote.id);
    if (index != -1) {
      lotes[index] = lote;
      await saveLotes(lotes);
    }
  }

  Future<void> deleteLote(String id) async {
    final lotes = await getLotes();
    lotes.removeWhere((l) => l.id == id);
    await saveLotes(lotes);
    
    // Remove também todas as baias do lote
    final baias = await getBaias();
    baias.removeWhere((b) => b.loteId == id);
    await saveBaias(baias);
  }

  Future<Lote?> getLoteById(String id) async {
    final lotes = await getLotes();
    try {
      return lotes.firstWhere((l) => l.id == id);
    } catch (e) {
      return null;
    }
  }

  // Baias
  Future<List<Baia>> getBaias() async {
    final prefs = await SharedPreferences.getInstance();
    final String? baiasJson = prefs.getString(_baiasKey);
    
    if (baiasJson == null) return [];
    
    final List<dynamic> decoded = jsonDecode(baiasJson);
    return decoded.map((json) => Baia.fromJson(json)).toList();
  }

  Future<void> saveBaias(List<Baia> baias) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(baias.map((b) => b.toJson()).toList());
    await prefs.setString(_baiasKey, encoded);
  }

  Future<void> addBaia(Baia baia) async {
    final baias = await getBaias();
    baias.add(baia);
    await saveBaias(baias);
  }

  Future<void> updateBaia(Baia baia) async {
    final baias = await getBaias();
    final index = baias.indexWhere((b) => b.id == baia.id);
    if (index != -1) {
      baias[index] = baia;
      await saveBaias(baias);
    }
  }

  Future<void> deleteBaia(String id) async {
    final baias = await getBaias();
    baias.removeWhere((b) => b.id == id);
    await saveBaias(baias);
  }

  Future<Baia?> getBaiaById(String id) async {
    final baias = await getBaias();
    try {
      return baias.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Baia>> getBaiasByLoteId(String loteId) async {
    final baias = await getBaias();
    return baias.where((b) => b.loteId == loteId).toList();
  }

  Future<int> getTotalMortalidadeLote(String loteId) async {
    final baias = await getBaiasByLoteId(loteId);
    return baias.fold<int>(0, (sum, baia) => sum + baia.leitoeMortos);
  }
}
