import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/passeio.dart';
import '../models/aluno.dart';
import 'package:http/http.dart' as http;

class PasseioComStatus {
  final Passeio passeio;
  final String statusReserva;
  
  PasseioComStatus({required this.passeio, required this.statusReserva});
}

class SeusPasseiosScreen extends StatefulWidget {
  final Aluno aluno;

  const SeusPasseiosScreen({required this.aluno, super.key});

  @override
  State<SeusPasseiosScreen> createState() => _SeusPasseiosScreenState();
}

class _SeusPasseiosScreenState extends State<SeusPasseiosScreen> {
  late Future<List<PasseioComStatus>> _meusPasseios;
  final String baseUrl = 'http://10.0.2.2:8080/api';

  @override
  void initState() {
    super.initState();
    _meusPasseios = fetchPasseiosReservados();
  }

  Future<List<PasseioComStatus>> fetchPasseiosReservados() async {
    // Busca as reservas
    final reservasUrl = Uri.parse('$baseUrl/reservas');
    final reservasResponse = await http.get(reservasUrl);

    if (reservasResponse.statusCode != 200) {
      throw Exception('Erro ao carregar reservas: ${reservasResponse.statusCode}');
    }

    final List<dynamic> reservasData = json.decode(reservasResponse.body);
    final alunoReservas = reservasData.where((reserva) => reserva['nome'] == widget.aluno.nome).toList();

    if (alunoReservas.isEmpty) return [];

    // Busca todos os passeios
    final passeiosUrl = Uri.parse('$baseUrl/passeios');
    final passeiosResponse = await http.get(passeiosUrl);

    if (passeiosResponse.statusCode != 200) {
      throw Exception('Erro ao carregar passeios: ${passeiosResponse.statusCode}');
    }

    final List<dynamic> passeiosData = json.decode(passeiosResponse.body);

    // Combina reservas com dados dos passeios
    List<PasseioComStatus> passeiosReservados = [];
    
    for (var reserva in alunoReservas) {
      final passeioEncontrado = passeiosData.firstWhere(
        (passeio) => passeio['nome'] == reserva['passeio'],
        orElse: () => null,
      );

      if (passeioEncontrado != null) {
        final passeio = Passeio(
          id: passeioEncontrado['id'],
          nome: passeioEncontrado['nome'],
          descricao: passeioEncontrado['descricao'] ?? '',
          dataPasseio: passeioEncontrado['dataPasseio'] ?? '',
          preco: (passeioEncontrado['preco'] ?? 0).toDouble(),
          horaSaida: passeioEncontrado['horaSaida'] ?? '',
          horaChegada: passeioEncontrado['horaChegada'] ?? '',
          dataInicioRecebimento: passeioEncontrado['dataInicioRecebimento'] ?? '',
          dataFinalRecebimento: passeioEncontrado['dataFinalRecebimento'] ?? '',
          dataCadastro: passeioEncontrado['dataCadastro'] ?? '',
          statusPasseio: passeioEncontrado['statusPasseio'] ?? '',
        );
        
        passeiosReservados.add(PasseioComStatus(
          passeio: passeio,
          statusReserva: reserva['status'] ?? 'nao-pago',
        ));
      }
    }

    return passeiosReservados;
  }

  String formatarData(String? dataString) {
    if (dataString == null || dataString.isEmpty) return '';
    final data = DateTime.tryParse(dataString);
    if (data == null) return '';
    return "${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}";
  }

  Color getStatusColor(String status) {
    return status == 'pago' ? Colors.green : Colors.orange;
  }

  String getStatusText(String status) {
    return status == 'pago' ? 'PAGO' : 'NÃO PAGO';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seus Passeios")),
      body: FutureBuilder<List<PasseioComStatus>>(
        future: _meusPasseios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final passeiosComStatus = snapshot.data ?? [];

          if (passeiosComStatus.isEmpty) {
            return const Center(child: Text('Nenhum passeio reservado.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: passeiosComStatus.length,
            itemBuilder: (context, index) {
              final item = passeiosComStatus[index];
              final passeio = item.passeio;
              
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => PasseioDetailPopup(passeio: passeio),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                'https://picsum.photos/seed/${passeio.id}/120/80',
                                width: 120,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    passeio.nome,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text("Valor: R\$${passeio.preco.toStringAsFixed(2)}"),
                                  Text("Data: ${formatarData(passeio.dataPasseio)}"),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: getStatusColor(item.statusReserva),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Status: ${getStatusText(item.statusReserva)}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ========================
// POPUP DE DETALHE
// ========================
class PasseioDetailPopup extends StatelessWidget {
  final Passeio passeio;

  const PasseioDetailPopup({required this.passeio, super.key});

  String formatarData(String? dataString) {
    if (dataString == null || dataString.isEmpty) return '';
    final data = DateTime.tryParse(dataString);
    if (data == null) return '';
    return "${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      insetPadding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(25)),
                child: Image.network(
                  'https://picsum.photos/seed/${passeio.id}/600/300',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      passeio.nome,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text("Descrição: ${passeio.descricao}"),
                    const SizedBox(height: 6),
                    Text("Valor: R\$${passeio.preco.toStringAsFixed(2)}"),
                    Text("Data passeio: ${formatarData(passeio.dataPasseio)}"),
                    Text("Hora Saída: ${passeio.horaSaida}"),
                    Text("Hora Chegada: ${passeio.horaChegada}"),
                    Text("Início Recebimento: ${formatarData(passeio.dataInicioRecebimento)}"),
                    Text("Fim Recebimento: ${formatarData(passeio.dataFinalRecebimento)}"),
                    Text("Cadastro: ${formatarData(passeio.dataCadastro)}"),
                    Text("Status: ${passeio.statusPasseio}"),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Fechar"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
