import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/product_provider.dart';
import '../widgets/product_item.dart';
class ProductGrid extends StatelessWidget {
  final bool favourite;
  ProductGrid(this.favourite);

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final products = favourite? productProvider.favoriteItems : productProvider.items;
    return GridView.builder(
        padding: EdgeInsets.all(10),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (ctx, i) {
          return ChangeNotifierProvider.value(
            value: products[i],
            child: ProductItem(
            ),
          );
        });
  }
}
