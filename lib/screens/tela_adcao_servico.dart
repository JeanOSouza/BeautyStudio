import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:beautystudio/models/service.dart';

class ServiceFormScreen extends StatefulWidget {
  final Service?
  service; // Torna o serviço opcional (null para adicionar, preenchido para editar)

  const ServiceFormScreen({super.key, this.service});

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  // Variáveis
  final _formKey = GlobalKey<FormState>(); //validação de formulário
  File?
  _selectedImage; // Usado para a imagem que está sendo selecionada localmente
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _userCommentController = TextEditingController();
  final List<String> _imagePaths = []; // URLs das imagens já salvas/carregadas

  bool _isEditing = false; // Indica se estamos no modo de edição

  @override
  void initState() {
    super.initState();
    // Verifica se um serviço foi passado para a tela
    if (widget.service != null) {
      _isEditing = true;
      _serviceNameController.text = widget.service!.serviceName;
      _descriptionController.text = widget.service!.description;
      _valueController.text = widget.service!.value.toStringAsFixed(
        2,
      ); // Formata o valor
      _userCommentController.text = widget.service!.userComment;
      // Carrega as imagens existentes do serviço
      _imagePaths.addAll(widget.service!.images);
    }
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    _userCommentController.dispose();
    super.dispose();
  }

  // abrir a galeria, selecionar imagem e fazer upload para Firebase Storage
  void _addImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      setState(() {
        _selectedImage =
            imageFile; // Opcional: exibir a imagem logo após a seleção
      });

      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child(
        'service_images/$fileName.jpg',
      );

      try {
        UploadTask uploadTask = storageRef.putFile(imageFile);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        setState(() {
          _imagePaths.add(downloadUrl); // Adiciona a URL da nova imagem à lista
          _selectedImage = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imagem adicionada com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao fazer upload da imagem: $e')),
        );
      }
    }
  }

  // Função para remover uma imagem da lista (antes de salvar/atualizar)
  void _removeImage(String imageUrl) {
    setState(() {
      _imagePaths.remove(imageUrl);
    });
  }

  // Função para salvar ou atualizar o serviço no Firestore
  void _saveService() async {
    if (!_formKey.currentState!.validate()) {
      // Valida o formulário
      return;
    }

    final serviceName = _serviceNameController.text.trim();
    final description = _descriptionController.text.trim();
    final value = double.tryParse(_valueController.text.trim()) ?? 0.0;
    final userComment = _userCommentController.text.trim();

    try {
      if (_isEditing) {
        // Modo de EDIÇÃO: Atualiza o documento existente
        await FirebaseFirestore.instance
            .collection('services')
            .doc(widget.service!.id)
            .update({
              'serviceName': serviceName,
              'description': description,
              'value': value,
              'userComment': userComment,
              'images': _imagePaths, // Atualiza a lista de imagens
              'updatedAt':
                  FieldValue.serverTimestamp(), // Adiciona timestamp de atualização
            });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Serviço "$serviceName" atualizado com sucesso!'),
          ),
        );
      } else {
        // Modo de ADIÇÃO: Cria um novo documento
        await FirebaseFirestore.instance.collection('services').add({
          'serviceName': serviceName,
          'description': description,
          'value': value,
          'userComment': userComment,
          'images': _imagePaths,
          'createdAt': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Serviço "$serviceName" adicionado com sucesso!'),
          ),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar serviço: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('lib/img/Logo.png'),
        ),
        // O título da AppBar muda com base no modo
        title: Text(_isEditing ? 'Editar Serviço' : 'Novo Serviço'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          // Envolve o formulário em um Form para validação
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campo: Nome do Serviço
              TextFormField(
                controller: _serviceNameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Serviço',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.palette),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do serviço.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Campo: Descrição do Serviço
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição Detalhada',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 4,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a descrição do serviço.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Campo: Valor do Serviço
              TextFormField(
                controller: _valueController,
                decoration: const InputDecoration(
                  labelText: 'Valor (Ex: 100.00)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o valor do serviço.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Valor inválido. Use números e "." para decimais.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25),

              // Texto da Galeria de Imagens
              const Text(
                'Galeria de Imagens do Serviço',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Botão para adicionar imagem
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _addImage,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Adicionar Imagem'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Área para mostrar as imagens selecionadas/existentes
              _imagePaths.isEmpty
                  ? const Text(
                      'Nenhuma imagem adicionada ainda.',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    )
                  : Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _imagePaths.map((path) {
                        return Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              // Se for URL, usa Image.network; se for File path local (durante a seleção), usa Image.file
                              child: path.startsWith('http')
                                  ? Image.network(
                                      path,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.broken_image,
                                              ), // fallback
                                    )
                                  : Image.file(
                                      File(path),
                                      fit: BoxFit.cover,
                                    ), // Para imagens que ainda não foram para o Firebase
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () => _removeImage(
                                  path,
                                ), // Chama a função de remover
                                child: const CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.purple,
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
              const SizedBox(height: 25),

              // Campo: Comentário para o Usuário
              TextField(
                controller: _userCommentController,
                decoration: const InputDecoration(
                  labelText:
                      'Observações para o Usuário (Ex: Preparo necessário)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.comment),
                ),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 30),

              // Botão para salvar serviço
              ElevatedButton.icon(
                onPressed: _saveService,
                icon: const Icon(Icons.save),
                // O texto do botão muda com base no modo
                label: Text(
                  _isEditing ? 'Atualizar Serviço' : 'Salvar Serviço',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
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
