import 'package:dio/dio.dart';
import '../models/group_session_model.dart';

abstract class GroupSessionRepository {
  Future<GroupSession> createSession({String? mood});
  Future<GroupSession> joinSession(String code);
  Future<List<SessionMember>> getSessionMembers(String code);
  Future<GroupSession> inviteMember(String code, String email);
  Future<List<GroupSession>> getPendingInvitations();
  Future<GroupSession> respondToInvitation(int memberId, String response);
  Future<List<GroupMovie>> getGroupRecommendations(String code, {int page = 1, int limit = 20});
  Future<GroupSession> updateSessionMood(String code, String mood);
}

class ApiGroupSessionRepository implements GroupSessionRepository {
  final Dio _dio;

  ApiGroupSessionRepository(this._dio);

  @override
  Future<GroupSession> createSession({String? mood}) async {
    try {
      final res = await _dio.post(
        '/group-sessions',
        data: {
          if (mood != null && mood.isNotEmpty) 'mood': mood,
        },
      );
      return GroupSession.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<GroupSession> joinSession(String code) async {
    try {
      final res = await _dio.post(
        '/group-sessions/join',
        data: {
          'code': code.toUpperCase(),
        },
      );
      return GroupSession.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<SessionMember>> getSessionMembers(String code) async {
    try {
      final res = await _dio.get('/group-sessions/$code/members');
      final data = res.data as List<dynamic>? ?? [];
      return data.map((e) => SessionMember.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<GroupSession> inviteMember(String code, String email) async {
    try {
      final res = await _dio.post(
        '/group-sessions/$code/invite',
        data: {
          'email': email.trim(),
        },
      );
      return GroupSession.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<GroupSession>> getPendingInvitations() async {
    try {
      final res = await _dio.get('/group-sessions/invitations');
      final data = res.data as List<dynamic>? ?? [];
      return data.map((e) => GroupSession.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<GroupSession> respondToInvitation(int memberId, String response) async {
    try {
      final res = await _dio.post(
        '/group-sessions/invitations/$memberId/respond',
        data: {
          'response': response, // 'accepted' or 'declined'
        },
      );
      return GroupSession.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<GroupMovie>> getGroupRecommendations(String code, {int page = 1, int limit = 20}) async {
    try {
      final res = await _dio.get(
        '/group-sessions/$code/recommendations',
        queryParameters: {
          'page': page,
          'page_size': limit,
        },
      );
      final data = res.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => GroupMovie.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<GroupSession> updateSessionMood(String code, String mood) async {
    try {
      final res = await _dio.put(
        '/group-sessions/$code/mood',
        data: {
          'mood': mood.trim(),
        },
      );
      return GroupSession.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}
