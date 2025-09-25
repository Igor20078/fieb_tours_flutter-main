import 'package:flutter/material.dart';
import '../api/api_service.dart';

class AvaliarPasseioScreen extends StatefulWidget {
  final int passeioId;
  final int alunoId; // precisa passar o aluno logado

  const AvaliarPasseioScreen({Key? key, required this.passeioId, required this.alunoId})
      : super(key: key);

  @override
  _AvaliarPasseioScreenState createState() => _AvaliarPasseioScreenState();
}

class _AvaliarPasseioScreenState extends State<AvaliarPasseioScreen> {
  final _formKey = GlobalKey<FormState>();
  int nota = 5;
  final TextEditingController comentarioController = TextEditingController();

  Future<void> enviarAvaliacao() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ApiService.enviarAvaliacao(
          widget.passeioId,
          widget.alunoId,
          nota,
          comentarioController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Avaliação enviada com sucesso! 🎉")),
        );
        Navigator.pop(context, true); // volta e sinaliza sucesso
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao enviar avaliação: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Avaliar Passeio")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                value: nota,
                decoration: InputDecoration(labelText: "Nota"),
                items: List.generate(5, (i) => i + 1)
                    .map((n) => DropdownMenuItem(value: n, child: Text("$n ⭐")))
                    .toList(),
                onChanged: (val) => setState(() => nota = val!),
              ),
              TextFormField(
                controller: comentarioController,
                decoration: InputDecoration(labelText: "Comentário"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Digite um comentário" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: enviarAvaliacao,
                child: Text("Enviar Avaliação"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
