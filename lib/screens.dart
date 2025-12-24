// هذا الملف يحتوي على باقي الشاشات
// سيتم دمجه مع main.dart

// ============ Products Screen ============

import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String imageUrl;
  final int stock;
  final String merchantName;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.stock,
    required this.merchantName,
  });
}

class LocalData {
  static List<Product> getAllProducts() {
    return [
      Product(
        id: '1',
        name: 'قميص حديث',
        price: 1455,
        category: 'ملابس رجالية',
        imageUrl: 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=400',
        stock: 21,
        merchantName: 'متجر الأناقة',
      ),
      Product(
        id: '2',
        name: 'مزهرية راقي',
        price: 2995,
        category: 'ديكور منزلي',
        imageUrl: 'https://images.unsplash.com/photo-1578500494198-246f612d3b3d?w=400',
        stock: 96,
        merchantName: 'متجر الأناقة',
      ),
      Product(
        id: '3',
        name: 'عود راقي',
        price: 4999,
        category: 'عطور',
        imageUrl: 'https://images.unsplash.com/photo-1541643600914-78b084683601?w=400',
        stock: 58,
        merchantName: 'عطور الشرق',
      ),
      Product(
        id: '4',
        name: 'عباية حديثة',
        price: 1827,
        category: 'ملابس نسائية',
        imageUrl: 'https://images.unsplash.com/photo-1583391733981-5babdc0fc859?w=400',
        stock: 54,
        merchantName: 'متجر الأناقة',
      ),
      Product(
        id: '5',
        name: 'حذاء رياضي',
        price: 3144,
        category: 'أحذية',
        imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
        stock: 89,
        merchantName: 'أزياء المدينة',
      ),
      Product(
        id: '6',
        name: 'سماعات',
        price: 4355,
        category: 'إلكترونيات',
        imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
        stock: 45,
        merchantName: 'إلكترونيات الحديثة',
      ),
      Product(
        id: '7',
        name: 'بخور',
        price: 3537,
        category: 'عطور',
        imageUrl: 'https://images.unsplash.com/photo-1602874801006-96632be89c6b?w=400',
        stock: 67,
        merchantName: 'عطور الشرق',
      ),
      Product(
        id: '8',
        name: 'كابل USB-C',
        price: 1785,
        category: 'إلكترونيات',
        imageUrl: 'https://images.unsplash.com/photo-1583863788434-e58a36330cf0?w=400',
        stock: 123,
        merchantName: 'إلكترونيات الحديثة',
      ),
      Product(
        id: '9',
        name: 'شبشب',
        price: 2512,
        category: 'أحذية',
        imageUrl: 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=400',
        stock: 78,
        merchantName: 'أزياء المدينة',
      ),
      Product(
        id: '10',
        name: 'دهن عود',
        price: 1305,
        category: 'عطور',
        imageUrl: 'https://images.unsplash.com/photo-1587017539504-67cfbddac569?w=400',
        stock: 91,
        merchantName: 'عطور الشرق',
      ),
      Product(
        id: '11',
        name: 'ساعة ذكية',
        price: 5670,
        category: 'إلكترونيات',
        imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
        stock: 34,
        merchantName: 'إلكترونيات الحديثة',
      ),
      Product(
        id: '12',
        name: 'حقيبة يد',
        price: 3890,
        category: 'إكسسوارات',
        imageUrl: 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=400',
        stock: 56,
        merchantName: 'متجر الأناقة',
      ),
    ];
  }

  static List<String> getCategories() {
    return [
      'الكل',
      'ملابس رجالية',
      'ملابس نسائية',
      'أحذية',
      'إكسسوارات',
      'عطور',
      'إلكترونيات',
      'ديكور منزلي',
    ];
  }
}

class ProductsScreen extends StatefulWidget {
  final Function(int) onAddToCart;
  final List<String> favoriteIds;
  final Function(String) onToggleFavorite;

  const ProductsScreen({
    super.key,
    required this.onAddToCart,
    required this.favoriteIds,
    required this.onToggleFavorite,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _selectedCategory = 'الكل';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final allProducts = LocalData.getAllProducts();
    final categories = LocalData.getCategories();
    
    // Filter products
    var filteredProducts = allProducts.where((product) {
      final matchesCategory = _selectedCategory == 'الكل' || product.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty || 
          product.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
        title: const Text(
          'سوق السودان الذكي',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('لا توجد إشعارات جديدة')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'ابحث عن منتج...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          
          // Categories
          Container(
            height: 50,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = _selectedCategory == category;
                
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = category),
                  child: Container(
                    margin: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF6B9AC4) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Products Count
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Text(
              'عدد المنتجات: ${filteredProducts.length}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
          
          // Products Grid
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'لا توجد منتجات',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      final productIndex = allProducts.indexOf(product);
                      final isFavorite = widget.favoriteIds.contains(product.id);
                      
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image with favorite button
                            Expanded(
                              flex: 3,
                              child: Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      child: Image.network(
                                        product.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Center(
                                            child: Icon(Icons.image, size: 48, color: Colors.grey),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () => widget.onToggleFavorite(product.id),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          isFavorite ? Icons.favorite : Icons.favorite_border,
                                          color: isFavorite ? Colors.red : Colors.grey,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Product Info
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      product.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2C3E50),
                                        height: 1.2,
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${product.price.toStringAsFixed(0)} جنيه',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF6B9AC4),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'المخزون: ${product.stock}',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: product.stock > 20 ? Colors.green : Colors.orange,
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () => widget.onAddToCart(productIndex),
                                              child: Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF6B9AC4),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons.add_shopping_cart,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
