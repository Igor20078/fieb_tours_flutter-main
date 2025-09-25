class Avaliacao {
  int id;
  int passeioId;
  int alunoId;
  int nota;
  String comentario;

  Avaliacao({
    required this.id,
    required this.passeioId,
    required this.alunoId,
    required this.nota,
    required this.comentario,
  });

  factory Avaliacao.fromJson(Map<String, dynamic> json) {
    return Avaliacao(
      id: json['id'],
      passeioId: json['passeioId'] ?? json['passeio_id'], // garante compatibilidade
      alunoId: json['alunoId'] ?? json['aluno_id'],
      nota: json['nota'],
      comentario: json['comentario'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'passeioId': passeioId,
      'alunoId': alunoId,
      'nota': nota,
      'comentario': comentario,
    };
  }
}
