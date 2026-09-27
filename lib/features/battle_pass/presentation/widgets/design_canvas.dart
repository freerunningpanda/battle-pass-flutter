import 'package:flutter/widgets.dart';

import '../../../exports.dart';

/// Холст 2320×1080 в координатах Figma, вписанный в экран с сохранением
/// пропорций: на экране другой формы по краям остаются поля цвета фона
/// Scaffold, но ничего не растягивается.
class DesignCanvas extends StatelessWidget {
  const DesignCanvas({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: FittedBox(
        child: SizedBox(
          width: AppDimens.designWidth,
          height: AppDimens.designHeight,
          child: child,
        ),
      ),
    );
  }
}
