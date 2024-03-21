import 'package:mtaa_project/support/observable.dart';

class LayoutConfig extends Observable<LayoutConfig> {
  LayoutConfig._();
  static final instance = LayoutConfig._();

  int get focusedButton => _focusedButton;
  var _focusedButton = 0;
  LayoutConfig setFocusedButton(int value) {
    _focusedButton = value;
    setDirty();
    return this;
  }

  String get title => _title;
  var _title = "Null Page";
  LayoutConfig setTitle(String value) {
    _title = value;
    setDirty();
    return this;
  }
}
