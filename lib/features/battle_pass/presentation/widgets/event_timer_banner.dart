import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../exports.dart';

/// Таймер до конца сезона + заголовок ивента рядом с кольцом уровня.
class EventTimerBanner extends StatelessWidget {
  const EventTimerBanner({required this.deadline, super.key});

  final DateTime deadline;

  @override
  Widget build(BuildContext context) {
    const bannerLeft = 513.0;
    const bannerTop = 56.0;

    return Positioned(
      left: bannerLeft,
      top: bannerTop,
      width: 439,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _CountdownTimer(deadline: deadline),
          const SizedBox(height: 8),
          _EventTitle(),
        ],
      ),
    );
  }
}

class _CountdownTimer extends StatelessWidget {
  const _CountdownTimer({required this.deadline});

  final DateTime deadline;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.appColors.mainColors;

    const iconSize = 32.0;

    return Row(
      children: [
        Icon(
          Icons.access_time_rounded,
          size: iconSize,
          color: colors.timerText,
        ),
        const SizedBox(width: 14),
        EventCountdownText(
          deadline: deadline,
          style: theme.appTypography.mobileTypo.medium26.copyWith(
            color: colors.timerText,
          ),
        ),
      ],
    );
  }
}

class _EventTitle extends StatefulWidget {
  const _EventTitle();

  @override
  State<_EventTitle> createState() => _EventTitleState();
}

class _EventTitleState extends State<_EventTitle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.appColors.mainColors;

    // Градиенту важна только высота текста — ширина неизвестна заранее.
    const gradientShaderRect = Rect.fromLTWH(0, 0, 1, 45);
    final titleGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [colors.eventTitleTop, colors.eventTitleBottom],
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // Декоративный отклик на тап: ладонь "дай пять" и искры.
      onTap: () => _controller.forward(from: 0),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Text(
            AppStrings.eventTitle,
            style: theme.appTypography.mobileTypo.semibold48.copyWith(
              foreground: Paint()
                ..shader = titleGradient.createShader(gradientShaderRect),
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => IgnorePointer(
              child: _HighFiveBurst(
                progress: _controller.value,
                color: colors.accentGold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ладонь "дай пять" и разлёт искр вокруг заголовка по тапу.
class _HighFiveBurst extends StatelessWidget {
  const _HighFiveBurst({required this.progress, required this.color});

  /// 0 — анимация не запущена (ничего не рисуем), 1 — полностью прошла.
  final double progress;
  final Color color;

  static const _sparkCount = 8;
  static const _maxRadius = 70.0;
  static const _sparkSize = 14.0;
  static const _handSize = 56.0;

  @override
  Widget build(BuildContext context) {
    if (progress == 0) return const SizedBox.shrink();

    // Ладонь выпрыгивает в первой половине анимации и гаснет во второй;
    // искры летят всю анимацию.
    final handProgress = (progress / 0.5).clamp(0.0, 1.0);
    final handScale = Curves.elasticOut.transform(handProgress);
    final handOpacity =
        1 - Curves.easeIn.transform(((progress - 0.5) / 0.5).clamp(0.0, 1.0));

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        for (var i = 0; i < _sparkCount; i++) _buildSpark(i),
        Opacity(
          opacity: handOpacity,
          child: Transform.scale(
            scale: handScale,
            child: Icon(Icons.pan_tool, size: _handSize, color: color),
          ),
        ),
      ],
    );
  }

  Widget _buildSpark(int index) {
    final angle = 2 * math.pi * index / _sparkCount;
    final distance = Curves.easeOut.transform(progress) * _maxRadius;
    final opacity = 1 - progress;

    return Transform.translate(
      offset: Offset(math.cos(angle) * distance, math.sin(angle) * distance),
      child: Opacity(
        opacity: opacity,
        child: Icon(Icons.star, size: _sparkSize, color: color),
      ),
    );
  }
}
