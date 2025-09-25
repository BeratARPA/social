import 'package:flutter/material.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';
import 'package:social/views/auth/login_view.dart';
import 'package:social/views/auth/register_view.dart';
import 'package:social/views/auth/send_email_verification_view.dart';
import 'package:social/views/auth/verify_email_view.dart';
import 'package:social/views/general/account_settings_view.dart';
import 'package:social/views/general/chat_view.dart';
import 'package:social/views/general/create_post_view.dart';
import 'package:social/views/general/create_story_view.dart';
import 'package:social/views/general/edit_profile_view.dart';
import 'package:social/views/general/explore_view.dart';
import 'package:social/views/general/home_view.dart';
import 'package:social/views/general/inbox_view.dart';
import 'package:social/views/general/notification_view.dart';
import 'package:social/views/general/profile_view.dart';
import 'package:social/views/general/story_viewer_view.dart';
import 'package:social/views/general/vibes_view.dart';

class AppNavigator {
  static Map<String, Widget Function(BuildContext)> routes = {
    "/create-post": (context) => const CreatePostView(),
    "/account-settings": (context) => const AccountSettingsView(),
    "/edit-profile": (context) => const EditProfileView(),
    "/chat": (context) => const ChatView(),
    "/vibes": (context) => const VibesView(),
    "/profile": (context) => const ProfileView(),
    "/explore": (context) => const ExploreView(),
    "/inbox": (context) => const InboxView(),
    "/notification": (context) => const NotificationView(),
    "/home": (context) => const HomeView(),
    "/story-viewer": (context) => const StoryViewerView(),
    "/create-story": (context) => const CreateStoryView(),
    "/login": (context) => const LoginView(),
    "/register": (context) => const RegisterView(),
    "/send-email-verification": (context) => const SendEmailVerificationView(),
    "/verify-email": (context) => const VerifyEmailView(),
  };

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext? get context => navigatorKey.currentContext;

  static bool get canPop => navigatorKey.currentState!.canPop();

  static Future<T?> push<T extends Object?>(Route<T> route) {
    return navigatorKey.currentState!.push(route);
  }

  static Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushReplacementNamed<T, TO>(
      routeName,
      result: result,
      arguments: arguments,
    );
  }

  static void pop<T extends Object?>([T? result]) {
    return navigatorKey.currentState!.pop(result);
  }

  static void popUntil(bool Function(Route<dynamic>) predicate) {
    navigatorKey.currentState!.popUntil(predicate);
  }

  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String routeName,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate,
      arguments: arguments,
    );
  }

  static Future<T?> showDialog<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: navigatorKey.currentContext!,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context!).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, anim1, anim2) => builder(ctx),
    );
  }

  static Future<T?> pushFullscreenDialog<T>(Widget page) {
    return push<T>(
      MaterialPageRoute<T>(builder: (_) => page, fullscreenDialog: true),
    );
  }

  static void showSnack(String message) {
    ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        backgroundColor: context!.themeValue(
          light: AppColors.lightBackground,
          dark: AppColors.darkBackground,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
        content: Text(
          message,
          style: TextStyle(
            color: context!.themeValue(
              light: AppColors.lightText,
              dark: AppColors.darkText,
            ),
          ),
        ),
      ),
    );
  }

  static void clearSnackbars() {
    ScaffoldMessenger.of(context!).clearSnackBars();
  }
}
