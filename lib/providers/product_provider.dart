import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _items = [];
  String? authToken;
  String? userId;
  ProductProvider(this.authToken,this.userId,this._items);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((favprod) => favprod.isFavourite).toList();
  }

  void updateUser(String? token, String? id) {
    userId = id;
    authToken = token;
    notifyListeners();
  }

  Product findById(String id) {
    return items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetData([bool filterUser = false]) async {
    final filterString = filterUser? 'orderBy="creatorId"&equalTo="$userId"': "";
    var url = Uri.parse(
        'https://shopapp-4a053-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken&$filterString');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if(extractedData == null){
        return;
      }
       url = Uri.parse(
          'https://shopapp-4a053-default-rtdb.asia-southeast1.firebasedatabase.app/userPreferences/$userId.json?auth=$authToken');
      final favouriteResponse = await http.get(url);
      final favouriteData = json.decode(favouriteResponse.body);
      final List<Product> loadedProduct = [];
      extractedData.forEach((prodId, prodData) {
        loadedProduct.add(
          Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            imageUrl: prodData['imageUrl'],
            price: prodData['price'],
            isFavourite: favouriteData == null ? false :favouriteData[prodId] ?? false,
          ),
        );
      });
      _items = loadedProduct;
      notifyListeners();
    } catch (error) {
      print(_items.toString());
      print(error);
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://shopapp-4a053-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'creatorId': userId,
        }),
      );
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async{
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.parse(
          'https://shopapp-4a053-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$authToken');
      await http.patch(url,body: json.encode({
        'title': newProduct.title,
        'description': newProduct.description,
        'imageUrl': newProduct.imageUrl,
        'price': newProduct.price,
      }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      return;
    }
  }

  Future<void> deleteProduct(String id) async{
    final url = Uri.parse(
        'https://shopapp-4a053-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$authToken');
    final _deleteItemIndex = _items.indexWhere((prod) =>  prod.id == id);
    final _deleteItem = _items[_deleteItemIndex];
    try{
      await http.delete(url);
      _items.removeWhere((prod) => prod.id == id);
      notifyListeners();
    }catch(error){
      _items.insert(_deleteItemIndex, _deleteItem);
      notifyListeners();
    }



    notifyListeners();
  }
}
