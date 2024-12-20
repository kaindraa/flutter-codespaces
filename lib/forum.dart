import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: ForumPage(posts: dummyPosts),
  ));
}

// Define Models
class Post {
  final int id;
  final String user;
  final String text;
  final String? image;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final int reportCount;
  final DateTime createdAt;
  final String? restaurant;
  final List<Like> likes;
  final List<Comment> comments;
  final List<Report> reports;

  Post({
    required this.id,
    required this.user,
    required this.text,
    this.image,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.reportCount,
    required this.createdAt,
    this.restaurant,
    required this.likes,
    required this.comments,
    required this.reports,
  });
}

class Like {
  final int id;
  final int postId;
  final int userId;
  final DateTime createdAt;

  Like({
    required this.id,
    required this.postId,
    required this.userId,
    required this.createdAt,
  });
}

class Comment {
  final int id;
  final int postId;
  final int userId;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.text,
    required this.createdAt,
  });
}

class Report {
  final int id;
  final int postId;
  final int reportedById;
  final String reason;
  final DateTime createdAt;

  Report({
    required this.id,
    required this.postId,
    required this.reportedById,
    required this.reason,
    required this.createdAt,
  });
}

// Dummy Data
final List<Post> dummyPosts = [
  Post(
    id: 1,
    user: "pacil",
    text: "Halo! Ini contoh post pertama.",
    image: null,
    likeCount: 5,
    commentCount: 2,
    shareCount: 0,
    reportCount: 0,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    restaurant: "Angkringan Abas Krian",
    likes: [],
    comments: [
      Comment(
        id: 1,
        postId: 1,
        userId: 2,
        text: "Komentar pertama!",
        createdAt: DateTime.now(),
      ),
      Comment(
        id: 2,
        postId: 1,
        userId: 3,
        text: "Komentar kedua!",
        createdAt: DateTime.now(),
      ),
    ],
    reports: [],
  ),
  Post(
    id: 2,
    user: "admin",
    text: "Ini adalah post kedua dari admin.",
    image: "https://via.placeholder.com/150",
    likeCount: 10,
    commentCount: 3,
    shareCount: 1,
    reportCount: 0,
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    restaurant: null,
    likes: [],
    comments: [
      Comment(
        id: 3,
        postId: 2,
        userId: 4,
        text: "Komentar dari admin!",
        createdAt: DateTime.now(),
      ),
    ],
    reports: [],
  ),
];

// ForumPage Widget
class ForumPage extends StatelessWidget {
  final List<Post> posts;

  const ForumPage({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
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
          return PostCard(post: post);
        },
      ),
    );
  }
}

// PostCard Widget
class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({super.key, required this.post});

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
    likeCount = widget.post.likeCount;
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

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
                  post.user,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _formatDate(post.createdAt),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Restaurant Name
            if (post.restaurant != null)
              Text(
                "Restoran: ${post.restaurant}",
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.orange,
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 8),
            // Post Content
            Text(
              post.text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            if (post.image != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Image.network(post.image!),
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
                    Text('${post.commentCount}'),
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
                children: post.comments.map((comment) => _buildComment(comment)).toList(),
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
              child: Text(comment.text),
            ),
          ),
        ],
      ),
    );
  }
}
