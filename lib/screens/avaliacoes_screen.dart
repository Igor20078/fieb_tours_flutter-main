import 'package:flutter/material.dart';
import '../models/aluno.dart';
import 'avaliar_passeio_screen.dart';
import 'ver_avaliacoes_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AvaliacoesScreen extends StatefulWidget {
  final Aluno aluno;

  const AvaliacoesScreen({Key? key, required this.aluno}) : super(key: key);

  @override
  _AvaliacoesScreenState createState() => _AvaliacoesScreenState();
}

class _AvaliacoesScreenState extends State<AvaliacoesScreen> {
  List passeios = [];

  @override
  void initState() {
    super.initState();
    fetchPasseios();
  }

  Future<void> fetchPasseios() async {
    final response = await http.get(
      Uri.parse("http://localhost:8080/api/passeios"),
    );
    if (response.statusCode == 200) {
      setState(() {
        passeios = json.decode(response.body);
      });
    }
  }

  void verAvaliacoes(int passeioId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerAvaliacoesScreen(passeioId: passeioId),
      ),
    );
  }

  void avaliarPasseio(int passeioId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AvaliarPasseioScreen(
          passeioId: passeioId,
          alunoId: widget.aluno.id, // aqui vem do aluno logado
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Avaliações")),
      body: ListView.builder(
        itemCount: passeios.length,
        itemBuilder: (context, index) {
          final passeio = passeios[index];
          return Card(
            child: ListTile(
              title: Text(passeio["titulo"] ?? ""),
              subtitle: Text(passeio["descricao"] ?? ""),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () => verAvaliacoes(passeio["id"]),
                    child: Text("Ver Avaliações"),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => avaliarPasseio(passeio["id"]),
                    child: Text("Avaliar"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
