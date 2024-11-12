import 'package:collection/collection.dart';
import 'package:jaspr/jaspr.dart';
const mapEq = MapEquality(
  keys: DefaultEquality<int>(),
  values: DefaultEquality<double>(),
);

class SharedValueInheritedModel extends InheritedModel<int> {
  final Map<int, double> stateNonceMap;

  const SharedValueInheritedModel({
    super.key,
    required super.child,
    required this.stateNonceMap,
  });

  @override
  bool updateShouldNotify(SharedValueInheritedModel oldComponent) =>
      !mapEq.equals(oldComponent.stateNonceMap, stateNonceMap);

  @override
  bool updateShouldNotifyDependent(
    SharedValueInheritedModel oldComponent,
    Set<int> dependencies,
  ) {
    // Compare the nonce value of this SharedValue,
    // with an older nonce value of the same SharedValue object.
    //
    // If the nonce values are not same,
    // rebuild the widget
    return dependencies.any(
      (sharedValueHash) =>
          stateNonceMap[sharedValueHash] !=
          oldComponent.stateNonceMap[sharedValueHash],
    );
  }
}
