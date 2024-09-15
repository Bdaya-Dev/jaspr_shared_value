import 'package:jaspr/jaspr.dart';
import 'package:jaspr_shared_value/jaspr_shared_value.dart';

Component sharedValueApp(ComponentBuilder builder) {
  return SharedValue.wrapApp(
    Builder(builder: builder),
  );
}

class Button extends StatelessComponent {
  const Button({required this.label, required this.onPressed, super.key});

  final String label;
  final void Function() onPressed;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'button',
      child: Text(label),
      events: {'click': (e) => onPressed()},
    );
  }
}
