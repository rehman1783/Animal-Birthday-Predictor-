import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/keyboard_helper.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../domain/faq_item.dart';
import '../../data/faq_data.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final TextEditingController _searchController = TextEditingController();
  FaqCategory _selectedCategory = FaqCategory.all;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FaqItem> get _filteredFaqs {
    return FaqData.defaultFaqs.where((faq) {
      final matchesCategory = _selectedCategory == FaqCategory.all || faq.category == _selectedCategory;
      if (!matchesCategory) return false;

      if (_searchQuery.trim().isEmpty) return true;

      final query = _searchQuery.toLowerCase();
      final inQuestion = faq.question.toLowerCase().contains(query);
      final inAnswer = faq.answer.toLowerCase().contains(query);
      final inTags = faq.tags.any((t) => t.toLowerCase().contains(query));

      return inQuestion || inAnswer || inTags;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final faqs = _filteredFaqs;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (dismissKeyboardIfOpen(context)) return;
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: Text(
            'Frequently Asked Questions',
            style: AppTypography.displayHeadline.copyWith(fontSize: 20),
          ),
        ),
      body: SafeArea(
        top: true,
        bottom: true,
        left: true,
        right: true,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(AppSpacing.horizontalPadding),
          child: ResponsiveBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.help_outline_rounded, color: AppColors.primaryGold, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Knowledge Base & Help',
                              style: AppTypography.featureTitle,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Find quick answers about gestation, scans, certificates, and animal care.',
                              style: AppTypography.finePrint.copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  style: AppTypography.inputText,
                  decoration: InputDecoration(
                    hintText: 'Search questions, topics, or keywords...',
                    hintStyle: AppTypography.finePrint.copyWith(color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryGold),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.inputField,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.inputBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primaryGold, width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Category Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: FaqCategory.values.map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            category.title,
                            style: TextStyle(
                              color: isSelected ? AppColors.background : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primaryGold,
                          backgroundColor: AppColors.surface,
                          side: BorderSide(
                            color: isSelected ? AppColors.primaryGold : AppColors.inputBorder,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategory = category;
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // Results Count
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${faqs.length} ${faqs.length == 1 ? 'Article' : 'Articles'} Found',
                        style: AppTypography.finePrint.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty || _selectedCategory != FaqCategory.all)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                            _selectedCategory = FaqCategory.all;
                          });
                        },
                        child: const Text(
                          'Reset Filters',
                          style: TextStyle(color: AppColors.primaryGold, fontSize: 12),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                // FAQ Accordion List
                if (faqs.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.search_off_rounded, color: AppColors.textMuted, size: 48),
                        const SizedBox(height: 12),
                        const Text(
                          'No FAQ articles found',
                          style: AppTypography.featureTitle,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Try searching for different keywords or select "All Questions".',
                          style: AppTypography.finePrint,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ...faqs.map((faq) => _FaqAccordionCard(faq: faq)),

                const SizedBox(height: 24),

                // Support Help Desk Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.headset_mic_outlined, color: AppColors.primaryGold, size: 22),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Still have questions?',
                              style: AppTypography.featureTitle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Our breeding support specialists and technical team are available to help you with calculations, certificates, and record management.',
                        style: AppTypography.finePrint.copyWith(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/disclaimer');
                              },
                              icon: const Icon(Icons.gavel_outlined, size: 16, color: AppColors.primaryGold),
                              label: const Text('View Disclaimer', style: TextStyle(color: AppColors.primaryGold, fontSize: 12)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.primaryGold),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}

class _FaqAccordionCard extends StatelessWidget {
  final FaqItem faq;

  const _FaqAccordionCard({required this.faq});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
          ),
          child: ExpansionTile(
          iconColor: AppColors.primaryGold,
          collapsedIconColor: AppColors.textMuted,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          childrenPadding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
          title: Text(
            faq.question,
            style: AppTypography.inputText.copyWith(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              faq.category.title,
              style: const TextStyle(
                color: AppColors.primaryGold,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          children: [
            const Divider(color: AppColors.inputBorder, height: 1),
            const SizedBox(height: 12),
            Text(
              faq.answer,
              style: AppTypography.body.copyWith(
                color: AppColors.textPrimary.withValues(alpha: 0.9),
                height: 1.5,
                fontSize: 13,
              ),
            ),
            if (faq.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: faq.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    child: Text(
                      '#$tag',
                      style: AppTypography.finePrint.copyWith(fontSize: 10, color: AppColors.textMuted),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
}
