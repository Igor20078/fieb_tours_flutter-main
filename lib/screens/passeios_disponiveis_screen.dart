import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/passeio.dart';
import '../models/aluno.dart';

class PasseiosDisponiveisScreen extends StatefulWidget {
  final Aluno aluno;

  const PasseiosDisponiveisScreen({required this.aluno, super.key});

  @override
  State<PasseiosDisponiveisScreen> createState() =>
      _PasseiosDisponiveisScreenState();
}

class _PasseiosDisponiveisScreenState extends State<PasseiosDisponiveisScreen> {
  late Future<List<Passeio>> _passeiosFuture;

  @override
  void initState() {
    super.initState();
    _passeiosFuture = ApiService.getPasseios();
  }

  String formatarData(String? dataString) {
    if (dataString == null || dataString.isEmpty) return '';
    final data = DateTime.tryParse(dataString);
    if (data == null) return '';
    return "${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}";
  }

  // ========================
  // FUNÇÃO PARA RESERVAR
  // ========================
  Future<void> _reservarPasseio(Passeio passeio) async {
    try {
      // Aqui seguimos exatamente a assinatura do ApiService
      await ApiService.reservarPasseio(passeio, widget.aluno);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passeio reservado com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao reservar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Passeios Disponíveis")),
      body: FutureBuilder<List<Passeio>>(
        future: _passeiosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum passeio disponível'));
          }

          final passeios = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: passeios.length,
            itemBuilder: (context, index) {
              final passeio = passeios[index];

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
                    child: Row(
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
                              Text("Início Recebimento: ${formatarData(passeio.dataInicioRecebimento)}"),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _reservarPasseio(passeio),
                          child: const Text("Reservar"),
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
