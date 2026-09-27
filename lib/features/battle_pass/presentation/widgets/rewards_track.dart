import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../exports.dart';

/// Лента наград: премиум-тизер (пока премиум не куплен) → уровни → карточка
/// следующего сезона (см. [TrackAppearance.seasonEndTeaser]), поверх —
/// стрелки и плавающее превью ближайшего юбилейного уровня.
class RewardsTrack extends StatefulWidget {
  const RewardsTrack({
    required this.season,
    required this.appearance,
    required this.onClaim,
    required this.onUnlockPremium,
    super.key,
  });

  final BattlePassSeason season;
  final TrackAppearance appearance;
  final void Function(int levelNumber) onClaim;
  final VoidCallback onUnlockPremium;

  @override
  State<RewardsTrack> createState() => _RewardsTrackState();
}

/// Всё, что зависит от позиции скролла. Record сравнивается по значению —
/// ValueNotifier уведомляет только когда что-то из этого реально поменялось.
typedef _ScrollUi = ({
  bool scrolled,
  bool pastFirstItem,
  bool atEnd,
  int? nextMilestone,
});

class _RewardsTrackState extends State<RewardsTrack> {
  /// Все уровни одной ширины (SliverFixedExtentList), поэтому смещение
  /// любого уровня и maxScrollExtent известны точно, а не оцениваются по
  /// построенным детям.
  static const double _levelExtent = TrackGeometry.levelExtent;

  static const double _trackHeight = 300;

  static const _milestoneStep = 10;

  /// Сколько последних плиток должно выйти из-под превью, прежде чем оно
  /// вернётся при обратном скролле от конца трека.
  static const _milestoneReturnLevels = 3;

  static const _arrowScrollLevels = 3;

  /// Доля ширины трека, на которой гаснут обычные края.
  static const _edgeFadeStop = 0.07;

  /// Ширина перехода от чётких плиток к погасшим перед превью юбилейного
  /// уровня.
  static const _milestoneFadeWidth = 150.0;

  /// Расстояние от правого края трека до середины стрелки к юбилейному
  /// уровню — отсюда плитки уже полностью погашены.
  static const _milestoneArrowMidpoint = MilestonePreview.cardSize + 55;

  final _controller = ScrollController();
  final _scrollUi = ValueNotifier<_ScrollUi>((
    scrolled: false,
    pastFirstItem: false,
    atEnd: false,
    nextMilestone: null,
  ));

  double get _leadingExtent => widget.season.premiumOwned
      ? 0
      : PremiumTeaserCluster.width + TrackGeometry.separatorWidth;

  /// Стрелка "назад" появляется, когда первый элемент ушёл за левый край.
  double get _firstItemExtent => widget.season.premiumOwned
      ? _levelExtent
      : PremiumTeaserCluster.width / 3;

  /// Смещение, при котором плитка уровня стоит по центру вьюпорта (в
  /// пределах доступного скролла).
  double _centeredOffset(int level) {
    final position = _controller.position;
    final offset =
        _leadingExtent +
        (level - 1) * _levelExtent -
        (position.viewportDimension - _levelExtent) / 2;
    return offset.clamp(0, position.maxScrollExtent);
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateScrollUi);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToStart());
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollUi.dispose();
    super.dispose();
  }

  /// Начальная позиция: "Конец наград" — сразу у конца трека; с купленным
  /// премиумом — на уровень вперёд; без премиума — с начала, с тизера.
  void _scrollToStart() {
    if (!mounted || !_controller.hasClients) return;
    if (widget.appearance.startScrolledToEnd) {
      _controller.jumpTo(_controller.position.maxScrollExtent);
    } else if (widget.season.premiumOwned) {
      _animateTo(_levelExtent);
    }
    _updateScrollUi();
  }

  void _updateScrollUi() {
    final position = _controller.position;
    final offset = position.pixels;
    _scrollUi.value = (
      scrolled: offset > 0,
      pastFirstItem: offset >= _firstItemExtent,
      atEnd: offset >= position.maxScrollExtent - 1,
      nextMilestone: _nextMilestone(offset),
    );
  }

  /// Ближайший юбилейный уровень (10, 20…), ещё не доскролленный до центра.
  int? _nextMilestone(double offset) {
    final levelCount = widget.season.levels.length;
    int? next;
    for (var m = _milestoneStep; m <= levelCount; m += _milestoneStep) {
      if (offset < _centeredOffset(m)) {
        next = m;
        break;
      }
    }
    // Превью, скрытое у конца трека, при обратном скролле возвращается не
    // сразу — иначе оно тут же накрыло бы собой последние плитки.
    final returnLevel = levelCount - _milestoneReturnLevels;
    if (next != null &&
        _scrollUi.value.nextMilestone == null &&
        returnLevel > 0 &&
        offset >= _centeredOffset(returnLevel)) {
      return null;
    }
    return next;
  }

  void _animateTo(
    double offset, {
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeOutCubic,
  }) {
    if (!_controller.hasClients) return;
    _controller.animateTo(
      offset.clamp(0, _controller.position.maxScrollExtent),
      duration: duration,
      curve: curve,
    );
  }

  void _scrollToMilestone(int level) => _animateTo(_centeredOffset(level));

  void _scrollByLevels(int count) => _animateTo(
    _controller.offset + count * _levelExtent,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
  );

  /// Края ленты гаснут в прозрачность, а не обрезаются под стрелками. До
  /// первого скролла левый край не гаснет — первая плитка ничем не
  /// перекрыта; у карточки следующего сезона не гаснет правый — дальше
  /// скроллить некуда.
  Gradient _fadeGradient(_ScrollUi ui, double width) {
    final colors = context.theme.appColors.mainColors;
    final leftFadeEnd = ui.scrolled ? _edgeFadeStop : 0.0;
    final double rightFadeStart;
    final double rightFadeEnd;
    if (ui.nextMilestone != null) {
      rightFadeEnd = 1 - _milestoneArrowMidpoint / width;
      rightFadeStart =
          1 - (_milestoneArrowMidpoint + _milestoneFadeWidth) / width;
    } else if (!ui.scrolled ||
        (ui.atEnd && widget.appearance.seasonEndTeaser != null)) {
      rightFadeStart = 1;
      rightFadeEnd = 1;
    } else {
      rightFadeStart = 1 - _edgeFadeStop;
      rightFadeEnd = 1;
    }
    return LinearGradient(
      stops: [
        0,
        leftFadeEnd,
        rightFadeStart.clamp(0, 1),
        rightFadeEnd.clamp(0, 1),
      ],
      colors: [
        colors.appColorTransparent,
        colors.appColorBlack,
        colors.appColorBlack,
        colors.appColorTransparent,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appearance = widget.appearance;

    const trackLeft = 346.0;
    const trackRight = 80.0;
    const trackBottom = 24.0;
    const arrowVerticalOffset = 32.0;
    const milestoneArrowGap = 13.0;
    const arrowButtonInset = 8.0;

    return Positioned(
      left: trackLeft,
      right: trackRight,
      bottom: trackBottom,
      height: _trackHeight,
      child: ValueListenableBuilder<_ScrollUi>(
        valueListenable: _scrollUi,
        // Сама лента от позиции скролла не зависит и при её смене не
        // перестраивается — только стрелки, превью и маска краёв.
        child: _TrackList(
          controller: _controller,
          season: widget.season,
          appearance: appearance,
          levelExtent: _levelExtent,
          onClaim: widget.onClaim,
          onUnlockPremium: widget.onUnlockPremium,
        ),
        builder: (context, ui, track) => Stack(
          // Превью юбилейного уровня выше обычной плитки и растёт вверх за
          // пределы трека (см. MilestonePreview).
          clipBehavior: Clip.none,
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  _fadeGradient(ui, bounds.width).createShader(bounds),
              blendMode: BlendMode.dstIn,
              child: track,
            ),
            if (ui.pastFirstItem)
              Positioned(
                left: 0,
                top:
                    MilestonePreview.cardCenterY(_trackHeight) -
                    arrowVerticalOffset,
                child: _ArrowButton(
                  icon: Icons.chevron_left,
                  onTap: () => _scrollByLevels(-_arrowScrollLevels),
                ),
              ),
            if (ui.nextMilestone case final milestone?) ...[
              Positioned(
                right: 0,
                bottom: MilestonePreview.bottomMargin,
                child: MilestonePreview(
                  level: widget.season.levels[milestone - 1],
                  style: appearance.milestonePreview,
                  onTap: () => _scrollToMilestone(milestone),
                ),
              ),
              Positioned(
                right:
                    MilestonePreview.cardSize +
                    milestoneArrowGap -
                    arrowButtonInset,
                top:
                    MilestonePreview.cardCenterY(_trackHeight) -
                    arrowVerticalOffset,
                child: _ArrowButton(
                  icon: Icons.chevron_right,
                  onTap: () => _scrollToMilestone(milestone),
                ),
              ),
            ] else if (!ui.atEnd)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _ArrowButton(
                    icon: Icons.chevron_right,
                    onTap: () => _scrollByLevels(_arrowScrollLevels),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Прокручиваемая лента: тизер и карточка следующего сезона — отдельные
/// слайверы, уровни — список фиксированной ширины.
class _TrackList extends StatelessWidget {
  const _TrackList({
    required this.controller,
    required this.season,
    required this.appearance,
    required this.levelExtent,
    required this.onClaim,
    required this.onUnlockPremium,
  });

  final ScrollController controller;
  final BattlePassSeason season;
  final TrackAppearance appearance;
  final double levelExtent;
  final void Function(int levelNumber) onClaim;
  final VoidCallback onUnlockPremium;

  @override
  Widget build(BuildContext context) {
    final levels = season.levels;
    final seasonEndTeaser = appearance.seasonEndTeaser;

    return CustomScrollView(
      controller: controller,
      scrollDirection: Axis.horizontal,
      slivers: [
        if (!season.premiumOwned)
          SliverToBoxAdapter(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PremiumTeaserCluster(
                  onUnlock: onUnlockPremium,
                  hidePremiumBadge: appearance.hidePremiumBadges,
                ),
                const _TrackSeparator(),
              ],
            ),
          ),
        SliverFixedExtentList(
          itemExtent: levelExtent,
          delegate: SliverChildBuilderDelegate(childCount: levels.length, (
            context,
            i,
          ) {
            final level = levels[i];
            final isLast = i == levels.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RewardTile(
                  level: level,
                  premiumOwned: season.premiumOwned,
                  currentXp: season.currentXp,
                  nextRequiredXp: isLast ? null : levels[i + 1].requiredXp,
                  onClaim: () => onClaim(level.number),
                  onUnlockPremium: onUnlockPremium,
                  hideGiftBadge: appearance.hideGiftBadges,
                  hidePremiumBadge: appearance.hidePremiumBadges,
                  highlighted: appearance.highlightedLevel == level.number,
                  gold: appearance.goldLevel == level.number,
                ),
                // Место под стрелку держится у каждого уровня (ширина
                // фиксированная), но у последнего она видна, только если
                // дальше карточка следующего сезона.
                _TrackSeparator(visible: !isLast || seasonEndTeaser != null),
              ],
            );
          }),
        ),
        if (seasonEndTeaser != null)
          SliverToBoxAdapter(
            child: NextSeasonTeaser(
              maxLevel: levels.length,
              requiresPremium:
                  seasonEndTeaser == SeasonEndTeaser.requiresPremium,
            ),
          ),
      ],
    );
  }
}

/// Стрелка между элементами трека, по центру карточки (а не всей колонки
/// с ромбом).
class _TrackSeparator extends StatelessWidget {
  const _TrackSeparator({this.visible = true});

  static const double width = TrackGeometry.separatorWidth;

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 240,
      child: visible
          ? Center(
              child: SvgPicture.asset(
                AppAssets.iconArrow,
                width: width,
                height: 20,
              ),
            )
          : null,
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.appColors.mainColors;

    const iconSize = 56.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: colors.buttonOverlayStrong,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 84,
            height: 84,
            child: Icon(icon, color: colors.appColorWhite, size: iconSize),
          ),
        ),
      ),
    );
  }
}
