import 'package:flutter/material.dart';
import 'package:golekmakanrek_mobile/models/post.dart';
import 'package:golekmakanrek_mobile/models/comment.dart';
import 'package:golekmakanrek_mobile/screens/forum/post_form.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class ForumPage extends StatefulWidget {
  const ForumPage({Key? key}) : super(key: key);

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  List<Post> _posts = [];
  Map<int, String> _users = {};
  Map<int, List<Comment>> postComments = {};
  Map<String, String> _restaurants = {};
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isFetching = false;

  // For debugging raw JSON response
  String _rawPostResponse = '';

  // Example: Hardcode the current user ID if you’re not yet retrieving from the login:
  int currentUserId = 1; // Replace with your actual user ID after login

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = context.read<CookieRequest>();
      fetchData(request);
    });
  }

  // --------------------------------------------------------
  // FETCH DATA (USERS, POSTS, COMMENTS, RESTAURANTS)
  // --------------------------------------------------------
  Future<void> fetchData(CookieRequest request) async {
    if (_isFetching) return;
    _isFetching = true;
    try {
      // 1. Fetch posts (which now include likeCount and isLiked from Django)
      final postResponse = await request.get(
        'https://ideal-eureka-r4gxwv6xrv5gh5565-8000.app.github.dev/forum/post_json/',
      );

      // Save raw JSON for debugging
      setState(() {
        _rawPostResponse = jsonEncode(postResponse);
      });

      List<dynamic> postData = postResponse;

      // 2. Fetch comments
      final commentResponse = await request.get(
        'https://ideal-eureka-r4gxwv6xrv5gh5565-8000.app.github.dev/forum/comment_json/',
      );
      List<dynamic> commentData = commentResponse;

      // 3. Fetch user list (get_all_users)
      final userResponse = await request.get(
        'https://ideal-eureka-r4gxwv6xrv5gh5565-8000.app.github.dev/forum/get_all_users/',
      );
      List<dynamic> userData = userResponse['users'];

      // 4. Fetch restaurants
      final restaurantResponse = await request.get(
        'https://ideal-eureka-r4gxwv6xrv5gh5565-8000.app.github.dev/forum/restaurant_json/',
      );
      List<dynamic> restaurantData = restaurantResponse;

      // Build _users map (userId -> username)
      Map<int, String> fetchedUsers = {};
      for (var user in userData) {
        int userId = user['id'];
        String username = user['username'];
        fetchedUsers[userId] = username;
      }

      // Convert postData to Post objects
      List<Post> fetchedPosts =
          postData.map((item) => Post.fromJson(item)).toList();

      // Create comments map: postId -> list of Comments
      Map<int, List<Comment>> commentsMap = {};
      for (var item in commentData) {
        Comment comment = Comment.fromJson(item);
        if (comment.fields.post != null) {
          commentsMap.putIfAbsent(comment.fields.post!, () => []).add(comment);
        }
      }

      // Build restaurants map (id -> name)
      Map<String, String> fetchedRestaurants = {};
      for (var item in restaurantData) {
        String restaurantId = item['pk'].toString(); // PK is numeric
        String restaurantName = item['fields']['nama'];
        fetchedRestaurants[restaurantId] = restaurantName;
      }

      // Update state
      setState(() {
        _users = fetchedUsers;
        _posts = fetchedPosts;
        postComments = commentsMap;
        _restaurants = fetchedRestaurants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    } finally {
      _isFetching = false;
    }
  }

  // --------------------------------------------------------
  // REFRESH
  // --------------------------------------------------------
  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    final request = context.read<CookieRequest>();
    await fetchData(request);
  }

  // --------------------------------------------------------
  // GET USERNAME BY USER ID
  // --------------------------------------------------------
  String getUsername(int userId) {
    return _users[userId] ?? 'Unknown User';
  }

  // --------------------------------------------------------
  // BUILD
  // --------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove the floatingActionButton, and instead build a custom header
      body: SafeArea(
        child: Container(
          color: Colors.grey[200],
          child: Column(
            children: [
              // -----------------------------------------
              // HEADER: Yellow background, big text, copywriting, and a green "Posting di Forum" button
              // -----------------------------------------
              Container(
                color: Colors.yellow[700],
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Jelajahi Makanan di Surabaya!",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Berbagi cerita bersama kulineran di Surabaya!",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CreatePostPage()),
                        );
                        if (result == true) {
                          _refreshData();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text("Posting di Forum"),
                    ),
                  ],
                ),
              ),

              // -----------------------------------------
              // MAIN CONTENT: List of Posts (or error/loading)
              // -----------------------------------------
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                        ? _buildErrorView()
                        : _buildPostListView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------
  // ERROR VIEW
  // --------------------------------------------------------
  Widget _buildErrorView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Terjadi Kesalahan:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Display error message
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
            onPressed: _refreshData,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text("Coba Lagi"),
          ),

          // Debug: Show raw post response if needed
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: SelectableText(
                _rawPostResponse.isNotEmpty
                    ? _rawPostResponse
                    : "No data available.",
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------
  // POSTS LIST VIEW
  // --------------------------------------------------------
  Widget _buildPostListView() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          final comments = postComments[post.pk] ?? [];
          final username = getUsername(post.fields.user);

          // Restaurant name (if any)
          final restaurantName = post.fields.restaurant != null
              ? _restaurants[post.fields.restaurant] ?? 'Unknown Restaurant'
              : null;

          return PostCard(
            post: post,
            comments: comments,
            username: username,
            onPostUpdated: _refreshData,
            currentUserId: currentUserId,
            restaurantName: restaurantName,
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PostCard: menampilkan detail Post + Aksi
// ---------------------------------------------------------------------------
class PostCard extends StatefulWidget {
  final Post post;
  final List<Comment> comments;
  final String username; // Display name of the post owner
  final VoidCallback onPostUpdated;
  final int currentUserId; // ID of the currently logged-in user
  final String? restaurantName;

  const PostCard({
    Key? key,
    required this.post,
    required this.comments,
    required this.username,
    required this.onPostUpdated,
    required this.currentUserId,
    required this.restaurantName,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool showComments = false;
  bool isLiked = false;
  int likeCount = 0;

  @override
  void initState() {
    super.initState();
    // Retrieve 'likeCount' and 'isLiked' from the post object
    likeCount = widget.post.fields.likeCount;
    isLiked = widget.post.fields.isLiked;
  }

  // --------------------------------------------------------
  // TOGGLE LIKE
  // --------------------------------------------------------
  Future<void> toggleLike() async {
    try {
      final request = context.read<CookieRequest>();
      final response = await request.post(
        'https://ideal-eureka-r4gxwv6xrv5gh5565-8000.app.github.dev/forum/like_post_flutter/',
        {
          'post_id': widget.post.pk.toString(),
        },
      );
      if (response['status'] == 'success') {
        setState(() {
          isLiked = response['liked'];
          likeCount = response['like_count'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal like: ${response['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error like: $e")),
      );
    }
  }

  // --------------------------------------------------------
  // DELETE POST
  // --------------------------------------------------------
  Future<void> deletePost() async {
    try {
      final request = context.read<CookieRequest>();
      final response = await request.post(
        'https://ideal-eureka-r4gxwv6xrv5gh5565-8000.app.github.dev/forum/delete_post_flutter/',
        {
          'post_id': widget.post.pk.toString(),
        },
      );
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post berhasil dihapus!")),
        );
        widget.onPostUpdated(); // Refresh the posts list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menghapus post: ${response['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error menghapus post: $e")),
      );
    }
  }

  // --------------------------------------------------------
  // SHOW DELETE CONFIRMATION DIALOG
  // --------------------------------------------------------
  void _confirmDeletePost() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text("Konfirmasi Hapus"),
          content: const Text("Apakah Anda yakin ingin menghapus postingan ini?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close the dialog
                deletePost();          // then proceed
              },
              child: const Text("Hapus", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------------------------
  // POST COMMENT
  // --------------------------------------------------------
  Future<void> postComment(String commentText) async {
    try {
      final request = context.read<CookieRequest>();
      final response = await request.post(
        'https://ideal-eureka-r4gxwv6xrv5gh5565-8000.app.github.dev/forum/comment_post_flutter/',
        {
          'post_id': widget.post.pk.toString(),
          'comment': commentText,
        },
      );

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Komentar berhasil ditambahkan!")),
        );
        // Add the new comment to the local list
        final newComment = Comment.fromJson(response['comment']);
        setState(() {
          widget.comments.add(newComment);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal komentar: ${response['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error komentar: $e")),
      );
    }
  }

  // --------------------------------------------------------
  // BUILD
  // --------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final comments = widget.comments;
    bool canDeletePost = (post.fields.user == widget.currentUserId);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Card(
        // White card on top of grey background
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------------------------------
              // Top Row: Profile icon + name/date (left), Delete button (right if canDelete)
              // ---------------------------------------
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile icon
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 8),

                  // Username & date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(post.fields.createdAt),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Delete button if user owns the post
                  if (canDeletePost)
                    IconButton(
                      onPressed: _confirmDeletePost,
                      icon: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                    ),
                ],
              ),

              // ---------------------------------------
              // Restaurant name (if present)
              // ---------------------------------------
              if (widget.restaurantName != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    widget.restaurantName!,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.orange,
                      fontSize: 14,
                    ),
                  ),
                ),

              // ---------------------------------------
              // Post text
              // ---------------------------------------
              if (post.fields.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  post.fields.text,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],

              // ---------------------------------------
              // Post image (if any)
              // ---------------------------------------


              // ---------------------------------------
              // Action row: Like, Comment, Share, Report
              // ---------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Like icon + count
                  Row(
                    children: [
                      IconButton(
                        onPressed: toggleLike,
                        icon: Icon(
                          isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                          color: isLiked ? Colors.blue : Colors.grey,
                        ),
                      ),
                      Text("$likeCount"),
                    ],
                  ),
                  IconButton(
                    onPressed: () => setState(() {
                      showComments = !showComments;
                    }),
                    icon: const Icon(Icons.comment_outlined),
                  ),
                  IconButton(
                    onPressed: () => sharePost(context),
                    icon: const Icon(Icons.share_outlined),
                  ),
                  IconButton(
                    onPressed: _showReportDialog,
                    icon: const Icon(Icons.flag_outlined, color: Colors.red),
                  ),
                ],
              ),

              // ---------------------------------------
              // Comments Section
              // ---------------------------------------
              if (showComments) _buildCommentsSection(comments),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------
  // COMMENTS SECTION
  // --------------------------------------------------------
  Widget _buildCommentsSection(List<Comment> comments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ...comments.map((c) => _buildCommentItem(c)).toList(),
        const SizedBox(height: 8),
        _buildCommentInput(),
      ],
    );
  }

  // --------------------------------------------------------
  // BUILD SINGLE COMMENT ITEM
  // --------------------------------------------------------
  Widget _buildCommentItem(Comment comment) {
    // In a real app, you’d want a user map: userId->username
    // For simplicity, we are using `widget.username` only for the post owner.
    // You could also pass in a dictionary of userId->username and do:
    // final commentOwnerName = _users[comment.fields.user] ?? "Unknown User";
    final bool canEditComment = (comment.fields.user == widget.currentUserId);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show only user ID or some placeholder since we don't have a direct name lookup:
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black),
                children: [
                  TextSpan(
                    text: "User ${comment.fields.user}: ",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: comment.fields.text,
                  ),
                ],
              ),
            ),
          ),
          // Edit icon if user can edit
          if (canEditComment)
            IconButton(
              onPressed: () => _editCommentDialog(comment),
              icon: const Icon(Icons.edit, color: Colors.blue),
              tooltip: "Edit Komentar",
            ),
        ],
      ),
    );
  }

  // --------------------------------------------------------
  // COMMENT INPUT
  // --------------------------------------------------------
  Widget _buildCommentInput() {
    final TextEditingController commentController = TextEditingController();
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: commentController,
            decoration: const InputDecoration(
              hintText: "Tambah komentar...",
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            final text = commentController.text.trim();
            if (text.isNotEmpty) {
              postComment(text);
              commentController.clear();
            }
          },
          icon: const Icon(Icons.send),
        ),
      ],
    );
  }

  // --------------------------------------------------------
  // EDIT COMMENT DIALOG
  // --------------------------------------------------------
  void _editCommentDialog(Comment comment) {
    final TextEditingController editController =
        TextEditingController(text: comment.fields.text);

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text("Edit Komentar"),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(
              hintText: "Masukkan komentar baru...",
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _editComment(comment, editController.text.trim());
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------------------------
  // EDIT COMMENT LOGIC
  // --------------------------------------------------------
  Future<void> _editComment(Comment comment, String newContent) async {
    if (newContent.isEmpty) return;
    try {
      final request = context.read<CookieRequest>();
      final response = await request.post(
        'https://ideal-eureka-r4gxwv6xrv5gh5565-8000.app.github.dev/forum/edit_comment_flutter/',
        {
          'comment_id': comment.pk.toString(),
          'text': newContent,
        },
      );

      if (response['status'] == 'success') {
        setState(() {
          // Update comment text locally
          comment.fields.text = newContent;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Komentar berhasil diedit!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal edit komentar: ${response['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error edit komentar: $e")),
      );
    }
  }

  // --------------------------------------------------------
  // FORMAT DATE
  // --------------------------------------------------------
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // --------------------------------------------------------
  // REPORT POST
  // --------------------------------------------------------
  Future<void> reportPost(String reason) async {
    try {
      final request = context.read<CookieRequest>();
      final response = await request.post(
        'https://ideal-eureka-r4gxwv6xrv5gh5565-8000.app.github.dev/forum/report_post_flutter/',
        {
          'post_id': widget.post.pk.toString(),
          'reason': reason,
        },
      );

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? "Postingan berhasil dilaporkan!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal melaporkan: ${response['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error melaporkan post: $e")),
      );
    }
  }

  // --------------------------------------------------------
  // SHOW REPORT DIALOG
  // --------------------------------------------------------
  void _showReportDialog() {
    String selectedReason = "Konten Tidak Pantas"; // Default selected reason
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text("Laporkan Postingan"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateSB) {
              return DropdownButton<String>(
                value: selectedReason,
                items: <String>[
                  "Konten Tidak Pantas",
                  "Spam atau Iklan",
                  "Bahasa Kasar atau Menyinggung",
                  "Misinformasi",
                  "Topik Tidak Relevan"
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newVal) {
                  setStateSB(() {
                    selectedReason = newVal ?? "Konten Tidak Pantas";
                  });
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close the dialog
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                reportPost(selectedReason); // Call the report function
              },
              child: const Text("Kirim"),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Utility: sharePost (example placeholder to copy link / share, etc.)
// ---------------------------------------------------------------------------
void sharePost(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("URL telah disalin!")),
  );
}

// ---------------------------------------------------------------------------
// Example: CreatePostPage – your existing screen to add new post
// ---------------------------------------------------------------------------
class CreatePostPage extends StatelessWidget {
  const CreatePostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buat Post Baru"),
      ),
      body: Center(
        child: Text("Form untuk buat postingan..."),
      ),
    );
  }
}
