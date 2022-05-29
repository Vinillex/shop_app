import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/order_item_widget.dart';

import '../providers/orders.dart';
import '../providers/product_provider.dart';

class OrderScreen extends StatelessWidget {
  static const routeName = '/order-screen';

  const OrderScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    //final orderData = Provider.of<Orders>(context);
    print('building order screen');
    return Scaffold(
      appBar: AppBar(
        title: Text('Order'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
          future:
              Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (dataSnapshot.error != null) {
                return const Center(
                  child: Text('An Error Occurred'),
                );
              } else {
                return Consumer<Orders>(
                  builder: (ctx, orderData, child){
                    return ListView.builder(
                      itemBuilder: (ctx, i) => OrderItemWidget(orderData.orders[i]),
                      itemCount: orderData.orders.length,
                    );
                  },
                );
              }
            }
          }),
    );
  }
}
