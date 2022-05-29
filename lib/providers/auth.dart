import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shop_app/models/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        (_expiryDate as DateTime).isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String? get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSnippet) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSnippet?key=AIzaSyBDpLA2O2KPPrLA91a-h4zv7jJ4tbg45S8');
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );
      autoLogOut();
      notifyListeners();
      final pref = await SharedPreferences.getInstance();
      final userData  = json.encode(
        {
          'token':_token,
          'userId':_userId,
          'expiryDate':_expiryDate?.toIso8601String(),
        },
      );
      pref.setString('userData', userData);
      print(userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> signIn(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async{
    final pref = await SharedPreferences.getInstance();
    if(!pref.containsKey('userData')){
      return false;
    }
    final extractedUserData = json.decode(pref.getString('userData') as String) as Map<String,dynamic>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate'] as String);
    if(expiryDate.isBefore(DateTime.now())){
      return false;
    }
    print(extractedUserData);
    _token = extractedUserData['token'] as String;
    _expiryDate = expiryDate;
    _userId = extractedUserData['userId'] as String;
    notifyListeners();
    autoLogOut();
    return true;


  }

  Future<void> logOut() async{
    _token = null;
    _userId = null;
    _expiryDate = null;
    if(_authTimer != null){
      _authTimer?.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final pref = await SharedPreferences.getInstance();
    pref.clear();
  }

  void autoLogOut(){
    if(_authTimer != null){
      _authTimer?.cancel();
    }
    final timeToExpiry = _expiryDate?.difference(DateTime.now()).inSeconds;
    Timer(Duration(seconds: timeToExpiry as int), logOut);
  }

}
