import 'movie_model.dart';

class SessionMember {
  final int id;
  final int userId;
  final String email;
  final String status;
  final DateTime? joinedAt;

  SessionMember({
    required this.id,
    required this.userId,
    required this.email,
    required this.status,
    this.joinedAt,
  });

  factory SessionMember.fromJson(Map<String, dynamic> json) {
    return SessionMember(
      id: json['id'] as int,
      userId: json['userId'] as int,
      email: json['email'] as String,
      status: json['status'] as String,
      joinedAt: json['joinedAt'] != null
          ? DateTime.tryParse(json['joinedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'email': email,
      'status': status,
      'joinedAt': joinedAt?.toIso8601String(),
    };
  }

  bool get isAccepted => status == 'accepted';
  bool get isPending => status == 'pending';
  bool get isDeclined => status == 'declined';
}

class GroupSession {
  final int id;
  final String sessionCode;
  final int creatorId;
  final String? mood;
  final bool isActive;
  final DateTime createdAt;
  final List<SessionMember> members;

  GroupSession({
    required this.id,
    required this.sessionCode,
    required this.creatorId,
    this.mood,
    required this.isActive,
    required this.createdAt,
    required this.members,
  });

  factory GroupSession.fromJson(Map<String, dynamic> json) {
    return GroupSession(
      id: json['id'] as int,
      sessionCode: json['sessionCode'] as String,
      creatorId: json['creatorId'] as int,
      mood: json['mood'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      members:
          (json['members'] as List<dynamic>?)
              ?.map((e) => SessionMember.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionCode': sessionCode,
      'creatorId': creatorId,
      'mood': mood,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'members': members.map((e) => e.toJson()).toList(),
    };
  }

  bool isCreator(int? currentUserId) => currentUserId == creatorId;
}

class GroupMovie {
  final Movie movie;
  final double groupScore;
  final Map<String, double> userScores;
  final String groupReason;

  GroupMovie({
    required this.movie,
    required this.groupScore,
    required this.userScores,
    required this.groupReason,
  });

  factory GroupMovie.fromJson(Map<String, dynamic> json) {
    // Determine where movie fields are. Under 'GroupMovieOut', fields like 'id', 'title', etc are flat on the object.
    // So we can parse the Movie directly from the same JSON object.
    final movie = Movie.fromJson(json);

    // Parse userScores
    final scoresMap = <String, double>{};
    if (json['userScores'] is Map<String, dynamic>) {
      (json['userScores'] as Map<String, dynamic>).forEach((key, value) {
        if (value is num) {
          scoresMap[key] = value.toDouble();
        }
      });
    }

    return GroupMovie(
      movie: movie,
      groupScore: (json['groupScore'] as num?)?.toDouble() ?? 0.0,
      userScores: scoresMap,
      groupReason: json['groupReason'] as String? ?? '',
    );
  }
}
