// To parse this JSON data, do
//
//     final like = likeFromJson(jsonString);

import 'dart:convert';

List<Like> likeFromJson(String str) => List<Like>.from(json.decode(str).map((x) => Like.fromJson(x)));

String likeToJson(List<Like> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Like {
    String model;
    int pk;
    Fields fields;

    Like({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Like.fromJson(Map<String, dynamic> json) => Like(
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
    int post;
    int user;
    DateTime createdAt;

    Fields({
        required this.post,
        required this.user,
        required this.createdAt,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        post: json["post"],
        user: json["user"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "post": post,
        "user": user,
        "created_at": createdAt.toIso8601String(),
    };
}
