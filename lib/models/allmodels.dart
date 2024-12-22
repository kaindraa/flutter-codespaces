// // To parse this JSON data, do
// //
// //     final post = postFromJson(jsonString);

// import 'dart:convert';

// List<Post> postFromJson(String str) => List<Post>.from(json.decode(str).map((x) => Post.fromJson(x)));

// String postToJson(List<Post> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class Post {
//     String model;
//     int pk;
//     Fields fields;

//     Post({
//         required this.model,
//         required this.pk,
//         required this.fields,
//     });

//     factory Post.fromJson(Map<String, dynamic> json) => Post(
//         model: json["model"],
//         pk: json["pk"],
//         fields: Fields.fromJson(json["fields"]),
//     );

//     Map<String, dynamic> toJson() => {
//         "model": model,
//         "pk": pk,
//         "fields": fields.toJson(),
//     };
// }

// class Fields {
//     int user;
//     String text;
//     String image;
//     int likeCount;
//     int commentCount;
//     int shareCount;
//     int reportCount;
//     DateTime createdAt;
//     String restaurant;

//     Fields({
//         required this.user,
//         required this.text,
//         required this.image,
//         required this.likeCount,
//         required this.commentCount,
//         required this.shareCount,
//         required this.reportCount,
//         required this.createdAt,
//         required this.restaurant,
//     });

//     factory Fields.fromJson(Map<String, dynamic> json) => Fields(
//         user: json["user"],
//         text: json["text"],
//         image: json["image"],
//         likeCount: json["like_count"],
//         commentCount: json["comment_count"],
//         shareCount: json["share_count"],
//         reportCount: json["report_count"],
//         createdAt: DateTime.parse(json["created_at"]),
//         restaurant: json["restaurant"],
//     );

//     Map<String, dynamic> toJson() => {
//         "user": user,
//         "text": text,
//         "image": image,
//         "like_count": likeCount,
//         "comment_count": commentCount,
//         "share_count": shareCount,
//         "report_count": reportCount,
//         "created_at": createdAt.toIso8601String(),
//         "restaurant": restaurant,
//     };
// }

// // To parse this JSON data, do
// //
// //     final like = likeFromJson(jsonString);


// List<Like> likeFromJson(String str) => List<Like>.from(json.decode(str).map((x) => Like.fromJson(x)));

// String likeToJson(List<Like> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class Like {
//     String model;
//     int pk;
//     Fields fields;

//     Like({
//         required this.model,
//         required this.pk,
//         required this.fields,
//     });

//     factory Like.fromJson(Map<String, dynamic> json) => Like(
//         model: json["model"],
//         pk: json["pk"],
//         fields: Fields.fromJson(json["fields"]),
//     );

//     Map<String, dynamic> toJson() => {
//         "model": model,
//         "pk": pk,
//         "fields": fields.toJson(),
//     };
// }

// class Fields {
//     int post;
//     int user;
//     DateTime createdAt;

//     Fields({
//         required this.post,
//         required this.user,
//         required this.createdAt,
//     });

//     factory Fields.fromJson(Map<String, dynamic> json) => Fields(
//         post: json["post"],
//         user: json["user"],
//         createdAt: DateTime.parse(json["created_at"]),
//     );

//     Map<String, dynamic> toJson() => {
//         "post": post,
//         "user": user,
//         "created_at": createdAt.toIso8601String(),
//     };
// }

// // To parse this JSON data, do
// //
// //     final comment = commentFromJson(jsonString);

// import 'dart:convert';

// List<Comment> commentFromJson(String str) => List<Comment>.from(json.decode(str).map((x) => Comment.fromJson(x)));

// String commentToJson(List<Comment> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class Comment {
//     String model;
//     int pk;
//     Fields fields;

//     Comment({
//         required this.model,
//         required this.pk,
//         required this.fields,
//     });

//     factory Comment.fromJson(Map<String, dynamic> json) => Comment(
//         model: json["model"],
//         pk: json["pk"],
//         fields: Fields.fromJson(json["fields"]),
//     );

//     Map<String, dynamic> toJson() => {
//         "model": model,
//         "pk": pk,
//         "fields": fields.toJson(),
//     };
// }

// class Fields {
//     int post;
//     int user;
//     String text;
//     DateTime createdAt;

//     Fields({
//         required this.post,
//         required this.user,
//         required this.text,
//         required this.createdAt,
//     });

//     factory Fields.fromJson(Map<String, dynamic> json) => Fields(
//         post: json["post"],
//         user: json["user"],
//         text: json["text"],
//         createdAt: DateTime.parse(json["created_at"]),
//     );

//     Map<String, dynamic> toJson() => {
//         "post": post,
//         "user": user,
//         "text": text,
//         "created_at": createdAt.toIso8601String(),
//     };
// }

// // To parse this JSON data, do
// //
// //     final like = likeFromJson(jsonString);

// import 'dart:convert';

// List<Like> likeFromJson(String str) => List<Like>.from(json.decode(str).map((x) => Like.fromJson(x)));

// String likeToJson(List<Like> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class Like {
//     String model;
//     int pk;
//     Fields fields;

//     Like({
//         required this.model,
//         required this.pk,
//         required this.fields,
//     });

//     factory Like.fromJson(Map<String, dynamic> json) => Like(
//         model: json["model"],
//         pk: json["pk"],
//         fields: Fields.fromJson(json["fields"]),
//     );

//     Map<String, dynamic> toJson() => {
//         "model": model,
//         "pk": pk,
//         "fields": fields.toJson(),
//     };
// }

// class Fields {
//     int post;
//     int user;
//     DateTime createdAt;

//     Fields({
//         required this.post,
//         required this.user,
//         required this.createdAt,
//     });

//     factory Fields.fromJson(Map<String, dynamic> json) => Fields(
//         post: json["post"],
//         user: json["user"],
//         createdAt: DateTime.parse(json["created_at"]),
//     );

//     Map<String, dynamic> toJson() => {
//         "post": post,
//         "user": user,
//         "created_at": createdAt.toIso8601String(),
//     };
// }

