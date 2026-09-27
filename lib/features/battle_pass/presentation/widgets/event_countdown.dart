import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../exports.dart';

/// Остаток времени до [deadline] в формате "XXд YYч ZZм". Минуты — самая
/// мелкая единица, поэтому перерисовывается раз в минуту, ровно на её смене.
class EventCountdownText extends StatefulWidget {
  const EventCountdownText({
    required this.deadline,
    required this.style,
    super.key,
  });

  final DateTime deadline;
  final TextStyle style;

  @override
  State<EventCountdownText> createState() => _EventCountdownTextState();
}

class _EventCountdownTextState extends State<EventCountdownText> {
  Timer? _ticker;

  Duration get _remaining {
    final left = widget.deadline.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  @override
  void initState() {
    super.initState();
    _scheduleTick();
  }

  @override
  void didUpdateWidget(covariant EventCountdownText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deadline != widget.deadline) _scheduleTick();
  }

  void _scheduleTick() {
    _ticker?.cancel();
    final remaining = _remaining;
    if (remaining == Duration.zero) return;
    final untilNextMinute = remaining - Duration(minutes: remaining.inMinutes);
    _ticker = Timer(untilNextMinute, () {
      setState(() {});
      _scheduleTick();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _remaining;
    return Text(
      '${remaining.inDays}${AppStrings.countdownDaysUnit} '
      '${remaining.inHours % 24}${AppStrings.countdownHoursUnit} '
      '${remaining.inMinutes % 60}${AppStrings.countdownMinutesUnit}',
      style: widget.style,
    );
  }
}
