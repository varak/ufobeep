import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_state.g.dart';

// App State Provider
@riverpod
class AppState extends _$AppState {
  @override
  AppStateModel build() {
    return const AppStateModel(
      isInitialized: false,
      isOnline: true,
      currentUserId: null,
    );
  }

  void setInitialized(bool initialized) {
    state = state.copyWith(isInitialized: initialized);
  }

  void setOnlineStatus(bool online) {
    state = state.copyWith(isOnline: online);
  }

  void setCurrentUser(String? userId) {
    state = state.copyWith(currentUserId: userId);
  }
}

// App State Model
class AppStateModel {
  const AppStateModel({
    required this.isInitialized,
    required this.isOnline,
    required this.currentUserId,
  });

  final bool isInitialized;
  final bool isOnline;
  final String? currentUserId;

  AppStateModel copyWith({
    bool? isInitialized,
    bool? isOnline,
    String? currentUserId,
  }) {
    return AppStateModel(
      isInitialized: isInitialized ?? this.isInitialized,
      isOnline: isOnline ?? this.isOnline,
      currentUserId: currentUserId ?? this.currentUserId,
    );
  }
}