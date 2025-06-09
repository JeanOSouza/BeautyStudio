import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importe o Firestore
import 'login.dart'; // Certifique-se de que este caminho está correto

class UserRegisterScreen extends StatefulWidget {
  @override
  _UserRegisterScreenState createState() => _UserRegisterScreenState();
}

class _UserRegisterScreenState extends State<UserRegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController =
      TextEditingController(); // Novo controlador para telefone
  final _formKey = GlobalKey<FormState>();

  Future<void> _registerUser() async {
    // Valida o formulário antes de tentar o registro
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              // Método correto do Firebase Auth
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        // Se o registro no Firebase Auth for bem-sucedido, salve os dados adicionais no Firestore
        if (userCredential.user != null) {
          // Atualiza o display name no Firebase Auth (opcional, mas boa prática)
          await userCredential.user!.updateDisplayName(
            _nameController.text.trim(),
          );

          // Salva dados adicionais do usuário (nome e telefone) na coleção 'users' do Firestore
          // O ID do documento será o UID do usuário recém-criado
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
                'firstName': _nameController.text.trim(),
                'phone': _phoneController.text.trim(),
                'email': _emailController.text
                    .trim(), // Salvar o email também no Firestore
                'createdAt':
                    FieldValue.serverTimestamp(), // Adiciona um timestamp de criação
              });

          print('Usuário registrado com sucesso: ${userCredential.user!.uid}');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cadastro realizado com sucesso!')),
          );

          // Navega para a tela de login após o cadastro bem-sucedido
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(),
            ), // Substitua 'LoginScreen' pelo nome real da sua classe de login
          );
        }
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'weak-password') {
          message = 'A senha é muito fraca. Escolha uma mais forte.';
        } else if (e.code == 'email-already-in-use') {
          message = 'Este e-mail já está em uso.';
        } else {
          message = 'Erro ao registrar: ${e.message}';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        print('Erro ao registrar: $e');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ocorreu um erro inesperado. Tente novamente.'),
          ),
        );
        print('Erro genérico ao registrar: $e');
      }
    }
  }

  @override
  void dispose() {
    // Libera os controladores para evitar vazamento de memória
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController
        .dispose(); // Não se esqueça de dar dispose no novo controlador
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastro de Usuário")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey, // Associa o GlobalKey<FormState> ao formulário
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
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

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu e-mail.';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'E-mail inválido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true, // Esconde o texto da senha
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira sua senha.';
                  }
                  if (value.length < 6) {
                    return 'A senha deve ter pelo menos 6 caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Novo campo de telefone
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone para Contato',
                  hintText: '(XX) XXXXX-XXXX',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType:
                    TextInputType.phone, // Define o teclado para telefone
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu telefone.';
                  }
                  // Opcional: Regex para validação mais robusta de telefone
                  // if (!RegExp(r'^\(\d{2}\)\s\d{4,5}-\d{4}$').hasMatch(value)) {
                  //   return 'Formato de telefone inválido.';
                  // }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _registerUser,
                child: const Text("Cadastrar", style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 30,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Colors.purple, // Adapte a cor ao seu tema
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
