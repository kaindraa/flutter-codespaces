import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _restaurantController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    _restaurantController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Access the CookieRequest instance


        final request = context.read<CookieRequest>();

        // Send the POST request to the Django backend
        
        final response = await request.postJson(
          'https://ideal-eureka-r4gxwv6xrv5gh5565-8000.app.github.dev/forum/create_post_flutter/',
          jsonEncode(<String, dynamic>{
            'text': _textController.text,
            'restaurant_id': _restaurantController.text.isNotEmpty
                ? _restaurantController.text
                : "Kosong",
          }),
        );

        // Check the response
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'])),
          );

          // Navigate back to the forum page
          Navigator.pop(context, true); // Pass true to indicate a new post
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Error creating post.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Post"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const Text(
                      "Post Details",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    // Text Field for Post Text
                    TextFormField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        labelText: "Post Text",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter text for the post.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Text Field for Restaurant ID
                    TextFormField(
                      controller: _restaurantController,
                      decoration: const InputDecoration(
                        labelText: "Restaurant ID (optional)",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        onPressed: _submitPost,
                        child: const Text("Submit"),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
