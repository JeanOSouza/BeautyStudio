import 'package:flutter/material.dart';

void main() {
  runApp(const BeautyStudioApp());
}

class BeautyStudioApp extends StatelessWidget {
  const BeautyStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beauty Studio',
      theme: ThemeData(
        brightness: Brightness.dark, // Tema escuro
        primarySwatch: Colors.deepPurple, // Cor primária para alguns widgets
        scaffoldBackgroundColor: const Color(
          0xFF1A002A,
        ), // Fundo quase preto/roxo escuro
        cardColor: const Color(0xFF2E004A), // Cor dos cards
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent, // AppBar transparente
          elevation: 0, // Sem sombra na AppBar
          foregroundColor: Colors.white, // Cor dos ícones e texto da AppBar
        ),
        // Adicione outras customizações de tema conforme necessário
      ),
      home: const ShoppingCartScreen(),
    );
  }
}

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  // Variáveis de estado para as opções de pagamento
  String? _selectedPaymentOption =
      'pay_all_now'; // 'pay_50_percent' ou 'pay_all_now'
  String? _selectedPaymentMethod = 'pix'; // 'credit_card' ou 'pix'

  // Variáveis de estado para o item do carrinho (simplificado)
  int _itemQuantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            // Ação ao pressionar o botão de voltar
          },
        ),
        title: const Text(
          'BeautyStudio',
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz), // Ou Icons.menu
            onPressed: () {
              // Ação para o menu de mais opções
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de busca "Meu carrinho" (opcional, como na imagem)
            // if (false) // Descomente para exibir
            //   Padding(
            //     padding: const EdgeInsets.only(bottom: 16.0),
            //     child: TextField(
            //       decoration: InputDecoration(
            //         hintText: 'Meu carrinho...',
            //         prefixIcon: Icon(Icons.search, color: Colors.white70),
            //         border: OutlineInputBorder(
            //           borderRadius: BorderRadius.circular(10.0),
            //           borderSide: BorderSide.none,
            //         ),
            //         filled: true,
            //         fillColor: Theme.of(context).cardColor,
            //       ),
            //     ),
            //   ),

            // Item do Carrinho (Banho de Gel)
            _buildCartItem(context),
            const SizedBox(height: 20),

            // Subtotal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'R\$ 30,00',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Opções de Pagamento
            Text('Pagamento:', style: Theme.of(context).textTheme.bodyLarge),
            RadioListTile<String>(
              title: const Text('Pagar 50% agora e o restante depois'),
              value: 'pay_50_percent',
              groupValue: _selectedPaymentOption,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentOption = value;
                });
              },
              activeColor: Colors.deepPurpleAccent,
            ),
            RadioListTile<String>(
              title: const Text('Pagar tudo agora'),
              value: 'pay_all_now',
              groupValue: _selectedPaymentOption,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentOption = value;
                });
              },
              activeColor: Colors.deepPurpleAccent,
            ),
            const SizedBox(height: 20),

            // Forma de Pagamento
            Text(
              'Forma de Pagamento:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            RadioListTile<String>(
              title: const Text('Cartão de Crédito'),
              subtitle: const Text('Parcelamento'),
              value: 'credit_card',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
              activeColor: Colors.deepPurpleAccent,
            ),
            RadioListTile<String>(
              title: const Text('Pix'),
              value: 'pix',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
              activeColor: Colors.deepPurpleAccent,
            ),
            const SizedBox(height: 20),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total:', style: Theme.of(context).textTheme.titleLarge),
                Text(
                  'R\$ 90,00', // Assumindo este é o valor final da imagem
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Botão Finalizar Compra
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Lógica para finalizar a compra
                  print('Finalizar Compra Clicado!');
                  print('Opção de Pagamento: $_selectedPaymentOption');
                  print('Método de Pagamento: $_selectedPaymentMethod');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple, // Cor do botão
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Finalizar Compra',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).cardColor,
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType
            .fixed, // Garante que todos os itens apareçam igualmente
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '', // Deixe vazio para não mostrar texto
          ),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite), // Ou outro ícone como perfil
            label: '',
          ),
        ],
        onTap: (index) {
          // Lógica para navegar entre as telas
          print('Bottom bar item $index tapped');
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero, // Remove margem padrão do Card
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 0, // Sem sombra
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Imagem do produto
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                image: const DecorationImage(
                  image: AssetImage(
                    'assets/gel_nails.png',
                  ), // Substitua pela sua imagem
                  fit: BoxFit.cover,
                ),
                color: Colors.grey[700], // Placeholder se a imagem não carregar
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white70,
              ), // Ícone placeholder
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Banho de Gel - Aplicação',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'R\$ 30,00',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.greenAccent),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Data: 28/06/2025',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Horário: 15 horas',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            // Quantidade e botão de remover
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_itemQuantity > 1) _itemQuantity--;
                        });
                      },
                    ),
                    Text(
                      '$_itemQuantity',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        setState(() {
                          _itemQuantity++;
                        });
                      },
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () {
                    // Lógica para remover o item do carrinho
                    print('Remover item clicado');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
