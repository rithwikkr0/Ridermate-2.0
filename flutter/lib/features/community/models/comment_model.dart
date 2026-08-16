/// RiderMate 2.0 — Canonical Comment Model
class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String authorName;
  final String authorAvatar;
  final String text;
  final String? parentCommentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CommentModel> replies;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.authorName,
    this.authorAvatar = '',
    required this.text,
    this.parentCommentId,
    required this.createdAt,
    required this.updatedAt,
    this.replies = const [],
  });

  CommentModel copyWith({
    String? id,
    String? postId,
    String? userId,
    String? authorName,
    String? authorAvatar,
    String? text,
    String? parentCommentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<CommentModel>? replies,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      text: text ?? this.text,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      replies: replies ?? this.replies,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'text': text,
      'parent_comment_id': parentCommentId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map, {List<CommentModel> replies = const []}) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    return CommentModel(
      id: map['id'] as String,
      postId: map['post_id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      authorName: map['author_name'] as String? ?? 'Rider',
      authorAvatar: map['author_avatar'] as String? ?? '',
      text: map['text'] as String? ?? '',
      parentCommentId: map['parent_comment_id'] as String?,
      createdAt: parseDate(map['created_at']),
      updatedAt: parseDate(map['updated_at']),
      replies: replies,
    );
  }
}
