class Lote {
  String id;
  DateTime dataAlojamento;
  String origem;
  int quantidadeAlojada;
  int mortalidade;
  double pesoMedioInicial;
  double estimativaGPD;
  int machosAlojados;
  int femeasAlojadas;
  String linhaGenetica;
  double? pesoMedioReal;
  DateTime? dataPesagemReal;

  Lote({
    required this.id,
    required this.dataAlojamento,
    required this.origem,
    required this.quantidadeAlojada,
    this.mortalidade = 0,
    required this.pesoMedioInicial,
    this.estimativaGPD = 0.995,
    required this.machosAlojados,
    required this.femeasAlojadas,
    required this.linhaGenetica,
    this.pesoMedioReal,
    this.dataPesagemReal,
  });

  int get animaisAtuais => quantidadeAlojada - mortalidade;

  double get pesoMedioAtualEstimado {
    final diasDesdeAlojamento = DateTime.now().difference(dataAlojamento).inDays;
    return pesoMedioInicial + (estimativaGPD * diasDesdeAlojamento);
  }

  bool get temMedicaoReal => pesoMedioReal != null;

  double get ganhoEstimado => pesoMedioAtualEstimado - pesoMedioInicial;

  double get ganhoReal {
    if (!temMedicaoReal) return 0;
    return pesoMedioReal! - pesoMedioInicial;
  }

  double get gpdReal {
    if (!temMedicaoReal || dataPesagemReal == null) return 0;
    final diasDesdeAlojamento = dataPesagemReal!.difference(dataAlojamento).inDays;
    if (diasDesdeAlojamento == 0) return 0;
    return ganhoReal / diasDesdeAlojamento;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dataAlojamento': dataAlojamento.toIso8601String(),
      'origem': origem,
      'quantidadeAlojada': quantidadeAlojada,
      'mortalidade': mortalidade,
      'pesoMedioInicial': pesoMedioInicial,
      'estimativaGPD': estimativaGPD,
      'machosAlojados': machosAlojados,
      'femeasAlojadas': femeasAlojadas,
      'linhaGenetica': linhaGenetica,
      'pesoMedioReal': pesoMedioReal,
      'dataPesagemReal': dataPesagemReal?.toIso8601String(),
    };
  }

  factory Lote.fromJson(Map<String, dynamic> json) {
    return Lote(
      id: json['id'],
      dataAlojamento: DateTime.parse(json['dataAlojamento']),
      origem: json['origem'],
      quantidadeAlojada: json['quantidadeAlojada'],
      mortalidade: json['mortalidade'] ?? 0,
      pesoMedioInicial: json['pesoMedioInicial'].toDouble(),
      estimativaGPD: json['estimativaGPD']?.toDouble() ?? 0.995,
      machosAlojados: json['machosAlojados'],
      femeasAlojadas: json['femeasAlojadas'],
      linhaGenetica: json['linhaGenetica'],
      pesoMedioReal: json['pesoMedioReal'] != null ? json['pesoMedioReal'].toDouble() : null,
      dataPesagemReal: json['dataPesagemReal'] != null ? DateTime.parse(json['dataPesagemReal']) : null,
    );
  }

  Lote copyWith({
    String? id,
    DateTime? dataAlojamento,
    String? origem,
    int? quantidadeAlojada,
    int? mortalidade,
    double? pesoMedioInicial,
    double? estimativaGPD,
    int? machosAlojados,
    int? femeasAlojadas,
    String? linhaGenetica,
    double? pesoMedioReal,
    DateTime? dataPesagemReal,
  }) {
    return Lote(
      id: id ?? this.id,
      dataAlojamento: dataAlojamento ?? this.dataAlojamento,
      origem: origem ?? this.origem,
      quantidadeAlojada: quantidadeAlojada ?? this.quantidadeAlojada,
      mortalidade: mortalidade ?? this.mortalidade,
      pesoMedioInicial: pesoMedioInicial ?? this.pesoMedioInicial,
      estimativaGPD: estimativaGPD ?? this.estimativaGPD,
      machosAlojados: machosAlojados ?? this.machosAlojados,
      femeasAlojadas: femeasAlojadas ?? this.femeasAlojadas,
      linhaGenetica: linhaGenetica ?? this.linhaGenetica,
      pesoMedioReal: pesoMedioReal ?? this.pesoMedioReal,
      dataPesagemReal: dataPesagemReal ?? this.dataPesagemReal,
    );
  }
}
