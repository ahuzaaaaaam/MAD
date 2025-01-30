import 'package:flutter/material.dart';
import '../widgets/product_card.dart';
import '../providers/cart_provider.dart';
import 'package:provider/provider.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key, this.showOnlyFeatured = false});

  final bool showOnlyFeatured;

  static List<Map<String, dynamic>> getFeaturedProducts() {
    return _MenuScreenState._allProducts
        .where((p) => p['isFeatured'] as bool)
        .toList();
  }

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _selectedCategory = 'All';

  static final List<Map<String, dynamic>> _allProducts = [
    {
      'id': '1',
      'name': 'Pepperoni Pizza',
      'description': 'Savory pepperoni, melted mozzarella, and zesty tomato sauce on a classic crust.',
      'price': 14.99,
      'imageUrl': 'https://www.cherryonmysundae.com/wp-content/uploads/2021/10/pepperoni-pizza-8.jpg',
      'isVeg': false,
      'isFeatured': true,
    },
    {
      'id': '2',
      'name': 'Hawaiian Pizza',
      'description': 'Sweet pineapple, savory ham, and melted mozzarella on a zesty tomato base.',
      'price': 15.99,
      'imageUrl': 'https://dinnerthendessert.com/wp-content/uploads/2024/07/Hawaiian-Pizza-1-2.jpg',
      'isVeg': false,
      'isFeatured': true,
    },
    {
      'id': '3',
      'name': 'Margherita Pizza',
      'description': 'Fresh mozzarella, basil, and tomato sauce on a classic crust.',
      'price': 13.99,
      'imageUrl': 'https://cb.scene7.com/is/image/Crate/frame-margherita-pizza-1?wid=800&qlt=70&op_sharpen=1',
      'isVeg': true,
      'isFeatured': true,
    },
    {
      'id': '4',
      'name': 'Veggie Supreme',
      'description': 'Mushrooms, bell peppers, onions, olives, and tomatoes.',
      'price': 15.99,
      'imageUrl': 'https://www.vegrecipesofindia.com/wp-content/uploads/2020/11/pizza-recipe-2.jpg',
      'isVeg': true,
      'isFeatured': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    final products = widget.showOnlyFeatured 
        ? _allProducts.where((p) => p['isFeatured'] as bool).toList()
        : _allProducts;

    if (widget.showOnlyFeatured || _selectedCategory == 'All') return products;
    return products.where((product) => 
      _selectedCategory == 'Veg' ? product['isVeg'] : !product['isVeg']
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Column(
      children: [
        if (!widget.showOnlyFeatured) ...[
          // Categories
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['All', 'Veg', 'Non-Veg'].map((category) {
                final isSelected = _selectedCategory == category;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.red : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        // Products
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredProducts.length,
            itemBuilder: (context, index) {
              final product = _filteredProducts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ProductCard(
                  id: product['id'] as String,
                  name: product['name'] as String,
                  description: product['description'] as String,
                  price: product['price'] as double,
                  imageUrl: product['imageUrl'] as String,
                  isVeg: product['isVeg'] as bool,
                  onAddToCart: () {
                    cartProvider.addItem(
                      id: product['id'] as String,
                      name: product['name'] as String,
                      price: product['price'] as double,
                      imageUrl: product['imageUrl'] as String,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added ${product['name']} to cart'),
                        action: SnackBarAction(
                          label: 'View Cart',
                          onPressed: () {
                            Navigator.pushNamed(context, '/cart');
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
