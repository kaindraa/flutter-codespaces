import 'package:flutter/material.dart';

class ForumPage extends StatelessWidget {
  const ForumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text("Jelajahi Makanan di Surabaya!"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Tombol "Posting di Forum"
            Container(
              width: double.infinity,
              color: Colors.yellow,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text("Posting di Forum"),
              ),
            ),
            // List of posts
            const PostCard(
              username: "pacil",
              postTime: "3 weeks, 2 days ago",
              restoran: "Angkringan Abas Krian",
              content: "Halo! Ini contoh post pertama.",
            ),
            const PostCard(
              username: "admin",
              postTime: "1 month ago",
              restoran: null,
              content: "Ini adalah post kedua dari admin.",
            ),
          ],
        ),
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final String username;
  final String postTime;
  final String? restoran;
  final String content;

  const PostCard({
    super.key,
    required this.username,
    required this.postTime,
    this.restoran,
    required this.content,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool showComments = false; // Toggle state for comments

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Username and Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.username,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.postTime,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Restoran Name (if exists)
            if (widget.restoran != null)
              Text(
                "Restoran: ${widget.restoran}",
                style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87),
              ),
            const SizedBox(height: 8),
            // Post Content
            Text(widget.content),
            const SizedBox(height: 12),
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text("Like"),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text("Share"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      showComments = !showComments; // Toggle comments
                    });
                  },
                  child: Text(showComments ? "Hide Comments" : "Show Comments"),
                ),
              ],
            ),
            // Comments Section
            if (showComments) const DummyComments(),
          ],
        ),
      ),
    );
  }
}

class DummyComments extends StatelessWidget {
  const DummyComments({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy comments list
    final comments = [
      "Ini komentar pertama!",
      "Komentar kedua, sangat menarik!",
      "Mantap sekali artikelnya, saya suka.",
      "Apakah ada info lebih lanjut?",
      "Terima kasih sudah berbagi pengalaman!",
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...comments.map((comment) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar icon
                    const CircleAvatar(
                      radius: 15,
                      child: Icon(Icons.person, size: 18),
                    ),
                    const SizedBox(width: 8),
                    // Comment text
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(comment),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
