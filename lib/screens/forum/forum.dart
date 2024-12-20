// lib/main.dart

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:golekmakanrek_mobile/models/food.dart';
import 'package:golekmakanrek_mobile/models/restaurant.dart';
import 'package:golekmakanrek_mobile/models/post.dart';
import 'package:golekmakanrek_mobile/models/like.dart';
import 'package:golekmakanrek_mobile/models/comment.dart';
import 'package:golekmakanrek_mobile/models/report.dart';
import 'package:golekmakanrek_mobile/screens/forum/dummy_data.dart';
import 'package:golekmakanrek_mobile/screens/forum/post_form.dart'; // Import dummy data
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:golekmakanrek_mobile/screens/forum/post_form.dart';

void main() {
  
  runApp(MaterialApp(
    home: ForumPage(),
  ));
}

// ---------------------------
// Dummy Data



// ---------------------------
// ForumPage Widget
// ---------------------------

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  List<Post> _posts = [];
  bool _isLoading = true;
  String _errorMessage = '';
  Map<int, List<Comment>> postComments = {};


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = context.read<CookieRequest>(); // Access the CookieRequest
      fetchPosts(request);
    });
  }

  // Fungsi untuk mengambil data post dari server Django
Future<void> fetchPosts(CookieRequest request) async {
  try {
    // Fetch posts
    final postResponse = await request.get(
      'https://ideal-eureka-r4gxwv6xrv5gh5565-8000.app.github.dev/forum/post_json/',
    );

    // Fetch comments
    final commentResponse = await request.get(
      'https://ideal-eureka-r4gxwv6xrv5gh5565-8000.app.github.dev/forum/comment_json/',
    );

    // Fetch restaurant data
    final restaurantResponse = await request.get(
      'https://ideal-eureka-r4gxwv6xrv5gh5565-8000.app.github.dev/main/restaurant_json/',
    );

    // Decode responses
    List<dynamic> postData = postResponse;
    List<dynamic> commentData = commentResponse;
    List<dynamic> restaurantData = restaurantResponse;

    // Create comments map
    Map<int, List<Comment>> commentsMap = {};
    for (var item in commentData) {
      Comment comment = Comment.fromJson(item);

      if (comment.fields.post != null) {
        commentsMap.putIfAbsent(comment.fields.post!, () => []).add(comment);
      }
    }

    // Create restaurant map
    Map<String, String> restaurantMap = {};
    for (var item in restaurantData) {
      restaurantMap[item['pk']] = item['fields']['nama'];
    }

    // Convert posts to Post objects and replace restaurant UUID with name
    List<Post> fetchedPosts = postData.map((item) {
      Post post = Post.fromJson(item);

      // Replace restaurant UUID with its name if available
      if (post.fields.restaurant != null &&
          restaurantMap.containsKey(post.fields.restaurant)) {
        post.fields.restaurant = restaurantMap[post.fields.restaurant];
      } else {
        post.fields.restaurant = "Unknown Restaurant";
      }

      return post;
    }).toList();

    setState(() {
      _posts = fetchedPosts;
      postComments = commentsMap;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _errorMessage = 'Terjadi kesalahan: $e';
      _isLoading = false;
    });
  }
}
  // Fungsi untuk merefresh daftar post
  Future<void> _refreshPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    final request = context.read<CookieRequest>(); // Retrieve CookieRequest again

    await fetchPosts(request);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Jelajahi Makanan di Surabaya!"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Terjadi Kesalahan:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: SelectableText(
                          _errorMessage,
                          style: const TextStyle(fontSize: 14, color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _refreshPosts(),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      child: const Text("Coba Lagi"),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _refreshPosts,
                child: ListView.builder(
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  final post = _posts[index];
                  // Retrieve comments for the current post from postComments
                  final comments = postComments[post.pk] ?? [];
                  return PostCard(post: post, comments: comments);
                },
              ),
            ),
            floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.orange,
      onPressed: () async {
        // Navigate to CreatePostPage
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreatePostPage()),
        );

        // Refresh posts after returning
        _refreshPosts();
      },
      child: const Icon(Icons.add),
    ),
  );
  

  }
}

// ---------------------------
// PostCard Widget
// ---------------------------

class PostCard extends StatefulWidget {
  final Post post;
  final List<Comment> comments;

  const PostCard({super.key, required this.post, required this.comments});
  
  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool showComments = false;
  int likeCount = 0;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    likeCount = widget.post.fields.likeCount;
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    // ignore: avoid_print
    print("Post user: ${post.fields.user}");
    print("Post text: ${post.fields.text}");
    print("Post image: ${post.fields.image}");
    print("Post restaurant: ${post.fields.restaurant}");

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "User ID: ${post.fields.user}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _formatDate(post.fields.createdAt),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Restaurant Name
            if (post.fields.restaurant != null && post.fields.restaurant!.isNotEmpty)
              Text(
                "Restoran: ${post.fields.restaurant}",
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.orange,
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 8),
            // Post Content
            Text(
              post.fields.text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            if (post.fields.image != null && post.fields.image!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Image.network(post.fields.image!),
              ),
            const SizedBox(height: 16),
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isLiked = !isLiked;
                          likeCount += isLiked ? 1 : -1;
                        });
                      },
                      icon: Icon(
                        isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                        color: isLiked ? Colors.blue : Colors.grey,
                      ),
                    ),
                    // Text('$likeCount'),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          showComments = !showComments;
                        });
                      },
                      icon: const Icon(Icons.comment_outlined),
                    ),
                    // Text('${post.fields.commentCount}'),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Share functionality coming soon!")),
                    );
                  },
                  icon: const Icon(Icons.share_outlined),
                ),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Report functionality coming soon!")),
                    );
                  },
                  icon: const Icon(Icons.flag_outlined, color: Colors.red),
                ),
              ],
            ),
            // Comments Section
            if (showComments)
              Column(
                children: widget.comments.map((comment) => _buildComment(comment)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Widget _buildComment(Comment comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 15,
            child: Icon(Icons.person, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(comment.fields.text),
            ),
          ),
        ],
      ),
    );
  }
}
