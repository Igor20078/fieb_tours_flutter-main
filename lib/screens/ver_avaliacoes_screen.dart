import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/avaliacao.dart';

class VerAvaliacoesScreen extends StatefulWidget {
  final int passeioId;

  const VerAvaliacoesScreen({Key? key, required this.passeioId}) : super(key: key);

  @override
  _VerAvaliacoesScreenState createState() => _VerAvaliacoesScreenState();
}

class _VerAvaliacoesScreenState extends State<VerAvaliacoesScreen> {
  List<Avaliacao> avaliacoes = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarAvaliacoes();
  }

  Future<void> carregarAvaliacoes() async {
    try {
      final lista = await ApiService.getAvaliacoes(widget.passeioId);
      setState(() {
        avaliacoes = lista;
        carregando = false;
      });
    } catch (e) {
      setState(() => carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao carregar avaliações: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Avaliações do Passeio")),
      body: carregando
          ? Center(child: CircularProgressIndicator())
          : avaliacoes.isEmpty
              ? Center(child: Text("Nenhuma avaliação ainda 😢"))
              : ListView.builder(
                  itemCount: avaliacoes.length,
                  itemBuilder: (context, index) {
                    final avaliacao = avaliacoes[index];
                    return Card(
                      child: ListTile(
                        title: Text("⭐ ${avaliacao.nota}/5"),
                        subtitle: Text(avaliacao.comentario),
                        trailing: Text("Aluno ${avaliacao.alunoId}"),
                      ),
                    );
                  },
                ),
    );
  }
}
