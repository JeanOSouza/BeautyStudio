import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tela_adcao_servico.dart'; // Provavelmente sua ServiceFormScreen
import 'package:beautystudio/cores/cores.dart'; // cores
import 'disponibilidade_servico.dart'; //
import 'perfil.dart';

class ListaServicosScreen extends StatefulWidget {
  const ListaServicosScreen({super.key});

  @override
  State<ListaServicosScreen> createState() => _ListaServicosScreenState();
}

class _ListaServicosScreenState extends State<ListaServicosScreen> {
  @override
  Widget build(BuildContext context) {
    final servicosRef = FirebaseFirestore.instance.collection('services');

    return Scaffold(
      appBar: AppBar(
        // Ícone de menu (três barras) para abrir o Drawer
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
              ), // Ícone do menu
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Abre o Drawer
              },
            );
          },
        ),
        title: const Text(
          'Meus Serviços',
          style: TextStyle(color: Colors.white),
        ), // Texto do título
        backgroundColor: AppColors.roxoEscuro, // Cor de fundo roxa
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calendar_today,
              color: Colors.white,
            ), // Ícone do calendário
            tooltip: 'Definir Disponibilidade',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const DisponibilidadeProfissionalScreen(),
                ),
              );
            },
          ),
          // Botão de perfil (substituído pelo Drawer, mas mantido aqui para referência se precisar de mais ações na AppBar)
          // PopupMenuButton<String>(
          //   icon: const Icon(Icons.person, color: Colors.white),
          //   onSelected: (value) {
          //     if (value == 'perfil') {
          //       // TODO: Navegar para tela de perfil
          //     } else if (value == 'disponibilidade') {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) => const DisponibilidadeProfissionalScreen(),
          //         ),
          //       );
          //     } else if (value == 'sair') {
          //       // TODO: Lógica de logout
          //     }
          //   },
          //   itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          //     const PopupMenuItem<String>(
          //       value: 'perfil',
          //       child: Text('Editar Perfil'),
          //     ),
          //     const PopupMenuItem<String>(
          //       value: 'disponibilidade',
          //       child: Text('Definir Disponibilidade'),
          //     ),
          //     const PopupMenuItem<String>(value: 'sair', child: Text('Sair')),
          //   ],
          // ),
        ],
      ),
      // --- DRAWER ---
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero, // Remove padding extra do ListView
          children: <Widget>[
            // Cabeçalho do Drawer
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.roxoEscuro, // Cor roxa para o cabeçalho
              ),
              child: const Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            // Opção "Perfil"
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Perfil'),
              onTap: () {
                // TODO: Navegar para a tela de perfil
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            // Opção "Cadastro de Serviço"
            ListTile(
              leading: const Icon(Icons.add_business),
              title: const Text('Cadastro de Serviço'),
              onTap: () {
                Navigator.pop(context); // Fecha o drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ServiceFormScreen(),
                  ), // Navega para a tela de cadastro
                );
              },
            ),
            // Adicione mais opções de menu aqui, se necessário
          ],
        ),
      ),
      // --- FIM DO NOVO ELEMENTO: DRAWER ---
      body: StreamBuilder<QuerySnapshot>(
        stream: servicosRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar serviços.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final servicos = snapshot.data!.docs;

          if (servicos.isEmpty) {
            return const Center(child: Text('Nenhum serviço cadastrado.'));
          }

          return ListView.builder(
            itemCount: servicos.length,
            itemBuilder: (context, index) {
              final servico = servicos[index];
              final data = servico.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: data['images'] != null && data['images'].isNotEmpty
                      ? Image.network(
                          data['images'][0],
                          width: 60,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image),
                  title: Text(
                    data['serviceName'] ?? 'Sem nome',
                  ), // Correção para 'serviceName'
                  subtitle: Text(data['description'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // Navegue para tela de edição aqui
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Color.fromARGB(255, 67, 11, 77),
                        ),
                        onPressed: () {
                          _confirmarExclusao(context, servico.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // --- NOVO ELEMENTO: FLOATING ACTION BUTTON ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ServiceFormScreen(),
            ), // Navega para a tela de cadastro de serviço
          );
        },
        backgroundColor: Colors.purple, // Cor do FAB
        tooltip: 'Cadastrar novo serviço', // Dica ao passar o mouse/segurar
        child: const Icon(Icons.add, color: Colors.white), // Ícone de adição
      ),
      // --- FIM DO NOVO ELEMENTO: FLOATING ACTION BUTTON ---
    );
  }

  void _confirmarExclusao(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir Serviço'),
        content: const Text('Tem certeza que deseja excluir este serviço?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Excluir'),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('services') // 'services' em vez de 'servicos'
                  .doc(id)
                  .delete();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
