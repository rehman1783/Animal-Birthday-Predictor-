import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../domain/foaling_diary_entry.dart';
import '../providers/foaling_diary_provider.dart';
import '../../../certificates/data/pdf_certificate_service.dart';

class FoalingDiaryScreen extends ConsumerStatefulWidget {
  const FoalingDiaryScreen({super.key});

  @override
  ConsumerState<FoalingDiaryScreen> createState() => _FoalingDiaryScreenState();
}

class _FoalingDiaryScreenState extends ConsumerState<FoalingDiaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  MovementStage? _selectedStage;
  String _searchQuery = '';
  bool _isExporting = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FoalingDiaryEntry> _filterEntries(List<FoalingDiaryEntry> raw) {
    return raw.where((entry) {
      if (_selectedStage != null && entry.movementStage != _selectedStage) {
        return false;
      }
      if (_searchQuery.trim().isEmpty) return true;

      final q = _searchQuery.toLowerCase();
      final inMare = entry.mareName.toLowerCase().contains(q);
      final inStallion = entry.stallionName.toLowerCase().contains(q);
      final inRecip = entry.recipientMareName?.toLowerCase().contains(q) ?? false;
      final inPaddock = entry.currentPaddock.toLowerCase().contains(q);

      return inMare || inStallion || inRecip || inPaddock;
    }).toList();
  }

  Future<void> _exportPdf(List<FoalingDiaryEntry> entries) async {
    if (entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No recorded mares in current view to export.')),
      );
      return;
    }

    setState(() => _isExporting = true);
    try {
      final pdfBytes = await PdfCertificateService.generateFoalingDiaryPdf(
        entries: entries,
        studName: 'Sterling Thoroughbred & Sport Horse Stud',
        season: '2026 / 2027 Breeding Season',
        filterTitle: _selectedStage?.title ?? 'All Active Gestations',
      );
      await PdfCertificateService.exportOrPrintPdf(
        pdfBytes,
        'ABP_Stud_Foaling_Diary_${DateTime.now().year}_${DateTime.now().month}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _showPaddockDialog(FoalingDiaryEntry entry) {
    final controller = TextEditingController(text: entry.currentPaddock);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.primaryGold),
        ),
        title: Text('Assign Paddock / Barn Box', style: AppTypography.featureTitle.copyWith(fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mare: ${entry.mareName}', style: AppTypography.inputText.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Stage: ${entry.movementStage.title}', style: const TextStyle(color: AppColors.primaryGold, fontSize: 12)),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              style: AppTypography.inputText,
              decoration: InputDecoration(
                labelText: 'Location / Paddock Name',
                labelStyle: const TextStyle(color: AppColors.textMuted),
                hintText: 'e.g. Foaling Barn Box 2, Close Paddock B',
                filled: true,
                fillColor: AppColors.inputField,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold),
            onPressed: () {
              final newLoc = controller.text.trim();
              if (newLoc.isNotEmpty) {
                ref.read(foalingDiaryProvider.notifier).updatePaddock(entry.id, newLoc);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save Location', style: TextStyle(color: AppColors.background, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final diaryAsync = ref.watch(foalingDiaryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Foaling Diary & Stud Planner',
          style: AppTypography.displayHeadline.copyWith(fontSize: 18),
        ),
        actions: [
          diaryAsync.when(
            data: (entries) => IconButton(
              icon: _isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: AppColors.primaryGold, strokeWidth: 2),
                    )
                  : const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primaryGold),
              tooltip: 'Export Stud Foaling Diary PDF',
              onPressed: _isExporting ? null : () => _exportPdf(_filterEntries(entries)),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: true,
        bottom: true,
        left: true,
        right: true,
        child: diaryAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGold)),
          error: (err, _) => Center(
            child: Text('Error loading diary: $err', style: const TextStyle(color: AppColors.error)),
          ),
          data: (allEntries) {
            final filtered = _filterEntries(allEntries);

            final overdueCount = allEntries.where((e) => e.movementStage == MovementStage.overdue).length;
            final barnCount = allEntries.where((e) => e.movementStage == MovementStage.foalingBarn).length;
            final paddockCount = allEntries.where((e) => e.movementStage == MovementStage.closePaddock).length;
            final upcomingCount = allEntries.where((e) => e.movementStage == MovementStage.upcoming).length;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(AppSpacing.horizontalPadding),
              child: ResponsiveBody(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Stud Metrics Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                        border: Border.all(color: AppColors.primaryGold, width: 1.2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGold.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.event_note_rounded, color: AppColors.primaryGold, size: 22),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Stud Gestation & Movement Manager', style: AppTypography.featureTitle),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Managing ${allEntries.length} Recorded Broodmares & Recipients',
                                      style: AppTypography.finePrint.copyWith(color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          // KPI Row
                          Row(
                            children: [
                              Expanded(
                                child: _KpiChip(
                                  label: 'Overdue',
                                  count: overdueCount,
                                  color: AppColors.error,
                                  isActive: _selectedStage == MovementStage.overdue,
                                  onTap: () {
                                    setState(() {
                                      _selectedStage = _selectedStage == MovementStage.overdue ? null : MovementStage.overdue;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _KpiChip(
                                  label: 'Foaling Barn',
                                  count: barnCount,
                                  color: AppColors.warning,
                                  isActive: _selectedStage == MovementStage.foalingBarn,
                                  onTap: () {
                                    setState(() {
                                      _selectedStage = _selectedStage == MovementStage.foalingBarn ? null : MovementStage.foalingBarn;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _KpiChip(
                                  label: 'Close Paddock',
                                  count: paddockCount,
                                  color: const Color(0xFF9333EA),
                                  isActive: _selectedStage == MovementStage.closePaddock,
                                  onTap: () {
                                    setState(() {
                                      _selectedStage = _selectedStage == MovementStage.closePaddock ? null : MovementStage.closePaddock;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _KpiChip(
                                  label: 'Upcoming',
                                  count: upcomingCount,
                                  color: AppColors.success,
                                  isActive: _selectedStage == MovementStage.upcoming,
                                  onTap: () {
                                    setState(() {
                                      _selectedStage = _selectedStage == MovementStage.upcoming ? null : MovementStage.upcoming;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Quick Actions & Dedicated Due Date Button
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGold,
                              foregroundColor: AppColors.background,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.calculate_rounded, size: 18),
                            label: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('WHEN IS MY FOAL DUE?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/due-date-calculator');
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primaryGold),
                              foregroundColor: AppColors.primaryGold,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                            label: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('EXPORT PDF ROSTER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                            onPressed: () => _exportPdf(filtered),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Search Input
                    TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: AppTypography.inputText,
                      decoration: InputDecoration(
                        hintText: 'Search by Mare, Sire, Recipient, Paddock...',
                        hintStyle: AppTypography.finePrint.copyWith(color: AppColors.textMuted),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryGold),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.inputField,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.inputBorder),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Active Filter Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${filtered.length} ${filtered.length == 1 ? 'Mare' : 'Mares'} in Stud Diary',
                          style: AppTypography.finePrint.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (_selectedStage != null || _searchQuery.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedStage = null;
                                _searchQuery = '';
                                _searchController.clear();
                              });
                            },
                            child: const Text('Show All Stages', style: TextStyle(color: AppColors.primaryGold, fontSize: 12)),
                          ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Mare Entries List
                    if (allEntries.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                          border: Border.all(color: AppColors.inputBorder),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGold.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.event_note_rounded, color: AppColors.primaryGold, size: 36),
                            ),
                            const SizedBox(height: 14),
                            const Text('No Mares in Foaling Diary Yet', style: AppTypography.featureTitle),
                            const SizedBox(height: 6),
                            const Text(
                              'Calculate expected due dates with "When Is My Foal Due?" or record active mare breedings to automatically track gestation and paddock movements.',
                              style: AppTypography.finePrint,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 18),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGold,
                                foregroundColor: AppColors.background,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.calculate_rounded, size: 18),
                              label: const Text('CALCULATE FOAL DUE DATE', style: TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: () => Navigator.pushNamed(context, '/due-date-calculator'),
                            ),
                          ],
                        ),
                      )
                    else if (filtered.isEmpty)
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
                            const Icon(Icons.search_off_rounded, color: AppColors.textMuted, size: 40),
                            const SizedBox(height: 10),
                            const Text('No mares found matching criteria', style: AppTypography.featureTitle),
                            const SizedBox(height: 4),
                            const Text(
                              'Try clearing filters or search keywords.',
                              style: AppTypography.finePrint,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      ...filtered.map((entry) => _MareDiaryCard(
                            entry: entry,
                            onChangePaddock: () => _showPaddockDialog(entry),
                          )),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _KpiChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _KpiChip({
    required this.label,
    required this.count,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.25) : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? color : AppColors.inputBorder,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MareDiaryCard extends StatelessWidget {
  final FoalingDiaryEntry entry;
  final VoidCallback onChangePaddock;

  const _MareDiaryCard({
    required this.entry,
    required this.onChangePaddock,
  });

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final rem = entry.daysRemaining;
    Color stageColor;
    String stageBadgeText;

    switch (entry.movementStage) {
      case MovementStage.overdue:
        stageColor = AppColors.error;
        stageBadgeText = '🚨 OVERDUE (+${rem.abs()} DAYS)';
        break;
      case MovementStage.foalingBarn:
        stageColor = AppColors.warning;
        stageBadgeText = '⏰ FOALING BARN (<${rem}d)';
        break;
      case MovementStage.closePaddock:
        stageColor = const Color(0xFF9333EA);
        stageBadgeText = '🌾 CLOSE PADDOCK (<${rem}d)';
        break;
      case MovementStage.upcoming:
        stageColor = AppColors.success;
        stageBadgeText = '📅 UPCOMING (${rem}d)';
        break;
      case MovementStage.foaled:
        stageColor = AppColors.primaryGold;
        stageBadgeText = '✅ FOALED';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: entry.movementStage == MovementStage.overdue
              ? AppColors.error
              : (entry.movementStage == MovementStage.foalingBarn ? AppColors.warning : AppColors.inputBorder),
          width: (entry.movementStage == MovementStage.overdue || entry.movementStage == MovementStage.foalingBarn) ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Mare Name & Stage Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.mareName,
                      style: AppTypography.displayHeadline.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sire: ${entry.stallionName}',
                      style: AppTypography.finePrint.copyWith(color: AppColors.primaryGold),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: stageColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: stageColor),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      stageBadgeText,
                      style: TextStyle(
                        color: stageColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ET / Recipient Mare Tag
          if (entry.isEmbryoTransfer) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.swap_horiz_rounded, size: 13, color: AppColors.primaryGold),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Embryo Transfer • Carrier: ${entry.recipientMareName ?? entry.mareName}',
                      style: const TextStyle(color: AppColors.primaryGold, fontSize: 10, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(color: AppColors.inputBorder, height: 1),
          const SizedBox(height: 12),

          // Key Dates Grid
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TARGET DUE DATE (340d)', style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(entry.foalingDueDate),
                      style: AppTypography.inputText.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryGold, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SAFE WINDOW (320-365d)', style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatDate(entry.minDueDate)} - ${_formatDate(entry.maxDueDate)}',
                      style: AppTypography.finePrint.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Paddock / Barn Location Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primaryGold),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Current Location: ${entry.currentPaddock}',
                    style: AppTypography.finePrint.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                  ),
                ),
                InkWell(
                  onTap: onChangePaddock,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Text(
                      'Move / Edit',
                      style: TextStyle(color: AppColors.primaryGold, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Notes if present
          if (entry.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Notes: ${entry.notes}',
              style: AppTypography.finePrint.copyWith(color: AppColors.textMuted, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }
}
