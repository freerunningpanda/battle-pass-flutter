import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../exports.dart';

/// Центральный предмет БП над аркой (Item + Item_Name из макета, id 1:1259).
class CentralItemDisplay extends StatelessWidget {
  const CentralItemDisplay({required this.scenario, super.key});

  final BattlePassScenario scenario;

  @override
  Widget build(BuildContext context) {
    const itemLeft = 960.0;
    const itemTop = 140.0;
    const switchDuration = Duration(milliseconds: 350);

    final flavor = ScenarioFlavor.of(scenario);
    return Positioned(
      left: itemLeft,
      top: itemTop,
      width: 600,
      height: 550,
      child: AnimatedSwitcher(
        duration: switchDuration,
        child: Column(
          key: ValueKey(scenario),
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Transform.translate(
                offset: Offset(0, flavor.itemOffsetY),
                child: Transform.scale(
                  scale: flavor.itemScale,
                  child: Image.asset(flavor.itemAsset, fit: BoxFit.contain),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (flavor.tag case final tag?) ...[
              _Tag(text: tag),
              const SizedBox(height: 10),
            ],
            _ItemTitle(
              text: flavor.itemTitle,
              infoAsset: flavor.itemAsset,
              infoText: flavor.infoText,
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.appColors.mainColors;

    final tagGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [colors.itemTagGradientTop, colors.itemTagGradientBottom],
    );

    return Container(
      width: 324,
      height: 39,
      padding: const EdgeInsets.only(left: 12, right: 19),
      decoration: BoxDecoration(
        gradient: tagGradient,
        borderRadius: const BorderRadius.all(Radius.circular(30)),
      ),
      child: Row(
        children: [
          SvgPicture.asset(AppAssets.iconPremiumIcon, width: 30, height: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: theme.appTypography.mobileTypo.p1Med.copyWith(
                color: colors.itemTagText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemTitle extends StatelessWidget {
  const _ItemTitle({
    required this.text,
    required this.infoAsset,
    required this.infoText,
  });

  final String text;

  /// Картинка предмета — она же превью в диалоге.
  final String infoAsset;

  final String infoText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text.rich(
              _titleSpan(context, text),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
        ),
        const SizedBox(width: 16),
        InkWell(
          customBorder: const CircleBorder(),
          onTap: () => showDialog<void>(
            context: context,
            builder: (_) => _ItemInfoDialog(
              title: text,
              asset: infoAsset,
              description: infoText,
            ),
          ),
          child: SvgPicture.asset(AppAssets.iconInfo, width: 36, height: 36),
        ),
      ],
    );
  }

  // "или" между двумя названиями — золотым (по Figma).
  InlineSpan _titleSpan(BuildContext context, String text) {
    final theme = context.theme;
    final colors = theme.appColors.mainColors;
    final style = theme.appTypography.mobileTypo.h4.copyWith(
      color: colors.textPrimary,
    );
    const highlight = AppStrings.itemTitleOrConnector;
    final index = text.indexOf(highlight);
    if (index == -1) return TextSpan(text: text, style: style);

    return TextSpan(
      style: style,
      children: [
        TextSpan(text: text.substring(0, index)),
        TextSpan(
          text: highlight,
          style: TextStyle(color: colors.accentGold),
        ),
        TextSpan(text: text.substring(index + highlight.length)),
      ],
    );
  }
}

/// Карточка предмета по тапу на инфо-иконку: превью, заголовок, описание.
class _ItemInfoDialog extends StatelessWidget {
  const _ItemInfoDialog({
    required this.title,
    required this.asset,
    required this.description,
  });

  final String title;
  final String asset;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.appColors.mainColors;

    const dialogMaxWidth = 480.0;
    const previewSize = 160.0;
    const borderWidth = 1.5;
    const glowBlurRadius = 24.0;
    const glowSpreadRadius = 1.0;
    // Сверху — место под крестик, плавающий поверх контента.
    const contentPadding = EdgeInsets.fromLTRB(32, 52, 32, 32);
    const closeButtonInset = 8.0;
    const closeButtonPadding = 8.0;
    // Диалог — в координатах экрана, а не холста: на низком экране
    // контент может не влезть, поэтому maxHeight и скролл.
    final dialogMaxHeight = MediaQuery.sizeOf(context).height * 0.8;

    return Dialog(
      backgroundColor: colors.appColorTransparent,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogMaxWidth,
          maxHeight: dialogMaxHeight,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: colors.taskCardHeaderBg,
            borderRadius: const BorderRadius.all(Radius.circular(24)),
            border: Border.all(color: colors.glowGold, width: borderWidth),
            boxShadow: [
              BoxShadow(
                color: colors.glowShadow,
                blurRadius: glowBlurRadius,
                spreadRadius: glowSpreadRadius,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(24)),
            child: Stack(
              children: [
                Padding(
                  padding: contentPadding,
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: previewSize,
                            height: previewSize,
                            child: Image.asset(asset, fit: BoxFit.contain),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: theme.appTypography.mobileTypo.p1Med
                                .copyWith(color: colors.accentGold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description,
                            textAlign: TextAlign.center,
                            style: theme.appTypography.mobileTypo.p4Reg
                                .copyWith(color: colors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: closeButtonInset,
                  right: closeButtonInset,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.of(context).pop(),
                    child: Padding(
                      padding: const EdgeInsets.all(closeButtonPadding),
                      child: Icon(
                        Icons.close,
                        color: colors.textSecondary,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
