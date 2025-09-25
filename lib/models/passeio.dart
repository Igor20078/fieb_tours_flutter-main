class Passeio {
  final int id;
  final String nome;
  final String descricao;
  final String dataPasseio;
  final double preco;
  final String horaSaida;
  final String horaChegada;
  final String dataInicioRecebimento;
  final String dataFinalRecebimento;
  final String dataCadastro;
  final String statusPasseio;

  Passeio({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.dataPasseio,
    required this.preco,
    required this.horaSaida,
    required this.horaChegada,
    required this.dataInicioRecebimento,
    required this.dataFinalRecebimento,
    required this.dataCadastro,
    required this.statusPasseio,
  });

  factory Passeio.fromJson(Map<String, dynamic> json) {
    return Passeio(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      dataPasseio: json['dataPasseio'],
      preco: (json['preco'] as num).toDouble(),
      horaSaida: json['horaSaida'],
      horaChegada: json['horaChegada'],
      dataInicioRecebimento: json['dataInicioRecebimento'],
      dataFinalRecebimento: json['dataFinalRecebimento'],
      dataCadastro: json['dataCadastro'],
      statusPasseio: json['statusPasseio'],
    );
  }
}
