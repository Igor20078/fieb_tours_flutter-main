class Aluno {
  int id;
  String nome;
  String rm;
  String? senhaBase64;

  Aluno({
    required this.id,
    required this.nome,
    required this.rm,
    this.senhaBase64,
  });

  factory Aluno.fromJson(Map<String, dynamic> json) {
    return Aluno(
      id: json['id'],
      nome: json['nome'],
      rm: json['rm'],
      senhaBase64: json['senhaBase64'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'rm': rm,
      'senhaBase64': senhaBase64,
    };
  }
}
