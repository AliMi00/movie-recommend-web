/// Application constants for Movie Tinder
class AppConstants {
  // App Information
  static const String appName = 'CineJo';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'A movie recommendation web app — swipe, discover, and get personalized picks';

  // UI Constants
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double cardElevation = 8.0;
  static const double bottomSheetBorderRadius = 20.0;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  static const Duration swipeAnimationDuration = Duration(milliseconds: 250);

  // Movie Card Constants
  static const double movieCardAspectRatio = 2 / 3;
  static const double movieCardMaxWidth = 350;
  static const double movieCardStackOffset = 8.0;
  static const int maxMovieCardsInStack = 5;

  // Swipe Gesture Thresholds
  static const double swipeThreshold = 0.4;
  static const double superLikeThreshold = 0.3;
  static const double swipeVelocityThreshold = 300.0;

  // API Constants (for future use)
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p';
  static const String tmdbPosterSize = 'w500';
  static const String tmdbBackdropSize = 'w1280';
  static const int apiTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;

  // Local Storage Keys
  static const String themeKey = 'theme_mode';
  static const String userPreferencesKey = 'user_preferences';
  static const String likedMoviesKey = 'liked_movies';
  static const String dislikedMoviesKey = 'disliked_movies';
  static const String watchHistoryKey = 'watch_history';
  static const String genrePreferencesKey = 'genre_preferences';
  static const String firstTimeUserKey = 'first_time_user';
  // Device-level flag for the pre-auth intro carousel. Deliberately separate
  // from firstTimeUserKey, which tracks whether a signed-in *account* still
  // needs the preferences setup flow — the intro is shown once per install,
  // before anyone has logged in, and survives logout.
  static const String onboardingIntroSeenKey = 'onboarding_intro_seen';
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';

  // Genre Constants
  static const List<String> movieGenres = [
    'Action',
    'Adventure',
    'Animation',
    'Comedy',
    'Crime',
    'Documentary',
    'Drama',
    'Family',
    'Fantasy',
    'History',
    'Horror',
    'Music',
    'Mystery',
    'Romance',
    'Science Fiction',
    'Thriller',
    'War',
    'Western',
  ];

  // Rating Constants
  static const double minRating = 0.0;
  static const double maxRating = 10.0;
  static const double defaultMinRating = 6.0;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxCachePages = 10;

  // Image Placeholder
  static const String moviePosterPlaceholder = 'assets/images/movie_poster_placeholder.png';
  static const String movieBackdropPlaceholder = 'assets/images/movie_backdrop_placeholder.png';
  static const String userAvatarPlaceholder = 'assets/images/user_avatar_placeholder.png';

  // Error Messages
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String networkErrorMessage = 'Network connection error. Please check your internet connection.';
  static const String timeoutErrorMessage = 'Request timeout. Please try again.';
  static const String noMoviesFoundMessage = 'No movies found matching your preferences.';
  static const String loadingMessage = 'Loading amazing movies for you...';

  // Success Messages
  static const String movieLikedMessage = 'Movie added to your favorites!';
  static const String movieDislikedMessage = 'Thanks for the feedback!';
  static const String preferencesUpdatedMessage = 'Preferences updated successfully!';

  // Validation Constants
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;
  static const int minPasswordLength = 8;
  static const int maxOverviewLength = 500;

  // Navigation Route Names
  static const String splashRoute = '/';
  static const String welcomeRoute = '/welcome';
  static const String onboardingRoute = '/onboarding';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String genreSelectionRoute = '/genre-selection';
  static const String homeRoute = '/home';
  static const String discoveryRoute = '/discovery';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';
  static const String watchHistoryRoute = '/watch-history';
  static const String movieDetailsRoute = '/movie-details';
  static const String trailerRoute = '/trailer';
  static const String termsRoute = '/terms';
  static const String privacyRoute = '/privacy';
  static const String accessibilityRoute = '/accessibility';

  // Feature Flags (for progressive development)
  static const bool enableOfflineMode = true;
  static const bool enableNotifications = false;

  // Mock Data Constants
  static const int mockMovieCount = 100;
  static const String mockDataAssetPath = 'assets/mock_data/movies.json';
}
