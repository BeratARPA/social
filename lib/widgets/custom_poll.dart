import 'package:flutter/material.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';

class CustomPoll extends StatefulWidget {
  final Map<String, dynamic> pollData;
  final Function(int)? onVote;
  final bool canVote;
  final bool showResults;

  const CustomPoll({
    super.key,
    required this.pollData,
    this.onVote,
    this.canVote = true,
    this.showResults = true,
  });

  @override
  State<CustomPoll> createState() => _CustomPollState();
}

class _CustomPollState extends State<CustomPoll> {
  int? selectedOption;
  bool hasVoted = false;

  int get totalVotes {
    return (widget.pollData["votes"] as List<int>).fold(
      0,
      (sum, votes) => sum + votes,
    );
  }

  double getPercentage(int votes) {
    return totalVotes > 0 ? (votes / totalVotes) * 100 : 0.0;
  }

  Color getOptionColor(int index) {
    const colors = [
      Color(0xFF6366F1), // Indigo
      Color(0xFF10B981), // Emerald
      Color(0xFFF59E0B), // Amber
      Color(0xFFEF4444), // Red
      Color(0xFF8B5CF6), // Violet
      Color(0xFF06B6D4), // Cyan
      Color(0xFFF97316), // Orange
      Color(0xFFEC4899), // Pink
      Color(0xFF6B7280), // Gray
      Color(0xFF059669), // Green
      Color(0xFFDC2626), // Dark Red
    ];
    return colors[index % colors.length];
  }

  String getOptionIcon(int index) {
    const icons = [
      'A',
      'B',
      'C',
      'D',
      'E',
      'F',
      'G',
      'H',
      'I',
      'J',
      'K',
      'L',
      'M',
      'N',
      'O',
      'P',
      'Q',
      'R',
      'S',
      'T',
      'U',
      'V',
      'W',
      'X',
      'Y',
      'Z',
    ];
    return icons[index % icons.length];
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.poll_rounded,
                      size: 12,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ANKET',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.themeValue(
                    light: AppColors.lightSurface,
                    dark: AppColors.darkSurface,
                  ),
                  border: Border.all(
                    color: context.themeValue(
                      light: AppColors.lightBorder,
                      dark: AppColors.darkBorder,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 11,
                      color: context.themeValue(
                        light: AppColors.lightSecondaryText,
                        dark: AppColors.darkSecondaryText,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '$totalVotes',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: context.themeValue(
                          light: AppColors.lightSecondaryText,
                          dark: AppColors.darkSecondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.pollData["question"],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: context.themeValue(
                light: AppColors.lightText,
                dark: AppColors.darkText,
              ),
              height: 1.3,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPollOptions(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.separated(
          itemCount: widget.pollData["options"].length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) => _buildPollOption(index),
        ),
      ),
    );
  }

  Widget _buildPollOption(int index) {
    final option = widget.pollData["options"][index];
    final votes = widget.pollData["votes"][index];
    final percentage = getPercentage(votes);
    final color = getOptionColor(index);
    final isSelected = selectedOption == index;
    final showPercentage = widget.showResults && totalVotes > 0;
    final canSelect = widget.canVote && !hasVoted;

    // Tema uyumlu renkler
    final borderColor =
        isSelected
            ? color
            : hasVoted || !canSelect
            ? context.themeValue(
              light: AppColors.lightDivider,
              dark: AppColors.darkDivider,
            )
            : context.themeValue(
              light: AppColors.lightBorder,
              dark: AppColors.darkBorder,
            );

    final backgroundColor =
        isSelected
            ? color.withOpacity(0.1)
            : hasVoted && !isSelected && canSelect
            ? context.themeValue(
              light: AppColors.lightBackground,
              dark: AppColors.darkBackground,
            )
            : context.themeValue(
              light: AppColors.lightSurface,
              dark: AppColors.darkSurface,
            );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap:
            canSelect
                ? () {
                  setState(() {
                    selectedOption = index;
                    hasVoted = true;
                  });
                  widget.onVote?.call(index);
                }
                : null,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
            color: backgroundColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Option Icon/Letter
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? color
                              : hasVoted
                              ? context.themeValue(
                                light: AppColors.lightDivider,
                                dark: AppColors.darkDivider,
                              )
                              : context.themeValue(
                                light: AppColors.lightBackground,
                                dark: AppColors.darkBackground,
                              ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        getOptionIcon(index),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color:
                              isSelected
                                  ? Colors.white
                                  : hasVoted
                                  ? context.themeValue(
                                    light: AppColors.lightSecondaryText,
                                    dark: AppColors.darkSecondaryText,
                                  )
                                  : context.themeValue(
                                    light: AppColors.lightSecondaryText,
                                    dark: AppColors.darkSecondaryText,
                                  ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Option Text
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color:
                            isSelected
                                ? context.themeValue(
                                  light: AppColors.lightText,
                                  dark: AppColors.darkText,
                                )
                                : hasVoted && !isSelected
                                ? context.themeValue(
                                  light: AppColors.lightSecondaryText,
                                  dark: AppColors.darkSecondaryText,
                                )
                                : context.themeValue(
                                  light: AppColors.lightText,
                                  dark: AppColors.darkText,
                                ),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Vote Count and Percentage
                  if (showPercentage) ...[
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$votes',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: context.themeValue(
                              light: AppColors.lightSecondaryText,
                              dark: AppColors.darkSecondaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  // Selection indicator
                  if (canSelect && !hasVoted) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              isSelected
                                  ? color
                                  : context.themeValue(
                                    light: AppColors.lightBorder,
                                    dark: AppColors.darkBorder,
                                  ),
                          width: 2,
                        ),
                        color: isSelected ? color : Colors.transparent,
                      ),
                      child:
                          isSelected
                              ? const Icon(
                                Icons.check,
                                size: 8,
                                color: Colors.white,
                              )
                              : null,
                    ),
                  ],
                ],
              ),
              // Progress Bar
              if (showPercentage && percentage > 0) ...[
                const SizedBox(height: 8),
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: context.themeValue(
                      light: AppColors.lightDivider,
                      dark: AppColors.darkDivider,
                    ),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: percentage / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 12,
            color: context.themeValue(
              light: AppColors.lightSecondaryText,
              dark: AppColors.darkSecondaryText,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              selectedOption == null
                  ? 'Bir seçenek seçin'
                  : 'Oyunuz kaydedildi!',
              style: TextStyle(
                fontSize: 11,
                color: context.themeValue(
                  light: AppColors.lightSecondaryText,
                  dark: AppColors.darkSecondaryText,
                ),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.themeValue(
          light: AppColors.lightSurface,
          dark: AppColors.darkSurface,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildPollOptions(context),
          _buildFooter(context),
        ],
      ),
    );
  }
}
