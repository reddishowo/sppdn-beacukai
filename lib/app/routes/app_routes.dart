part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const HOME = _Paths.HOME;
  static const SPLASH = _Paths.SPLASH;
  static const PROFILE = _Paths.PROFILE;
  static const ADD_ACTIVITY = _Paths.ADD_ACTIVITY;
  static const MANAGE_ROOMS = _Paths.MANAGE_ROOMS;
}

abstract class _Paths {
  _Paths._();
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const HOME = '/home';
  static const SPLASH = '/splash';
  static const PROFILE = '/profile';
  static const ADD_ACTIVITY = '/add-activity';
  static const MANAGE_ROOMS = '/manage-rooms';
}
