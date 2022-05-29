import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product_provider.dart';
import 'package:shop_app/screens/edit_product_screen.dart';

class ManageProductWidget extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;
  ManageProductWidget(this.id,this.title,this.imageUrl);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          trailing: Container(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: Icon(Icons.edit), onPressed: (){
                  Navigator.of(context).pushNamed(EditProductScreen.routeName, arguments: id);
                },),
                IconButton(icon: Icon(Icons.delete), onPressed: () async{
                  await Provider.of<ProductProvider>(context,listen: false).deleteProduct(id);
                  Provider.of<ProductProvider>(context,listen: false).fetchAndSetData();
                },),
              ],
            ),
          ),
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(imageUrl),
          ),
          title: Text(title),
        ),
        Divider(),
      ],
    );
  }
}
