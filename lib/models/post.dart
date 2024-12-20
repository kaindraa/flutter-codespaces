// To parse this JSON data, do
//
//     final post = postFromJson(jsonString);

import 'dart:convert';

List<Post> postFromJson(String str) => List<Post>.from(json.decode(str).map((x) => Post.fromJson(x)));

String postToJson(List<Post> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Post {
    String model;
    int pk;
    Fields fields;

    Post({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Post.fromJson(Map<String, dynamic> json) => Post(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    int user;
    String text;
    String image;
    int likeCount;
    int commentCount;
    int shareCount;
    int reportCount;
    DateTime createdAt;
    String restaurant;

    Fields({
        required this.user,
        required this.text,
        required this.image,
        required this.likeCount,
        required this.commentCount,
        required this.shareCount,
        required this.reportCount,
        required this.createdAt,
        required this.restaurant,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        user: json["user"],
        text: json["text"],
        image: json["image"],
        likeCount: json["like_count"],
        commentCount: json["comment_count"],
        shareCount: json["share_count"],
        reportCount: json["report_count"],
        createdAt: DateTime.parse(json["created_at"]),
        restaurant: json["restaurant"],
    );

    Map<String, dynamic> toJson() => {
        "user": user,
        "text": text,
        "image": image,
        "like_count": likeCount,
        "comment_count": commentCount,
        "share_count": shareCount,
        "report_count": reportCount,
        "created_at": createdAt.toIso8601String(),
        "restaurant": restaurant,
    };
}
