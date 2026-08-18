import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/group_session_model.dart';
import '../../../data/repositories/group_session_repository.dart';
import '../../../data/services/api_client.dart';
import '../../../core/analytics/analytics_service.dart';

final groupSessionRepositoryProvider = Provider<GroupSessionRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiGroupSessionRepository(dio);
});

class ActiveGroupSessionNotifier extends StateNotifier<GroupSession?> {
  final GroupSessionRepository _repository;
  Timer? _refreshTimer;

  ActiveGroupSessionNotifier(this._repository) : super(null);

  Future<void> createSession({String? mood}) async {
    try {
      final session = await _repository.createSession(mood: mood);
      state = session;
      
      AnalyticsService.trackEvent('group_session_created', properties: {
        'mood': mood,
        'code': session.sessionCode,
      });
      
      startLobbyPolling();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> joinSession(String code) async {
    try {
      final session = await _repository.joinSession(code);
      state = session;
      
      AnalyticsService.trackEvent('group_session_joined', properties: {
        'code': code,
      });
      
      startLobbyPolling();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> inviteMember(String email) async {
    final current = state;
    if (current == null) return;
    try {
      final updated = await _repository.inviteMember(current.sessionCode, email);
      state = updated;
      
      AnalyticsService.trackEvent('group_session_member_invited', properties: {
        'code': current.sessionCode,
        'invited_email': email,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshMembers() async {
    final current = state;
    if (current == null) return;
    try {
      final members = await _repository.getSessionMembers(current.sessionCode);
      state = GroupSession(
        id: current.id,
        sessionCode: current.sessionCode,
        creatorId: current.creatorId,
        mood: current.mood,
        isActive: current.isActive,
        createdAt: current.createdAt,
        members: members,
      );
    } catch (_) {}
  }

  void startLobbyPolling() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      refreshMembers();
    });
  }

  void stopLobbyPolling() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  void leaveSession() {
    if (state != null) {
      AnalyticsService.trackEvent('group_session_left', properties: {
        'code': state!.sessionCode,
      });
    }
    stopLobbyPolling();
    state = null;
  }

  Future<void> updateSessionMood(String mood) async {
    final current = state;
    if (current == null) return;
    try {
      final updated = await _repository.updateSessionMood(current.sessionCode, mood);
      state = updated;
      
      AnalyticsService.trackEvent('group_session_mood_updated', properties: {
        'code': current.sessionCode,
        'mood': mood,
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    stopLobbyPolling();
    super.dispose();
  }
}

final activeGroupSessionProvider =
    StateNotifierProvider<ActiveGroupSessionNotifier, GroupSession?>((ref) {
  final repo = ref.watch(groupSessionRepositoryProvider);
  return ActiveGroupSessionNotifier(repo);
});

class PendingInvitationsNotifier extends StateNotifier<AsyncValue<List<GroupSession>>> {
  final GroupSessionRepository _repository;
  Timer? _pollingTimer;

  PendingInvitationsNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchInvitations();
    _startPolling();
  }

  Future<void> fetchInvitations() async {
    try {
      final invites = await _repository.getPendingInvitations();
      state = AsyncValue.data(invites);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      fetchInvitations();
    });
  }

  Future<void> respond(int memberId, String response) async {
    try {
      await _repository.respondToInvitation(memberId, response);
      
      AnalyticsService.trackEvent('group_session_invite_responded', properties: {
        'member_id': memberId,
        'response': response,
      });
      
      await fetchInvitations();
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}

final pendingInvitationsProvider =
    StateNotifierProvider<PendingInvitationsNotifier, AsyncValue<List<GroupSession>>>((ref) {
  final repo = ref.watch(groupSessionRepositoryProvider);
  return PendingInvitationsNotifier(repo);
});

class GroupRecommendationsState {
  final List<GroupMovie> movies;
  final bool isLoading;
  final String? error;
  final int page;
  final bool hasMore;

  const GroupRecommendationsState({
    this.movies = const [],
    this.isLoading = false,
    this.error,
    this.page = 1,
    this.hasMore = true,
  });

  GroupRecommendationsState copyWith({
    List<GroupMovie>? movies,
    bool? isLoading,
    String? error,
    int? page,
    bool? hasMore,
  }) {
    return GroupRecommendationsState(
      movies: movies ?? this.movies,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class GroupRecommendationsNotifier extends StateNotifier<GroupRecommendationsState> {
  final GroupSessionRepository _repository;
  final String _code;

  GroupRecommendationsNotifier(this._repository, this._code)
      : super(const GroupRecommendationsState()) {
    loadRecommendations();
  }

  Future<void> loadRecommendations() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final items = await _repository.getGroupRecommendations(_code, page: state.page);
      state = state.copyWith(
        movies: [...state.movies, ...items],
        isLoading: false,
        page: state.page + 1,
        hasMore: items.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    state = const GroupRecommendationsState();
    await loadRecommendations();
  }
}

final groupRecommendationsProvider = StateNotifierProvider.family<
    GroupRecommendationsNotifier, GroupRecommendationsState, String>((ref, code) {
  final repo = ref.watch(groupSessionRepositoryProvider);
  return GroupRecommendationsNotifier(repo, code);
});
