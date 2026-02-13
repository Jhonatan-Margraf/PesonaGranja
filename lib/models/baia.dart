import 'medicao.dart';

enum SexoBaia { macho, femea }

class Baia {
  String id;
  String loteId;
  String numero;
  SexoBaia sexo;
  int quantidadeSuinos;
  int leitoeMortos;
  double? pesoManualMedio; // [FUNCIONALIDADE DE DESENVOLVEDOR]
  List<Medicao> medicoes;

  Baia({
    required this.id,
    required this.loteId,
    required this.numero,
    required this.sexo,
    required this.quantidadeSuinos,
    this.leitoeMortos = 0,
    this.pesoManualMedio,
    List<Medicao>? medicoes,
  }) : medicoes = medicoes ?? [];

  double? get pesoMedioAtual {
    if (medicoes.isEmpty) return null;
    
    // Pega as medições do dia atual
    final hoje = DateTime.now();
    final medicoesHoje = medicoes.where((m) {
      return m.dataHora.year == hoje.year &&
             m.dataHora.month == hoje.month &&
             m.dataHora.day == hoje.day;
    }).toList();

    if (medicoesHoje.isEmpty) {
      // Se não tem medições hoje, pega a última medição
      return medicoes.last.peso;
    }

    // Calcula a média das medições do dia
    final somasPesos = medicoesHoje.fold<double>(0, (sum, m) => sum + m.peso);
    return somasPesos / medicoesHoje.length;
  }

  void adicionarMorte() {
    if (quantidadeSuinos > 0) {
    leitoeMortos++;
    if (quantidadeSuinos > 0) {
      quantidadeSuinos--;
    }
    }
  }

  void reverterMorte() {
    if (leitoeMortos > 0) {
      leitoeMortos--;
      quantidadeSuinos++;
    }
  }

  void adicionarMedicao(Medicao medicao) {
    medicoes.add(medicao);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loteId': loteId,
      'numero': numero,
      'sexo': sexo == SexoBaia.macho ? 'macho' : 'femea',
      'quantidadeSuinos': quantidadeSuinos,
      'leitoeMortos': leitoeMortos,
      'pesoManualMedio': pesoManualMedio,
      'medicoes': medicoes.map((m) => m.toJson()).toList(),
    };
  }

  factory Baia.fromJson(Map<String, dynamic> json) {
    return Baia(
      id: json['id'],
      loteId: json['loteId'],
      numero: json['numero'],
      sexo: json['sexo'] == 'macho' ? SexoBaia.macho : SexoBaia.femea,
      quantidadeSuinos: json['quantidadeSuinos'],
      leitoeMortos: json['leitoeMortos'] ?? 0,
      pesoManualMedio: json['pesoManualMedio'],
      medicoes: (json['medicoes'] as List?)
              ?.map((m) => Medicao.fromJson(m))
              .toList() ??
          [],
    );
  }

  Baia copyWith({
    String? id,
    String? loteId,
    String? numero,
    SexoBaia? sexo,
    int? quantidadeSuinos,
    int? leitoeMortos,
    double? pesoManualMedio,
    List<Medicao>? medicoes,
  }) {
    return Baia(
      id: id ?? this.id,
      loteId: loteId ?? this.loteId,
      numero: numero ?? this.numero,
      sexo: sexo ?? this.sexo,
      quantidadeSuinos: quantidadeSuinos ?? this.quantidadeSuinos,
      leitoeMortos: leitoeMortos ?? this.leitoeMortos,
      pesoManualMedio: pesoManualMedio ?? this.pesoManualMedio,
      medicoes: medicoes ?? this.medicoes,
    );
  }
}
