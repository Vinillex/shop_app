import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop_app/providers/orders.dart';

class OrderItemWidget extends StatefulWidget {
  final OrderItem order;
  OrderItemWidget(this.order);

  @override
  State<OrderItemWidget> createState() => _OrderItemWidgetState();
}

class _OrderItemWidgetState extends State<OrderItemWidget> {
  bool _isexpanded = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text('\$${widget.order.amount}'),
            subtitle: Text(DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime)),
            trailing: IconButton(
              icon: Icon(_isexpanded? Icons.expand_less: Icons.expand_more),
              onPressed: (){
                setState(() {
                  _isexpanded = !_isexpanded;
                });
              },
            ),
          ),
          if(_isexpanded)
            Container(
              padding: EdgeInsets.all(20),
              color: Colors.white,
              height: widget.order.products.length * 50,
              child: ListView(
                children: widget.order.products.map((prod) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(prod.title),
                    Text(prod.quantity.toString()),
                    Text(prod.price.toString()),
                  ],
                )).toList(),
              ),
            )
        ],
      ),
    );
  }
}
