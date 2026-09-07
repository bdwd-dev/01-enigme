import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const EnigmeApp());
}

class EnigmeApp extends StatelessWidget {
  const EnigmeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'L\'Énigme',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE91E63),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE91E63),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.dark,
      home: const HomeScreen(),
    );
  }
}

// ============================================
// API SERVICE
// ============================================
class ApiService {
  static const String baseUrl = 'http://localhost:3001/api';

  static Future<dynamic> get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Erreur GET $endpoint');
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    }
    throw Exception('Erreur POST $endpoint');
  }
}

// ============================================
// HOME SCREEN
// ============================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<dynamic> _products = [];
  List<dynamic> _categories = [];
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _cart = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final products = await ApiService.get('/products');
      final categories = await ApiService.get('/categories');
      final stats = await ApiService.get('/stats');
      setState(() {
        _products = products;
        _categories = categories;
        _stats = stats;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      final existing = _cart.indexWhere((i) => i['id'] == product['id']);
      if (existing >= 0) {
        _cart[existing]['qty']++;
      } else {
        _cart.add({...product, 'qty': 1});
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product['name']} ajouté au panier')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔞 L\'Énigme', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => _showCart(),
              ),
              if (_cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_cart.length}',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _currentIndex == 0
          ? _buildHomeTab()
          : _currentIndex == 1
              ? _buildCategoriesTab()
              : _buildProfileTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex i),
        selectedItemColor: const Color(0xFFE91E63),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Catégories'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Bien-être & Intimité',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Produits premium — Livraison 100% anonyme',
            style: TextStyle(color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _StatCard(icon: Icons.inventory, value: '${_stats['products'] ?? 0}', label: 'Produits'),
              _StatCard(icon: Icons.shopping_bag, value: '${_stats['orders'] ?? 0}', label: 'Commandes'),
              _StatCard(icon: Icons.people, value: '${_stats['customers'] ?? 0}', label: 'Clients'),
              _StatCard(icon: Icons.attach_money, value: '${_stats['revenue'] ?? 0}', label: 'CA (F)'),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Produits populaires',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._products.take(4).map((p) => _ProductCard(product: p, onAdd: () => _addToCart(p))),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Catégories',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ..._categories.map((c) => Card(
          child: ListTile(
            leading: const Icon(Icons.category, color: Color(0xFFE91E63)),
            title: Text(c['name']),
            subtitle: Text('${c['count']} produits'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          )),
        )),
      ],
    );
  }

  Widget _buildProfileTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFFE91E63),
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text('Client Anonyme', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('+242 ** *** **', style: TextStyle(color: Colors.grey[400])),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.diamond),
            label: const Text('Acheter Oziki'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => _CartView(
          cart: _cart,
          onUpdateQty: (idx, qty) {
            setState(() {
              if (qty <= 0) {
                _cart.removeAt(idx);
              } else {
                _cart[idx]['qty'] = qty;
              }
            });
          },
          onCheckout: () {
            Navigator.pop(context);
            _showCheckout();
          },
        ),
      ),
    );
  }

  void _showCheckout() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    String deliveryMethod = 'delivery';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Finaliser la commande', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nom (ou pseudo)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Téléphone', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: deliveryMethod,
                decoration: const InputDecoration(labelText: 'Livraison', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'delivery', child: Text('Livraison à domicile')),
                  DropdownMenuItem(value: 'click-collect', child: Text('Click & Collect')),
                ],
                onChanged: (v) => setSheetState(() => deliveryMethod = v!),
              ),
              if (deliveryMethod == 'delivery') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Adresse', border: OutlineInputBorder()),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await ApiService.post('/orders', {
                        'customer_name': nameController.text,
                        'customer_phone': phoneController.text,
                        'delivery_method': deliveryMethod,
                        'delivery_address': addressController.text,
                        'items': _cart.map((i) => {'product_id': i['id'], 'qty': i['qty']}).toList(),
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Commande confirmée !')),
                      );
                      setState(() => _cart.clear());
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur: $e')),
                      );
                    }
                  },
                  child: const Text('Confirmer'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// WIDGETS
// ============================================
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 32),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onAdd;

  const _ProductCard({required this.product, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.card_giftcard, color: Color(0xFFE91E63)),
        ),
        title: Text(product['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${product['price']?.toLocaleString()} F'),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle, color: Color(0xFFE91E63)),
          onPressed: onAdd,
        ),
      ),
    );
  }
}

class _CartView extends StatelessWidget {
  final List<Map<String, dynamic>> cart;
  final Function(int, int) onUpdateQty;
  final VoidCallback onCheckout;

  const _CartView({required this.cart, required this.onUpdateQty, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    final total = cart.fold<int>(0, (s, i) => s + (i['price'] as int) * (i['qty'] as int));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Panier', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('${cart.length} articles', style: TextStyle(color: Colors.grey[400])),
            ],
          ),
        ),
        Expanded(
          child: cart.isEmpty
              ? const Center(child: Text('Panier vide'))
              : ListView.builder(
                  itemCount: cart.length,
                  itemBuilder: (context, idx) {
                    final item = cart[idx];
                    return ListTile(
                      title: Text(item['name']),
                      subtitle: Text('${item['price']?.toLocaleString()} F'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => onUpdateQty(idx, item['qty'] - 1),
                          ),
                          Text('${item['qty']}', style: const TextStyle(fontSize: 16)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => onUpdateQty(idx, item['qty'] + 1),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        if (cart.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontSize: 18)),
                    Text('${total.toLocaleString()} F', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onCheckout,
                    child: const Text('Passer commande'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
