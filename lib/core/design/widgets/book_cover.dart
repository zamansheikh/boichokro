import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../tokens.dart';

/// A book cover drawn as a physical object: tight spine edge on the left,
/// rounded fore-edge on the right, a spine highlight and a soft drop shadow.
///
/// Falls back to a tinted "cloth" cover with the title when there is no image.
class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    required this.imageUrl,
    this.width = 96,
    this.height,
    this.title,
    this.heroTag,
    this.elevated = true,
  });

  final String? imageUrl;
  final double width;

  /// Defaults to a 2:3 book ratio.
  final double? height;

  /// Shown on the fallback cover.
  final String? title;
  final Object? heroTag;
  final bool elevated;

  static const List<Color> _clothColors = [
    Color(0xFF1F5C4A),
    Color(0xFF8C3B2E),
    Color(0xFF2F4A6B),
    Color(0xFF8A5A14),
    Color(0xFF5B3F66),
    Color(0xFF3F5A3A),
  ];

  @override
  Widget build(BuildContext context) {
    final h = height ?? width * 1.5;
    final outer = Radius.circular(width * 0.08);
    final spine = Radius.circular(width * 0.03);
    final radius = BorderRadius.only(
      topLeft: spine,
      bottomLeft: spine,
      topRight: outer,
      bottomRight: outer,
    );
    final url = imageUrl;
    final hasImage = url != null && url.isNotEmpty;

    Widget cover = Container(
      width: width,
      height: h,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: context.palette.softShadow,
                  blurRadius: width * 0.18,
                  offset: Offset(width * 0.04, width * 0.08),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                fadeInDuration: AppMotion.medium,
                placeholder: (context, _) =>
                    ColoredBox(color: context.colors.surfaceContainerHighest),
                errorWidget: (context, _, _) => _fallback(context),
              )
            else
              _fallback(context),
            // Spine crease and page-edge sheen.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [0, 0.035, 0.075, 0.13, 1],
                  colors: [
                    Color(0x33000000),
                    Color(0x0D000000),
                    Color(0x33FFFFFF),
                    Color(0x00FFFFFF),
                    Color(0x12000000),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (heroTag != null) {
      cover = Hero(tag: heroTag!, child: cover);
    }
    return cover;
  }

  Widget _fallback(BuildContext context) {
    final label = title?.trim() ?? '';
    final color = _clothColors[label.hashCode.abs() % _clothColors.length];
    final showTitle = label.isNotEmpty && width >= 64;

    return ColoredBox(
      color: color,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          width * 0.16,
          width * 0.12,
          width * 0.1,
          width * 0.12,
        ),
        child: showTitle
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: width * 0.22,
                    height: 2,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                  SizedBox(height: width * 0.08),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.94),
                        fontSize: (width * 0.125).clamp(9, 18).toDouble(),
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: Icon(
                  LucideIcons.bookOpen,
                  size: width * 0.4,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
      ),
    );
  }
}
