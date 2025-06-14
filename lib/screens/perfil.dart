import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importa o Firebase Auth
import 'disponibilidade_servico.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controladores para os campos de texto
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _specialtyController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Uma chave global para o formulário, útil para validação
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Estado para indicar se os dados estão sendo carregados ou salvos
  bool _isLoading = true;

  // Referência ao usuário logado
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser == null) {
      // Se não houver usuário logado, talvez redirecionar para a tela de login
      // Ou exibir uma mensagem de erro.
      print('Nenhum usuário logado. Redirecionando ou exibindo erro.');
      // Exemplo: Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
      setState(() {
        _isLoading = false; // Parar o loading mesmo sem dados
      });
      return;
    }
    _loadProfileData();
  }

  @override
  void dispose() {
    // Liberar os controladores para evitar vazamentos de memória
    _firstNameController.dispose();
    _lastNameController.dispose();
    _specialtyController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Função para carregar os dados do perfil do Firestore
  void _loadProfileData() async {
    if (_currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Busca o documento do perfil do usuário na coleção 'users'
      // O ID do documento é o UID do usuário autenticado
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      if (userDoc.exists) {
        // Se o documento existe, preenche os controladores com os dados
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        _firstNameController.text = data['firstName'] ?? '';
        _lastNameController.text = data['lastName'] ?? '';
        _specialtyController.text = data['specialty'] ?? '';
        _phoneController.text = data['phone'] ?? '';
      } else {
        print('Documento de perfil não encontrado para ${_currentUser!.uid}');
        // Pode ser a primeira vez que o usuário acessa, então os campos ficam vazios.
      }
    } catch (e) {
      print('Erro ao carregar dados do perfil: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar perfil: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Função para salvar as alterações do perfil no Firestore
  void _saveProfile() async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: Nenhum usuário logado para salvar o perfil.'),
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Ativa o indicador de carregamento
      });

      try {
        // Salva/Atualiza os dados do perfil na coleção 'users'
        // O ID do documento é o UID do usuário autenticado
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .set(
              {
                'firstName': _firstNameController.text.trim(),
                'lastName': _lastNameController.text.trim(),
                'specialty': _specialtyController.text.trim(),
                'phone': _phoneController.text.trim(),
                // Você pode adicionar um campo 'lastUpdated' para controle
                'lastUpdated': FieldValue.serverTimestamp(),
              },
              SetOptions(
                merge: true,
              ), // 'merge: true' para não apagar outros campos que já existam
            );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil salvo com sucesso!')),
        );
        // Opcional: Navegar de volta ou para outra tela após salvar
        // Navigator.pop(context);
      } on FirebaseException catch (e) {
        print('Erro no Firebase ao salvar perfil: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar perfil: ${e.message}')),
        );
      } catch (e) {
        print('Erro desconhecido ao salvar perfil: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro inesperado ao salvar perfil: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false; // Desativa o indicador de carregamento
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        actions: [
          if (!_isLoading) // Mostra o botão salvar apenas se não estiver carregando
            IconButton(
              icon: const Icon(Icons.save, color: Colors.white),
              onPressed: _saveProfile,
              tooltip: 'Salvar Perfil',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            ) // Mostra loading enquanto carrega
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey, // Associar a chave do formulário
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Imagem de Perfil (Opcional, você pode adicionar upload aqui)
                    Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        child: Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.grey[600],
                        ),
                        // Você pode substituir por NetworkImage ou FileImage se tiver upload de imagem
                        // backgroundImage: NetworkImage('URL_DA_IMAGEM_DO_PERFIL'),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Campo: Nome
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu nome.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Campo: Sobrenome
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Sobrenome',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu sobrenome.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Campo: Especialidade
                    TextFormField(
                      controller: _specialtyController,
                      decoration: const InputDecoration(
                        labelText: 'Especialidade',
                        hintText: 'Ex: Unha Gel, Deseho / Adesivo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.star),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira sua especialidade.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Campo: Telefone para Contato
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Telefone para Contato',
                        hintText: '(XX) XXXXX-XXXX',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu telefone.';
                        }
                        // Adicione validação de formato de telefone se necessário
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

                    // Botão para Adicionar/Editar Disponibilidade
                    ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null // Desabilita o botão se estiver carregando/salvando
                          : () {
                              // TODO: Navegar para a tela de disponibilidade
                              // Certifique-se de que a tela de disponibilidade está importada e acessível
                              // Exemplo:
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AvailabilityScreen(),
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Navegar para tela de Disponibilidade!',
                                  ),
                                ),
                              );
                            },
                      icon: const Icon(Icons.schedule),
                      label: const Text(
                        'Definir Minha Disponibilidade',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.deepPurpleAccent, // Cor do botão
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
