import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/product_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product-screen';

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _key = GlobalKey<FormState>();
  var _editedProduct = Product(
    id: null,
    title: '',
    description: '',
    imageUrl: '',
    price: 0,
  );
  var _isInit = true;
  var _initValues = {
    'title': '',
    'description': '',
    'imageUrl': '',
    'price': '',
  };
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)?.settings.arguments;
      if (productId != null) {
        _editedProduct = Provider.of<ProductProvider>(context, listen: false)
            .findById(productId as String);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'imageUrl': '',
          'price': _editedProduct.price.toString(),
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
    ;
  }

  Future<void> _saveForm() async{
    final _isValid = _key.currentState?.validate();
    if (!_isValid!) {
      return;
    }
    _key.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      await Provider.of<ProductProvider>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      try{
        await Provider.of<ProductProvider>(context, listen: false)
            .addProduct(_editedProduct);
      }catch(error){
        await showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('An error occured!!!'),
              content: Text('Something went wrong!!!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text('Okay'),
                ),
              ],
            ),);
      }
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: Form(
                key: _key,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: InputDecoration(label: Text('Title')),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          imageUrl: _editedProduct.imageUrl,
                          description: _editedProduct.description,
                          title: value as String,
                          price: _editedProduct.price,
                          id: _editedProduct.id,
                          isFavourite: _editedProduct.isFavourite,
                        );
                      },
                      validator: (value) {
                        if ((value as String).isEmpty) {
                          return 'Please enter some text';
                        } else {
                          return null;
                        }
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['price'],
                      focusNode: _priceFocusNode,
                      decoration: InputDecoration(label: Text('Price')),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          imageUrl: _editedProduct.imageUrl,
                          description: _editedProduct.description,
                          title: _editedProduct.title,
                          price: double.parse(value!),
                          id: _editedProduct.id,
                          isFavourite: _editedProduct.isFavourite,
                        );
                      },
                      validator: (value) {
                        if ((value as String).isEmpty) {
                          return 'Add a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Add a number';
                        }
                        if (double.parse(value) > 0) {
                          return null;
                        } else {
                          return 'Add price more than 0';
                        }
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      focusNode: _descriptionFocusNode,
                      decoration: InputDecoration(label: Text('Description')),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      onSaved: (value) {
                        _editedProduct = Product(
                          imageUrl: _editedProduct.imageUrl,
                          description: value as String,
                          title: _editedProduct.title,
                          price: _editedProduct.price,
                          id: _editedProduct.id,
                          isFavourite: _editedProduct.isFavourite,
                        );
                      },
                      validator: (value) {
                        if ((value as String).isEmpty) {
                          return 'Please enter some text';
                        } else {
                          return null;
                        }
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Center(
                                  child: Text(
                                    'Enter ImageUrl',
                                  ),
                                )
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            focusNode: _imageUrlFocusNode,
                            controller: _imageUrlController,
                            textInputAction: TextInputAction.done,
                            decoration:
                                InputDecoration(label: Text('ImageUrl')),
                            keyboardType: TextInputType.url,
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            onSaved: (value) {
                              _editedProduct = Product(
                                imageUrl: value as String,
                                description: _editedProduct.description,
                                title: _editedProduct.title,
                                price: _editedProduct.price,
                                id: _editedProduct.id,
                                isFavourite: _editedProduct.isFavourite,
                              );
                            },
                            validator: (value) {
                              if ((value as String).isEmpty) {
                                return 'Please enter some text';
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
