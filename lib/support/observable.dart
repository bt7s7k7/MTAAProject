import 'dart:collection';

import 'package:flutter/material.dart';

// ignore: prefer_collection_literals
final _values = LinkedHashMap<Observable, int>();
final _roots = <_ObservableRootState>{};

void _ensureRegistration(Observable observable) {
  if (_values.containsKey(observable)) return;
  final index = _values.length;
  _values[observable] = index;
}

void _setDirtyAll() {
  for (final root in _roots) {
    root._setDirty();
  }
}

class ObservableRoot extends StatefulWidget {
  const ObservableRoot({super.key, required this.child});

  final Widget child;

  @override
  State<ObservableRoot> createState() => _ObservableRootState();
}

class _ObservableRootState extends State<ObservableRoot> {
  _ObservableRootState() {
    _roots.add(this);
  }

  var _dirty = false;

  void _setDirty() {
    if (_dirty) return;
    _dirty = true;
    Future.microtask(
      () => setState(() {
        _dirty = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    var result = widget.child;

    for (final observable in _values.keys) {
      result = observable._makeProvider(result);
    }

    return result;
  }

  @override
  void dispose() {
    super.dispose();
    _roots.remove(this);
  }
}

class _ObservableProvider<T extends Observable> extends InheritedWidget {
  factory _ObservableProvider({required Widget child, required T value}) {
    return _ObservableProvider._(
        value: value, version: value._version, child: child);
  }

  const _ObservableProvider._(
      {required super.child, required this.value, required this.version});

  final T value;
  final int version;

  @override
  bool updateShouldNotify(_ObservableProvider<T> oldWidget) {
    return version > oldWidget.version;
  }
}

abstract class Observable<T> {
  void setDirty() {
    _version++;
    _setDirtyAll();
  }

  T bind(BuildContext context) {
    _ensureRegistration(this);
    context.dependOnInheritedWidgetOfExactType<
        _ObservableProvider<Observable<T>>>();
    return this as T;
  }

  var _version = 0;

  InheritedWidget _makeProvider(Widget child) {
    return _ObservableProvider(value: this, child: child);
  }
}
