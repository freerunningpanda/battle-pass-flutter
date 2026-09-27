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
  /// Шаг уровня: плитка (242) + стрелка-разделитель (12). Все уровни одной
  /// ширины (SliverFixedExtentList), поэтому смещение любого уровня и
  /// maxScrollExtent известны точно, а не оцениваются по построенным детям.
  static const double _levelExtent =
      RewardCarouselTile.defaultWidth + _TrackSeparator.width;

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
  static const _milestoneArrowMidpoint = _MilestonePreview._cardSize + 55;

  final _controller = ScrollController();
  final _scrollUi = ValueNotifier<_ScrollUi>((
    scrolled: false,
    pastFirstItem: false,
    atEnd: false,
    nextMilestone: null,
  ));

  double get _leadingExtent => widget.season.premiumOwned
      ? 0
      : PremiumTeaserCluster.width + _TrackSeparator.width;

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
      height: AppSizes.verticalSize300,
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
          // пределы трека (см. _MilestonePreview).
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
                top: _MilestonePreview.cardCenterY - arrowVerticalOffset,
                child: _ArrowButton(
                  icon: Icons.chevron_left,
                  onTap: () => _scrollByLevels(-_arrowScrollLevels),
                ),
              ),
            if (ui.nextMilestone case final milestone?) ...[
              Positioned(
                right: 0,
                bottom: _MilestonePreview._bottomMargin,
                child: _MilestonePreview(
                  level: widget.season.levels[milestone - 1],
                  style: appearance.milestonePreview,
                  onTap: () => _scrollToMilestone(milestone),
                ),
              ),
              Positioned(
                right:
                    _MilestonePreview._cardSize +
                    milestoneArrowGap -
                    arrowButtonInset,
                top: _MilestonePreview.cardCenterY - arrowVerticalOffset,
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
            child: _SeasonEndTeaser(
              maxLevel: levels.length,
              requiresPremium:
                  seasonEndTeaser == SeasonEndTeaser.requiresPremium,
            ),
          ),
      ],
    );
  }
}

/// Плавающее превью ближайшего непройденного юбилейного уровня (10, 20…) —
/// закреплено у правого края трека поверх обычных плиток, увеличено и
/// подсвечено оранжевой рамкой (#DA7128, не путать с зелёной "к клейму
/// готово") с отдельным по цвету свечением (#E23600, blur 45.1 — по спеке
/// из Figma), пока сам уровень не проскроллен в начало. Фон карточки —
/// обычный тёмно-серый (как у прочих плиток), градиент по редкости здесь
/// не показателен: акцент даёт корона + рамка + свечение, а не заливка.
class _MilestonePreview extends StatelessWidget {
  const _MilestonePreview({
    required this.level,
    required this.onTap,
    this.style = MilestonePreviewStyle.regular,
  });

  final BattlePassLevel level;
  final VoidCallback onTap;

  final MilestonePreviewStyle style;

  static const _diamondRotationAngle = 0.785398; // 45°

  static const _cardSize = 268.0;
  static const _spacer = 12.0;
  static const _diamondSize = 34.0;
  static const _bottomMargin = 14.0;

  /// Вертикальный центр самой карточки (без ромба) в координатах области
  /// трека высотой 300 — карточка растёт вверх от общей нижней линии
  /// (`bottom: _bottomMargin`), поэтому её центр заметно выше середины
  /// всей 300-высокой области. Используется, чтобы стрелка-подсказка
  /// указывала на центр карточки, а не терялась ниже неё.
  static double get cardCenterY {
    const columnHeight = _cardSize + _spacer + _diamondSize;
    const columnBottom = AppSizes.verticalSize300 - _bottomMargin;
    const columnTop = columnBottom - columnHeight;
    return columnTop + _cardSize / 2;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.appColors.mainColors;

    const previewGlowBlurRadius = 45.1;
    const previewGlowSpreadRadius = 0.0;

    // Заливка карточки — тёмно-серый вверху, переходящий в тот же оранжевый,
    // что и рамка, ближе к низу (за ящиком), а не ровный серый фон и не
    // сплошной оранжевый на весь фон.
    final cardGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [colors.rewardTileGrayDark, colors.milestonePreviewAccent],
    );

    final reward = level.freeReward;
    // Уже забранный юбилейный уровень (просто ещё не проскроленный мимо —
    // см. _RewardsTrackState._nextMilestone) показывается как обычная
    // забранная плитка: притушен, done.svg вместо короны/подарка в углу,
    // рамка #E9E9F3 4px без свечения вместо оранжевого "к клейму готово" —
    // и, в отличие от остального контента, не тускнеет вместе с ним.
    final claimed = level.state == LevelState.claimed;
    final showCrown = switch (style) {
      MilestonePreviewStyle.regular || MilestonePreviewStyle.maxLevel => true,
      MilestonePreviewStyle.noCrown || MilestonePreviewStyle.plain => false,
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RewardCarouselTile(
          asset: reward?.iconAsset ?? '',
          gradient: cardGradient,
          badge: RewardBadgeKind.premium,
          showBadge: !claimed && showCrown,
          borderColor: (claimed || style == MilestonePreviewStyle.plain)
              ? colors.textPrimary
              : colors.milestonePreviewAccent,
          borderIgnoresOpacity: claimed,
          showGlow: !claimed,
          glowColor: colors.milestonePreviewGlow,
          glowBlurRadius: previewGlowBlurRadius,
          glowSpreadRadius: previewGlowSpreadRadius,
          claimed: claimed,
          onTap: onTap,
          width: _cardSize,
          height: _cardSize,
        ),
        AppSizedBoxes.verticalSizedBoxH12,
        Transform.rotate(
          angle: _diamondRotationAngle,
          child: Container(
            width: _diamondSize,
            height: _diamondSize,
            // Уровень ещё не достигнут — тот же серый, что у непройденного
            // отрезка прогресс-бара под обычными плитками; у макс. уровня
            // подсвечен.
            decoration: BoxDecoration(
              color: style == MilestonePreviewStyle.maxLevel
                  ? colors.milestoneDiamondMaxLevel
                  : colors.trackNodeDefault,
              borderRadius: AppRadius.circular6,
            ),
            child: Transform.rotate(
              angle: -_diamondRotationAngle,
              child: Center(
                child: Text(
                  '${level.number}',
                  style: theme.appTypography.mobileTypo.bold14.copyWith(
                    color: colors.appColorWhite,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Карточка "следующий сезон" в самом конце трека (см.
/// TrackAppearance.seasonEndTeaser) — колонка той же высоты, что и обычная
/// плитка (карточка 240 + отступ 12 + ряд ромбов 34 = 286), чтобы встать в
/// ряд с уровнями трека без отдельного позиционирования.
class _SeasonEndTeaser extends StatelessWidget {
  const _SeasonEndTeaser({
    required this.maxLevel,
    this.requiresPremium = false,
  });

  final int maxLevel;

  /// См. SeasonEndTeaser.requiresPremium — меняет текст карточки на "нужна прокачка" вместо "откроются после уровня N".
  final bool requiresPremium;

  /// Уровень-ориентир следующего "сезона" наград, показанный в конце
  /// прерывистого сегмента — по референсу из Figma.
  static const _nextSeasonLevel = 120;

  @override
  Widget build(BuildContext context) {
    // Тот же левый отступ (21), что у видимой карточки обычной плитки
    // (RewardCarouselTile: left:21 внутри бокса 242 шириной) — иначе
    // расстояние от _TrackSeparator до рамки тизера меньше, чем между ним
    // и обычной плиткой. Правый отступ той же величины — буфер под наклон
    // (kRewardTileSkewAngle): сам Transform не резервирует под сдвиг место
    // в layout, а это последний элемент списка — без запаса справа
    // maxScrollExtent заканчивается раньше, чем скошенный правый край рамки
    // на самом деле дорисован, и его обрезает Viewport.
    return Padding(
      padding: AppPadding.horizontalPadding21,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TeaserCard(maxLevel: maxLevel, requiresPremium: requiresPremium),
          AppSizedBoxes.verticalSizedBoxH12,
          _TeaserTrackRow(
            nextLevel: maxLevel + 1,
            finalLevel: _nextSeasonLevel,
          ),
        ],
      ),
    );
  }
}

class _TeaserCard extends StatelessWidget {
  const _TeaserCard({required this.maxLevel, this.requiresPremium = false});

  final int maxLevel;
  final bool requiresPremium;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.appColors.mainColors;

    // Тот же наклон, что у остальных плиток трека (kRewardTileSkewAngle) —
    // рамка наклонена вместе с фоном, текст внутри контрнаклонён отдельным
    // слоем, чтобы остаться прямым (см. RewardCarouselTile/_ClaimButton).
    // Высота самой рамки (184) и отступ сверху (28) — те же, что у видимой
    // карточки обычной плитки (RewardCarouselTile.cardHeight = height-56 =
    // 240-56=184, top:28 внутри общего слота высотой 240).
    const borderWidth = 1.5;

    return SizedBox(
      height: AppSizes.verticalSize240,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: AppPadding.topPadding28,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.skewX(kRewardTileSkewAngle),
            child: Container(
              width: AppSizes.horizontalSize439,
              height: AppSizes.verticalSize184,
              alignment: Alignment.center,
              padding: AppPadding.horizontalPadding40,
              decoration: BoxDecoration(
                border: Border.all(
                  color: colors.progressRingFill,
                  width: borderWidth,
                ),
                borderRadius: AppRadius.circular24,
              ),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.skewX(-kRewardTileSkewAngle),
                child: Text.rich(
                  TextSpan(
                    style: theme.appTypography.mobileTypo.medium26Tall.copyWith(
                      color: colors.progressRingFill, // = textMuted
                    ),
                    children: requiresPremium
                        ? [
                            TextSpan(
                              text:
                                  '${AppStrings.seasonEndTeaserRewardsPrefix}'
                                  '$maxLevel'
                                  '${AppStrings.seasonEndTeaserRewardsSuffix}',
                            ),
                            const TextSpan(
                              text: AppStrings
                                  .seasonEndTeaserRequiresPremiumMiddle,
                            ),
                            TextSpan(
                              text: AppStrings
                                  .seasonEndTeaserRequiresPremiumSuffix,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                            ),
                          ]
                        : [
                            const TextSpan(
                              text: AppStrings.seasonEndTeaserUnlockPrefix,
                            ),
                            TextSpan(
                              text:
                                  '$maxLevel'
                                  '${AppStrings.seasonEndTeaserUnlockLevelSuffix}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                            ),
                          ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Прерывистый сегмент трека от `nextLevel` (сразу за последним реальным
/// уровнем — его собственный ромб рисует сам RewardTile, здесь не
/// дублируется) до `finalLevel`, по дизайну: сплошная линия к `nextLevel`
/// (продолжает линию последнего реального уровня — сам он её не дорисовывает,
/// см. RewardTile.nextRequiredXp — у последнего уровня трека всегда null),
/// затем зазор, ряд коротких равных чёрточек вместо промежуточных ромбов (их
/// слишком много, чтобы рисовать каждый — тот же язык, что у
/// _ProgressDashes в tasks_teaser_card.dart) и ещё один зазор перед
/// финальным ромбом.
class _TeaserTrackRow extends StatelessWidget {
  const _TeaserTrackRow({required this.nextLevel, required this.finalLevel});

  final int nextLevel;
  final int finalLevel;

  /// Ширины чёрточек пунктира: крайние — короткие, три средних — длиннее и
  /// одного размера между собой (см. дизайн).
  static const _dashWidths = [20.0, 32.0, 32.0, 32.0, 20.0];

  /// Толщина линии — та же, что у обычных соединительных линий трека, см.
  /// _LevelTrackNode._lineThickness в reward_tile.dart (там она приватная,
  /// значение продублировано).
  static const _lineThickness = 10.0;

  /// Расстояние от левого края этого виджета до ПРАВОГО (видимого) края ромба
  /// настоящего последнего уровня (100), чью исходящую линию сам он не
  /// рисует — RewardTile.nextRequiredXp у последнего уровня трека всегда
  /// null: половина его собственного слота (242/2=121) минус половина
  /// диагонали ромба (34·√2/2≈24.04, тот же _diamondHalfSpan, что в
  /// reward_tile.dart) + ширина стрелки-разделителя между элементами списка
  /// (12, см. _TrackSeparator) + левый отступ этого виджета под рамку
  /// карточки (21, см. _SeasonEndTeaser). Останавливается у края ромба, а не
  /// у его центра — этот виджет красится позже (выше по z) реального тайла,
  /// поэтому линия до центра перекрывала бы цифры номера. +6 сверху —
  /// скруглённые углы ромба (borderRadius:6) немного "срезают" его острый
  /// кончик, без запаса между линией и видимым краем оставался зазор.
  static const _backReach = 121.0 - 24.04 + 12.0 + 21.0 + 6.0;

  /// Промежуток между видимыми краями соседних ромбов у обычного сегмента
  /// трека (99→100 и т.п.): _diamondStride − 2·_diamondHalfSpan ≈
  /// 254 − 48.08 ≈ 205.92 (те же константы, что в reward_tile.dart). Обе
  /// линии этого ряда (100→101 и 101→120) — той же длины, несмотря на то что
  /// вторая символически пропускает уровни 102-119.
  static const _standardSegmentGap = 205.92;

  /// Видимая (в пределах этого виджета) часть ведущей линии к 101-му — вместе
  /// с _backReach должна давать _standardSegmentGap.
  static const _leadingLineWidth = _standardSegmentGap - _backReach;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.appColors.mainColors;
    // border-image-source пунктира по дизайну: linear-gradient(90deg,
    // #2D2E34 0%, #5D5D6D 50%, #2D2E34 100%) — сплошной градиент через весь
    // ряд чёрточек (не у каждой свой), поэтому рисуется одним ShaderMask
    // поверх всего Row, а не покраской отдельных Container.
    final dashGradient = LinearGradient(
      colors: [
        colors.screenBackground,
        colors.dashGradientMid,
        colors.screenBackground,
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    return SizedBox(
      width: AppSizes.horizontalSize439,
      height: AppSizes.verticalSize34,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -_backReach,
            top: (AppSizes.verticalSize34 - _lineThickness) / 2,
            width: _backReach,
            height: _lineThickness,
            child: ColoredBox(color: colors.trackNodeDefault),
          ),
          Row(
            children: [
              SizedBox(
                width: _leadingLineWidth,
                child: ColoredBox(
                  color: colors.trackNodeDefault,
                  child: AppSizedBoxes.verticalSizedBoxH10,
                ),
              ),
              _TeaserDiamond(number: nextLevel),
              AppSizedBoxes.horizontalSizedBoxW12,
              ShaderMask(
                shaderCallback: (bounds) => dashGradient.createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < _dashWidths.length; i++) ...[
                      if (i > 0) AppSizedBoxes.horizontalSizedBoxW10,
                      Container(
                        width: _dashWidths[i],
                        height: _lineThickness,
                        decoration: BoxDecoration(
                          color: colors.appColorWhite,
                          borderRadius: BorderRadius.circular(
                            _lineThickness / 2,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              AppSizedBoxes.horizontalSizedBoxW12,
              _TeaserDiamond(number: finalLevel),
            ],
          ),
        ],
      ),
    );
  }
}

class _TeaserDiamond extends StatelessWidget {
  const _TeaserDiamond({required this.number});

  final int number;

  static const _diamondRotationAngle = 0.785398; // 45°

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.appColors.mainColors;

    return Transform.rotate(
      angle: _diamondRotationAngle,
      child: Container(
        width: AppSizes.allSize34,
        height: AppSizes.allSize34,
        decoration: BoxDecoration(
          color: colors.trackNodeDefault,
          borderRadius: AppRadius.circular6,
        ),
        child: Transform.rotate(
          angle: -_diamondRotationAngle,
          child: Center(
            child: Padding(
              // Трёхзначные уровни (100+) не помещаются в ромб на полный
              // fontSize — сжимаем, а не обрезаем цифры (см. тот же приём в
              // _LevelTrackNode, reward_tile.dart).
              padding: AppPadding.horizontalPadding3,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$number',
                  style: theme.appTypography.mobileTypo.bold14.copyWith(
                    color: colors.appColorWhite,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Стрелка-разделитель между элементами трека — тот же ассет, что и внутри
/// `PremiumTeaserCluster`. Центрируется по высоте карточки (240), а не всей
/// колонки с ромбом уровня.
class _TrackSeparator extends StatelessWidget {
  const _TrackSeparator({this.visible = true});

  static const double width = AppSizes.horizontalSize12;

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: AppSizes.verticalSize240,
      child: visible
          ? Center(
              child: SvgPicture.asset(
                AppAssets.iconArrow,
                width: width,
                height: AppSizes.verticalSize20,
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
      padding: AppPadding.horizontalPadding8,
      child: Material(
        color: colors.buttonOverlayStrong,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: AppSizes.allSize84,
            height: AppSizes.allSize84,
            child: Icon(icon, color: colors.appColorWhite, size: iconSize),
          ),
        ),
      ),
    );
  }
}
