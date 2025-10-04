import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class week5 extends StatefulWidget {
  const week5({super.key});
  @override
  State<week5> createState() => _ApiExampleListState();
}

class _ApiExampleListState extends State<week5> {
  @override
  void initState() {
    super.initState();
    fetchAllProduct();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        actions: [
          ElevatedButton(
            onPressed: () {
              fetchAllProduct();
            }, 
            child: Icon(Icons.refresh)
          ),
          // ElevatedButton(
          //   onPressed: () {
          //     createProduct();
          //     fetchAllProduct();
          //   }, 
          //   child: Icon(Icons.add)
          // )
        ],
      ),
      body: ListView.separated(
        itemCount: listProduct.length,
        itemBuilder: (BuildContext context, int index){
          return ListTile(
            leading: Text('${listProduct[index].id}'),
            title: Text('${listProduct[index].name}'),
            subtitle: Text('${listProduct[index].description}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                  Text('${listProduct[index].price}',
                      style: TextStyle(color: Colors.green, fontSize: 15)),

                  IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _showProductForm(isEdit: true, product: listProduct[index]);
                  },
                ),

                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: const Text('Are you sure you want to delete this product?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'Cancel'),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'OK'),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == 'OK') {
                      await deleteProduct(idDelete: listProduct[index].id);
                      fetchAllProduct();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🗑️ Delete Success!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider();
        }, 
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showProductForm(isEdit: false);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showProductForm({bool isEdit = false, Product? product}) {
  final nameController = TextEditingController(text: isEdit ? product?.name : '');
  final descController = TextEditingController(text: isEdit ? product?.description : '');
  final priceController = TextEditingController(text: isEdit ? product?.price.toString() : '');

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(isEdit ? 'Edit Product' : 'Add Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: descController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Price'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (isEdit) {
                await updateProduct(
                  idUpdate: product!.id,
                  name: nameController.text,
                  description: descController.text,
                  price: priceController.text,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('✏️ Update Success!'), backgroundColor: Colors.blue),
                );
              } else {
                await createProduct(
                  name: nameController.text,
                  description: descController.text,
                  price: priceController.text,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('✅ Add Success!'), backgroundColor: Colors.green),
                );
              }
              fetchAllProduct();
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      );
    },
  );
}


  Product? product;
  List<Product> listProduct = [];

  void fetchAllProduct() async {
    try {
      var response = await http
          .get(Uri.parse('http://localhost:8001/products'));
          if (response.statusCode == 200) {
            List<dynamic> jsonList = jsonDecode(response.body);
            setState(() {
              listProduct = jsonList.map((item) => Product.fromJson(item)).toList();
            });
          }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> createProduct({required String name, required String description, required String price}) async {
    try {
      var response = await http.post(
        Uri.parse('http://localhost:8001/products'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "description": description,
          "price": price,
        }),
      );
      if (response.statusCode == 200) {
        fetchAllProduct();
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> updateProduct({required dynamic idUpdate, required String name, required String description, required String price}) async {
  try {
    var response = await http.put(
      Uri.parse('http://localhost:8001/products/$idUpdate'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "description": description,
        "price": price,
      }),
    );
    if (response.statusCode == 200) {
      fetchAllProduct();
    }
  } catch (e) {
    print('Error: $e');
  }
}

  Future<void> deleteProduct({dynamic idDelete = "44b7"}) async {
    try {
      var response = await http.delete(Uri.parse('http://localhost:8001/products/$idDelete'));
        if (response.statusCode == 200) {
          List<dynamic> jsonList = jsonDecode(response.body);
          setState(() {
            listProduct = jsonList.map((item) => Product.fromJson(item)).toList();
          });
        }
    } catch (e) {
      print('Error: $e');
    }
  }
}

// Model Class
class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  // Constructor
  Product(this.id, this.name, this.description, this.price);
  // แปลง JSON เป็น Object
  Product.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        description = json['description'],
        price = json['price'];
  // แปลง Object เป็น JSON Map
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description, 'price': price};
  }
}