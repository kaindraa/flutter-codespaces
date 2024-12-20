// lib/main.dart

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:golekmakanrek_mobile/models/food.dart';
import 'package:golekmakanrek_mobile/models/restaurant.dart';
import 'package:golekmakanrek_mobile/models/post.dart';
import 'package:golekmakanrek_mobile/models/like.dart';
import 'package:golekmakanrek_mobile/models/comment.dart';
import 'package:golekmakanrek_mobile/models/report.dart';

void main() {
  
  runApp(MaterialApp(
    home: ForumPage(posts: dummyPosts),
  ));
}

// ---------------------------
// Dummy Data
// ---------------------------

final List<Post> dummyPosts = [
    Post(
    model: "forum.post",
    pk: 1,
    fields: PostFields(
      user: 1,
      text: "Halo! Ini contoh post pertama.",
      image: "",
      likeCount: 5,
      commentCount: 2,
      shareCount: 0,
      reportCount: 0,
      createdAt: DateTime(2024, 12, 19, 14, 30), // Custom date and time
      restaurant: "Angkringan Abas Krian",
    ),
  ),
  Post(
    model: "forum.post",
    pk: 2,
    fields: PostFields(
      user: 2,
      text: "Ini adalah post kedua dari admin.",
      image: "https://via.placeholder.com/150",
      likeCount: 10,
      commentCount: 3,
      shareCount: 1,
      reportCount: 0,
      createdAt: DateTime(2024, 12, 18, 10, 0), // Custom date and time
      restaurant: "",
    ),
  ),
];

final List<Comment> dummyComments = [
  Comment(
    model: "forum.comment",
    pk: 1,
    fields: CommentFields(
      post: 1,
      user: 2,
      text: "Komentar pertama!",
      createdAt: DateTime.now(),
    ),
  ),
  Comment(
    model: "forum.comment",
    pk: 2,
    fields: CommentFields(
      post: 1,
      user: 3,
      text: "Komentar kedua!",
      createdAt: DateTime.now(),
    ),
  ),
  Comment(
    model: "forum.comment",
    pk: 3,
    fields: CommentFields(
      post: 2,
      user: 4,
      text: "Komentar dari admin!",
      createdAt: DateTime.now(),
    ),
  ),
  Comment(
    model: "forum.comment",
    pk: 4,
    fields: CommentFields(
      post: 2,
      user: 5,
      text: "Komentar tambahan!",
      createdAt: DateTime.now(),
    ),
  ),
];

final List<Like> dummyLikes = [
  Like(
    model: "forum.like",
    pk: 1,
    fields: LikeFields(
      post: 1,
      user: 1,
      createdAt: DateTime.now(),
    ),
  ),
  Like(
    model: "forum.like",
    pk: 2,
    fields: LikeFields(
      post: 2,
      user: 2,
      createdAt: DateTime.now(),
    ),
  ),
];

final List<Report> dummyReports = [
  Report(
    model: "forum.report",
    pk: 1,
    fields: ReportFields(
      post: 2,
      reportedBy: 3,
      reason: "Spam atau Iklan",
      createdAt: DateTime.now(),
    ),
  ),
];

// ---------------------------
// ForumPage Widget
// ---------------------------

class ForumPage extends StatelessWidget {
  final List<Post> posts;

  const ForumPage({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    // Associate comments, likes, and reports with posts
    List<Post> enrichedPosts = posts.map((post) {
      List<Comment> postComments = dummyComments.where((c) => c.fields.post == post.pk).toList();
      List<Like> postLikes = dummyLikes.where((l) => l.fields.post == post.pk).toList();
      List<Report> postReports = dummyReports.where((r) => r.fields.post == post.pk).toList();
      
      return Post(
        model: post.model,
        pk: post.pk,
        fields: PostFields(
          user: post.fields.user,
          text: post.fields.text,
          image: post.fields.image,
          likeCount: post.fields.likeCount,
          commentCount: post.fields.commentCount,
          shareCount: post.fields.shareCount,
          reportCount: post.fields.reportCount,
          createdAt: post.fields.createdAt,
          restaurant: post.fields.restaurant,
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text("Jelajahi Makanan di Surabaya!"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          // Associate comments with the post
          final comments = dummyComments.where((c) => c.fields.post == post.pk).toList();
          return PostCard(post: post, comments: comments);
        },
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
                    Text('$likeCount'),
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
                    Text('${post.fields.commentCount}'),
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
