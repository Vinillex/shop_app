import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)?.settings.arguments as String;
    final selectedProduct = Provider.of<ProductProvider>(context, listen: false)
        .findById(productId);

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedProduct.title),
      ),
      body: Column(
        children: [
          Container(
            height: 300,
            width: double.infinity,
            child: Image.network(
              selectedProduct.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 10,),
          Text('${selectedProduct.price}'),
          SizedBox(height: 10,),
          Text('${selectedProduct.description}')
        ],
      ),
    );
  }
}
