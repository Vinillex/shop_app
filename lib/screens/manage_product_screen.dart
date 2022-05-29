import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product_provider.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/manage_product_widget.dart';

import 'edit_product_screen.dart';

class ManageProductScreen extends StatelessWidget {
  static const routeName = '/manage-product-screen';

  Future<void> _refreshScreen(BuildContext context) async {
    await Provider.of<ProductProvider>(context, listen: false)
        .fetchAndSetData(true);
  }

  @override
  Widget build(BuildContext context) {
    //final productData = Provider.of<ProductProvider>(context);
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('Manage Products'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _refreshScreen(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshScreen(context),
                    child: Consumer<ProductProvider>(
                      builder:(ctx, productData, _) =>  ListView.builder(
                        itemCount: productData.items.length,
                        itemBuilder: (ctx, i) => ManageProductWidget(
                          productData.items[i].id,
                          productData.items[i].title,
                          productData.items[i].imageUrl,
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
