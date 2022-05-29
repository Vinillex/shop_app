import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product_provider.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/badge.dart';
import 'package:shop_app/widgets/product_grid.dart';
import 'package:shop_app/widgets/product_item.dart';
import '../providers/cart.dart';
import '../providers/product.dart';

enum Filter { favorites, all }

class ProductOverviewScreen extends StatefulWidget {
  @override
  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _showOnlyFavourites = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<ProductProvider>(context).fetchAndSetData().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Product Overview'),
          actions: [
            PopupMenuButton(
              icon: Icon(Icons.more_vert),
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  child: Text('Only Favourites'),
                  value: Filter.favorites,
                ),
                const PopupMenuItem(
                  child: Text('Show All'),
                  value: Filter.all,
                ),
              ],
              onSelected: (Filter selectedValue) {
                setState(() {
                  if (selectedValue == Filter.favorites) {
                    _showOnlyFavourites = true;
                  } else {
                    _showOnlyFavourites = false;
                  }
                });
              },
            ),
            Consumer<Cart>(
              builder: (_, cart, ch) => Badge(
                value: cart.itemCount.toString(),
                color: Theme.of(context).accentColor,
                child: IconButton(
                  icon: const Icon(
                    Icons.shopping_cart,
                  ),
                  onPressed: () {
                    //print(cart.itemCount.toString());
                    Navigator.of(context).pushNamed(
                      CartScreen.routeName,
                    );
                  },
                ),
              ),
            )
          ],
        ),
        drawer: AppDrawer(),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ProductGrid(_showOnlyFavourites));
  }
}
