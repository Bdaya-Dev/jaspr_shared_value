import 'package:jaspr/jaspr.dart';

import 'inherited_model.dart';

class StateManagerWidget extends StatefulComponent {
  final Component child;
  final StateManagerWidgetState state;
  final Map<int, double> stateNonceMap;

  const StateManagerWidget(
    this.child,
    this.state,
    this.stateNonceMap, {
    super.key,
  }) : super();

  @override
  StateManagerWidgetState createState() => state;
}

class StateManagerWidgetState extends State<StateManagerWidget> {
  Future<void> rebuild() async {
    if (!mounted) return;

    setState(() {});
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield SharedValueInheritedModel(
      child: component.child,
      // IMPORTANT!
      // A copy of stateNonceMap must be provided here.
      //
      // If the same object is passed,
      // then SharedValueInheritedModel won't be able to compare nonce values,
      // since the mutations will be propagated throughout the code path.
      stateNonceMap: Map.of(component.stateNonceMap),
    );
  }
}
