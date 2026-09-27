/// Как выглядит плавающее превью ближайшего юбилейного уровня.
enum MilestonePreviewStyle {
  /// Корона + оранжевая рамка "к клейму готово".
  regular,

  /// Как [regular], но ромб с номером подсвечен (макс. уровень).
  maxLevel,

  /// Без короны, цвет рамки обычный.
  noCrown,

  /// Без короны, рамка всегда белая.
  plain,
}

/// Карточка "следующий сезон" в конце трека.
enum SeasonEndTeaser {
  /// "Откроются после уровня N".
  unlocksAfterMaxLevel,

  /// "Нужна прокачка".
  requiresPremium,
}

/// Визуальные отличия трека наград между сценариями — одно значение вместо
/// набора флагов в конструкторе `RewardsTrack`.
class TrackAppearance {
  const TrackAppearance({
    this.milestonePreview = MilestonePreviewStyle.regular,
    this.seasonEndTeaser,
    this.hideGiftBadges = false,
    this.hidePremiumBadges = false,
    this.highlightedLevel,
    this.goldLevel,
  });

  final MilestonePreviewStyle milestonePreview;

  /// `null` — трек обычный; иначе в конце трека карточка следующего сезона,
  /// и трек открывается сразу у неё.
  final SeasonEndTeaser? seasonEndTeaser;

  /// Значок подарка убран у обычных плиток.
  final bool hideGiftBadges;

  /// Корона убрана у всех элементов карусели, включая премиум-тизер.
  final bool hidePremiumBadges;

  /// Уровень с белой рамкой и значком подарка независимо от [hideGiftBadges].
  final int? highlightedLevel;

  /// Уровень, всегда закрашенный золотым градиентом.
  final int? goldLevel;

  bool get startScrolledToEnd => seasonEndTeaser != null;
}
