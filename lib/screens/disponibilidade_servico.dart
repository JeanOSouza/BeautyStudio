import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DisponibilidadeProfissionalScreen extends StatefulWidget {
  const DisponibilidadeProfissionalScreen({super.key});

  @override
  State<DisponibilidadeProfissionalScreen> createState() =>
      _DisponibilidadeProfissionalScreenState();
}

class _DisponibilidadeProfissionalScreenState
    extends State<DisponibilidadeProfissionalScreen> {
  final List<String> diasSemana = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
  Map<String, bool> diasSelecionados = {};
  Map<String, TimeOfDay?> horaInicio = {};
  Map<String, TimeOfDay?> horaFim = {};

  @override
  void initState() {
    super.initState();
    for (var dia in diasSemana) {
      diasSelecionados[dia] = false;
      horaInicio[dia] = null;
      horaFim[dia] = null;
    }
  }

  Future<void> _selecionarHora(String dia, bool isInicio) async {
    final TimeOfDay? horaSelecionada = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (horaSelecionada != null) {
      setState(() {
        if (isInicio) {
          horaInicio[dia] = horaSelecionada;
        } else {
          horaFim[dia] = horaSelecionada;
        }
      });
    }
  }

  Future<void> _salvarDisponibilidade() async {
    final disponibilidade = <String, dynamic>{};

    for (var dia in diasSemana) {
      if (diasSelecionados[dia] == true) {
        disponibilidade[dia] = {
          'inicio': horaInicio[dia]?.format(context) ?? '',
          'fim': horaFim[dia]?.format(context) ?? '',
        };
      }
    }

    await FirebaseFirestore.instance
        .collection('disponibilidade')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set(disponibilidade);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Disponibilidade salva com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disponibilidade'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: diasSemana.length,
        itemBuilder: (context, index) {
          final dia = diasSemana[index];
          return Column(
            children: [
              SwitchListTile(
                title: Text(dia),
                value: diasSelecionados[dia]!,
                onChanged: (bool valor) {
                  setState(() {
                    diasSelecionados[dia] = valor;
                  });
                },
              ),
              if (diasSelecionados[dia] == true)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => _selecionarHora(dia, true),
                          child: Text(
                            horaInicio[dia] != null
                                ? 'Início: ${horaInicio[dia]!.format(context)}'
                                : 'Selecionar início',
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () => _selecionarHora(dia, false),
                          child: Text(
                            horaFim[dia] != null
                                ? 'Fim: ${horaFim[dia]!.format(context)}'
                                : 'Selecionar fim',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const Divider(),
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.save),
          label: const Text('Salvar Disponibilidade'),
          onPressed: _salvarDisponibilidade,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }
}
