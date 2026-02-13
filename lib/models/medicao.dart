class Medicao {
  String id;
  String baiaId;
  DateTime dataHora;
  double peso;
  String? imagemPath;

  Medicao({
    required this.id,
    required this.baiaId,
    required this.dataHora,
    required this.peso,
    this.imagemPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'baiaId': baiaId,
      'dataHora': dataHora.toIso8601String(),
      'peso': peso,
      'imagemPath': imagemPath,
    };
  }

  factory Medicao.fromJson(Map<String, dynamic> json) {
    return Medicao(
      id: json['id'],
      baiaId: json['baiaId'],
      dataHora: DateTime.parse(json['dataHora']),
      peso: json['peso'].toDouble(),
      imagemPath: json['imagemPath'],
    );
  }
}
