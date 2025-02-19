// @dart=2.9
import 'package:orchid/orchid.dart';

/// Support a background color for individual menu items
class ColorPopupMenuItem<T> extends PopupMenuItem<T> {
  final Color color;
  final double height;
  final VoidCallback onTap;
  final EdgeInsets padding;

  const ColorPopupMenuItem({
    Key key,
    T value,
    bool enabled = true,
    Widget child,
    this.color,
    this.height,
    this.onTap,
    this.padding,
  }) : super(
    key: key,
    value: value,
    enabled: enabled,
    height: height,
    onTap: onTap,
    padding: padding,
    child: child,
  );

  @override
  _ColorPopupMenuItemState<T> createState() => _ColorPopupMenuItemState<T>();
}

class _ColorPopupMenuItemState<T>
    extends PopupMenuItemState<T, ColorPopupMenuItem<T>> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.color,
      child: super.build(context),
    );
  }
}
