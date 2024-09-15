library shared_value;

import 'dart:async';
import 'dart:math';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_shared_value/src/generic_inherited_model.dart';

import 'inherited_model.dart';
import 'manager_widget.dart';

class SharedValue<T> {
  static final random = Random();
  static final stateManager = StateManagerWidgetState();

  /// Maps a [SharedValue]'s [hashCode] to its [nonce].
  ///
  /// This way [SharedValue] instances can be garbage collected safely.
  static final stateNonceMap = <int, double>{};

  static bool didWrap = false;

  /// Initialize Shared value.
  ///
  /// Internally, this inserts an [InheritedModel] widget into the widget tree.
  ///
  /// This must be done exactly once for the whole application.
  static Component wrapApp(Component app) {
    didWrap = true;
    return StateManagerWidget(
      app,
      stateManager,
      stateNonceMap,
    );
  }

  T _value;

  double? nonce;
  StreamController<T>? _controller;

  SharedValue({
    required T value,
  }) : _value = value {
    _update(init: true);
  }

  /// The value held by this state.
  T get $ => _value;

  /// Update the value and rebuild the dependent widgets if it changed.
  set $(T newValue) {
    setState(() {
      _value = newValue;
    });
  }

  /// Rebuild all dependent widgets.
  R? setState<R>([R? Function()? fn]) {
    if (!didWrap) {
      throw Exception(
        [
          "SharedValue was not initalized.",
          "Did you forget to call SharedValue.wrapApp()?\n"
              "If so, please do it once,"
              "alongside runApp() so that SharedValue can be initalized for you application.\n"
              "Example:\n"
              "\trunApp(SharedValue.wrapApp(MyApp()))",
        ].join('\n'),
      );
    }

    R? ret = fn?.call();

    if (ret is Future) {
      ret.then((_) {
        _update();
      });
    } else {
      _update();
    }

    return ret;
  }

  /// Get the value held by this state,
  /// and also rebuild the widget in [context] whenever [mutate] is called.
  T of(BuildContext? context) {
    if (context != null) {
      InheritedModel.inheritFrom<SharedValueInheritedModel>(
        context,
        aspect: identityHashCode(this),
      );
    }
    return _value;
  }

  /// A stream of [$]s that gets updated every time the internal value is changed.
  Stream<T> get stream {
    _controller ??= StreamController.broadcast();
    return _controller!.stream;
  }

  Stream<T> get streamWithInitial async* {
    yield _value;
    yield* stream;
  }

  /// Set [$] to [value], but only if they're different
  void setIfChanged(T value) {
    if (value == _value) return;
    $ = value;
  }

  /// Set [$] to the return value of [fn],
  /// and rebuild the dependent widgets if it changed.
  void update(T Function(T) fn) {
    $ = fn(_value);
  }

  void _update({bool init = false}) {
    // update the nonce
    nonce = random.nextDouble();
    stateNonceMap[identityHashCode(this)] = nonce!;

    if (!init) {
      // rebuild state manger widget
      stateManager.rebuild();
    }

    // add value to stream
    _controller?.add(_value);
  }

  Future<T> waitUntil(bool Function(T) predicate) async {
    // short-circuit if predicate already satisfied
    if (predicate(_value)) return _value;
    // otherwise, run predicate on every change
    await for (T value in this.stream) {
      if (predicate(value)) break;
    }
    return _value;
  }
}
