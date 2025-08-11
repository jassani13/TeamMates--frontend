import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

extension BuildContextExt on BuildContext {
  /// Returns same as MediaQuery.of(context)
  MediaQueryData get mq => MediaQuery.of(this);

  /// Returns if Orientation is landscape
  bool get isLandscape => mq.orientation == Orientation.landscape;

  double get statusBarHeight => mq.padding.top;

  double get navigationBarHeight => mq.padding.bottom;

  bool get isKeyboardOpen => 0 < mq.viewInsets.bottom;

  /// Returns same as Keyboard size in px
  double get keyboardHeightPx => mq.viewInsets.bottom;

  /// Returns same as Keyboard size in point
  double get keyboardHeight {
    var actualKeyboardHeight = mq.viewInsets.bottom;
    if (actualKeyboardHeight == 0) return 0.0;
    return mq.size.height * (actualKeyboardHeight / window.physicalSize.height);
  }

  hideKeyboard() {
    final currentFocus = FocusScope.of(this);
    if (!currentFocus.hasPrimaryFocus && currentFocus.hasFocus) {
      FocusManager.instance.primaryFocus!.unfocus();
    }
  }

  SystemUiOverlayStyle get systemOverlayStyle =>
      mq.platformBrightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark;

  //ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  double get bottomPadding => mediaQuery.padding.bottom;

  double get bottomInset => mediaQuery.viewInsets.bottom;

  double bottomPaddingIfNeeded(double defaultPadding) {
    return (0 < mediaQuery.padding.bottom)
        ? mediaQuery.padding.bottom
        : defaultPadding;
  }
}

extension StringX on String? {
  bool get xIsEmpty => this == null || this!.isEmpty;

  bool get xIsNotEmpty => this != null && this!.isNotEmpty;
}

extension SetExt<T> on Set<T> {
  replace(T element) {
    remove(element);
    add(element);
  }
}

extension StringNonNullX on String {
  DateTime parseUtcDateTime([String format = 'yyyy-MM-dd HH:mm:ss']) {
    return DateFormat(format, 'en')
        .parseUTC(replaceAll("T", " ").replaceAll("Z", " "));
  }

  DateTime parseLocalDateTime([String format = 'yyyy-MM-dd HH:mm:ss']) {
    return DateFormat(format, 'en')
        .parse(replaceAll("T", " ").replaceAll("Z", " "))
        .toLocal();
  }
}

extension DateTimeExt on DateTime {
  DateTime date() => DateTime(year, month, day);

  DateTime addDays(int days) => add(Duration(days: days));

  DateTime subtractDays(int days) => subtract(Duration(days: days));

  bool isSameDate(DateTime other) => other.date() == date();

  bool isToday() => DateTime.now().date() == date();

  String toChatHeaderDate(DateFormat dateFormat) {
    var today = DateTime.now().date();
    if (today == date()) return 'Today';
    if (today.subtract(const Duration(days: 1)) == date()) return 'Yesterday';
    return dateFormat.format(this);
  }

  String toFormat(String format, {String locale = 'en'}) =>
      DateFormat(format, locale).format(this);
}

extension ListX<T> on List<T>? {
  T? get firstOrNull {
    return this != null
        ? this!.isEmpty
            ? null
            : this!.first
        : null;
  }

  bool get xIsEmpty {
    if (this == null) return true;
    return this!.isEmpty;
  }

  bool get xIsNotEmpty {
    if (this == null) return false;
    return this!.isNotEmpty;
  }
}

extension ListExt<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;

  T? find(bool Function(T element) test) {
    if (!xIsEmpty) {
      var index = indexWhere(test);
      return -1 < index ? this[index] : null;
    }
    return null;
  }
}

extension $KotlinStyleExtension<T> on T {
  T let(void Function(T) func) {
    func(this);
    return this;
  }

  T apply(void Function() func) {
    func();
    return this;
  }

  R also<R>(R Function(T) func) {
    return func(this);
  }

  R run<R>(R Function() func) {
    return func();
  }
}

String enumToString(Object? o) => o.toString().split('.').last;

T? enumFromString<T>(String? key, List<T> values) =>
    values.firstWhereOrNull((v) => key == enumToString(v));

extension $GetxExtension on GetInterface {
  T deleteAndPut<T>(T dependency, {String? tag}) {
    GetInstance().delete<T>(tag: tag, force: true);
    return Get.put<T>(dependency, tag: tag);
  }

  T? findOrNull<T>({String? tag}) {
    try {
      return Get.find<T>(tag: tag);
    } catch (e) {
      return null;
    }
  }
}
