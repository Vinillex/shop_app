import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  var id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  bool isFavourite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.isFavourite = false,
  });
  
  void _setFavValue(bool newValue){
    isFavourite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavouriteStatus(String token, String userId) async{
    final oldStatus = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();
    final url = Uri.parse(
        'https://shopapp-4a053-default-rtdb.asia-southeast1.firebasedatabase.app/userPreferences/$userId/$id.json?auth=$token');
    try{
      final response = await http.put(url,body: json.encode(
        isFavourite
      ));
      if(response.statusCode >= 400){
        _setFavValue(oldStatus);

      }
    }catch(error){
      _setFavValue(oldStatus);
    }
  }
}
