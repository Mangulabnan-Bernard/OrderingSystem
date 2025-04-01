import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();

  String? selectedCategory;
  File? selectedImage;

  List<Map<String, dynamic>> categories = [];
  bool isLoadingCategories = true;
  bool isSubmitting = false; // To track if product is being added

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    setState(() => isLoadingCategories = true);

    try {
      final response = await http.get(Uri.parse('http://192.168.68.112/devops/get_categories.php'));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['categories'] is List) {
          setState(() {
            categories = List<Map<String, dynamic>>.from(jsonResponse['categories']);
            selectedCategory = categories.isNotEmpty ? categories[0]['id'].toString() : null;
          });
        } else {
          showMessage("No categories found.");
        }
      } else {
        showMessage("Failed to fetch categories (Status: ${response.statusCode})");
      }
    } catch (e) {
      showMessage("Error fetching categories: $e");
    } finally {
      setState(() => isLoadingCategories = false);
    }
  }

  Future<void> pickImage() async {
    final params = OpenFileDialogParams(dialogType: OpenFileDialogType.image);
    final filePath = await FlutterFileDialog.pickFile(params: params);

    if (filePath != null) {
      setState(() => selectedImage = File(filePath));
    }
  }

  Future<void> addProduct() async {
    if (isSubmitting) return; // Prevent multiple submissions

    if (nameController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        priceController.text.isEmpty ||
        quantityController.text.isEmpty ||
        selectedCategory == null ||
        selectedImage == null) {
      showMessage("Please fill all fields and select an image.");
      return;
    }

    // Ask for confirmation before adding the product
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Confirm'),
        content: const Text('Are you sure you want to add this product?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text('Yes'),
            onPressed: () async {
              Navigator.pop(context); // Close confirmation dialog
              setState(() => isSubmitting = true); // Disable the button while submitting

              var request = http.MultipartRequest(
                "POST",
                Uri.parse("http://192.168.68.112/devops/add_product.php"),
              );

              request.fields["name"] = nameController.text;
              request.fields["description"] = descriptionController.text;
              request.fields["price"] = priceController.text;
              request.fields["quantity"] = quantityController.text;
              request.fields["category"] = selectedCategory!;
              request.files.add(await http.MultipartFile.fromPath("image", selectedImage!.path));

              try {
                var response = await request.send();
                var responseData = await response.stream.bytesToString();

                var jsonResponse = json.decode(responseData);

                if (jsonResponse["success"] == true) {
                  showMessage("Product added successfully!", success: true);
                  resetForm(); // Reset the form after successful addition
                } else {
                  showMessage("Failed to add product: ${jsonResponse['message']}");
                }
              } catch (e) {
                showMessage("Error: $e");
              } finally {
                setState(() => isSubmitting = false); // Re-enable button
              }
            },
          ),
        ],
      ),
    );
  }

  void resetForm() {
    nameController.clear();
    descriptionController.clear();
    priceController.clear();
    quantityController.clear();
    selectedCategory = null;
    selectedImage = null;
  }

  void showMessage(String message, {bool success = false}) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(success ? 'Success' : 'Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Add Product'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CupertinoTextField(controller: nameController, placeholder: 'Product Name'),
              SizedBox(height: 10),
              CupertinoTextField(controller: descriptionController, placeholder: 'Description'),
              SizedBox(height: 10),
              CupertinoTextField(controller: priceController, placeholder: 'Price', keyboardType: TextInputType.number),
              SizedBox(height: 10),
              CupertinoTextField(controller: quantityController, placeholder: 'Quantity', keyboardType: TextInputType.number),
              SizedBox(height: 10),

              if (isLoadingCategories)
                CupertinoActivityIndicator()
              else
                CupertinoButton(
                  child: Text(selectedCategory == null ? "Select Category" : "Category: ${categories.firstWhere((c) => c['id'].toString() == selectedCategory)['name']}"),
                  onPressed: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (context) => CupertinoActionSheet(
                        title: Text("Select a Category"),
                        actions: categories.map((category) {
                          return CupertinoActionSheetAction(
                            child: Text(category['name']),
                            onPressed: () {
                              setState(() => selectedCategory = category['id'].toString());
                              Navigator.pop(context);
                            },
                          );
                        }).toList(),
                        cancelButton: CupertinoActionSheetAction(
                          child: Text("Cancel"),
                          isDefaultAction: true,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    );
                  },
                ),

              SizedBox(height: 10),
              CupertinoButton(
                child: Text(selectedImage == null ? 'Pick an Image' : 'Change Image'),
                onPressed: pickImage,
              ),
              if (selectedImage != null)
                Image.file(selectedImage!, height: 150, width: 150, fit: BoxFit.cover),
              SizedBox(height: 20),
              CupertinoButton.filled(
                child: Text('Add Product'),
                onPressed: addProduct,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
