import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

const customPizzaImageUrl = 'https://images.unsplash.com/photo-1513104890138-7c749659a591?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80';

class CustomizeScreen extends StatefulWidget {
  const CustomizeScreen({super.key});

  @override
  State<CustomizeScreen> createState() => _CustomizeScreenState();
}

class _CustomizeScreenState extends State<CustomizeScreen> {
  String _selectedSize = 'Medium';
  String _selectedCrust = 'Hand Tossed';
  final List<String> _selectedToppings = [];
  double _basePrice = 12.99;

  final List<String> _sizes = ['Small', 'Medium', 'Large'];
  final List<String> _crusts = ['Hand Tossed', 'Thin Crust', 'Stuffed Crust'];
  final List<Map<String, dynamic>> _toppings = [
    {'name': 'Pepperoni', 'price': 1.50, 'isVeg': false},
    {'name': 'Mushrooms', 'price': 1.00, 'isVeg': true},
    {'name': 'Onions', 'price': 0.75, 'isVeg': true},
    {'name': 'Bell Peppers', 'price': 0.75, 'isVeg': true},
    {'name': 'Extra Cheese', 'price': 1.50, 'isVeg': true},
    {'name': 'Black Olives', 'price': 1.00, 'isVeg': true},
    {'name': 'Italian Sausage', 'price': 1.50, 'isVeg': false},
    {'name': 'Bacon', 'price': 1.50, 'isVeg': false},
  ];

  double get _totalPrice {
    double total = _basePrice;
    // Add size price
    if (_selectedSize == 'Large') total += 4;
    else if (_selectedSize == 'Small') total -= 2;
    // Add crust price
    if (_selectedCrust == 'Stuffed Crust') total += 2;
    // Add toppings price
    for (String topping in _selectedToppings) {
      final toppingPrice = _toppings
          .firstWhere((t) => t['name'] == topping)['price'] as double;
      total += toppingPrice;
    }
    return total;
  }

  String get _customPizzaDescription {
    final toppingsText = _selectedToppings.isEmpty 
        ? 'No extra toppings' 
        : 'Toppings: ${_selectedToppings.join(', ')}';
    return '$_selectedSize size, $_selectedCrust crust. $toppingsText';
  }

  bool get _isVeg {
    return !_selectedToppings.any((topping) {
      final toppingData = _toppings.firstWhere((t) => t['name'] == topping);
      return !(toppingData['isVeg'] as bool);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Size Selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Size',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: _sizes.map((size) {
                      return ChoiceChip(
                        label: Text(size),
                        selected: _selectedSize == size,
                        onSelected: (selected) {
                          setState(() {
                            _selectedSize = size;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Crust Selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Crust',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: _crusts.map((crust) {
                      return ChoiceChip(
                        label: Text(crust),
                        selected: _selectedCrust == crust,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCrust = crust;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Toppings Selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Toppings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: _toppings.map((topping) {
                      final name = topping['name'] as String;
                      final price = topping['price'] as double;
                      final isVeg = topping['isVeg'] as bool;
                      return FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(name),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.circle,
                              size: 12,
                              color: isVeg ? Colors.green : Colors.red,
                            ),
                            Text(' +\$${price.toStringAsFixed(2)}'),
                          ],
                        ),
                        selected: _selectedToppings.contains(name),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedToppings.add(name);
                            } else {
                              _selectedToppings.remove(name);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Total and Add to Cart
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '\$${_totalPrice.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final customPizza = {
                        'id': 'custom_${DateTime.now().millisecondsSinceEpoch}',
                        'name': 'Custom Pizza',
                        'description': _customPizzaDescription,
                        'price': _totalPrice,
                        'imageUrl': customPizzaImageUrl,
                        'isVeg': _isVeg,
                      };

                      cartProvider.addItem(
                        id: customPizza['id'] as String,
                        name: customPizza['name'] as String,
                        price: customPizza['price'] as double,
                        imageUrl: customPizza['imageUrl'] as String,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Custom pizza added to cart!'),
                          action: SnackBarAction(
                            label: 'View Cart',
                            onPressed: () {
                              Navigator.pushNamed(context, '/cart');
                            },
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Add to Cart',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
