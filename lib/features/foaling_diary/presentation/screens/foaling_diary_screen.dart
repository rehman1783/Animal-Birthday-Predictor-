import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/abp_brand_badge.dart';
import '../../../../core/widgets/horseshoe_icon.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../domain/foaling_diary_entry.dart';
import '../../data/calendar_diary_sync_service.dart';
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
  int _selectedViewTab = 0; // 0 = Roster, 1 = Calendar Timeline
  String _selectedTimelineFilter = 'all'; // all, scans, paddock, due

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

  void _confirmDeleteEntry(FoalingDiaryEntry entry) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.primaryGold),
        ),
        title: Text('Remove from Foaling Diary?', style: AppTypography.featureTitle.copyWith(fontSize: 16)),
        content: Text(
          'Are you sure you want to remove "${entry.mareName}" from the Foaling Diary roster?',
          style: AppTypography.inputText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              ref.read(foalingDiaryProvider.notifier).deleteEntry(entry.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Removed "${entry.mareName}" from diary.'),
                  backgroundColor: AppColors.primaryGold,
                ),
              );
            },
            child: const Text('Remove', style: TextStyle(color: AppColors.background, fontWeight: FontWeight.bold)),
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
                    // Official ABP Header Badge
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AbpBrandBadge(text: 'OFFICIAL ABP™ FOALING & GESTATION DIARY'),
                        Row(
                          children: [
                            HorseshoeIcon(size: 14, color: AppColors.primaryGold),
                            SizedBox(width: 4),
                            Text('CALENDAR SYNCED', style: TextStyle(color: AppColors.primaryGold, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // View Mode Switcher Tab
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.inputBorder),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ViewTabButton(
                              icon: Icons.format_list_bulleted_rounded,
                              title: 'Broodmare Roster',
                              isSelected: _selectedViewTab == 0,
                              onTap: () => setState(() => _selectedViewTab = 0),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _ViewTabButton(
                              icon: Icons.calendar_month_rounded,
                              title: 'Calendar & Timeline',
                              isSelected: _selectedViewTab == 1,
                              onTap: () => setState(() => _selectedViewTab = 1),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (_selectedViewTab == 0) ...[
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
                              onDelete: () => _confirmDeleteEntry(entry),
                            )),
                    ] else ...[
                      // Calendar & Timeline View
                      _buildCalendarTimelineView(context, allEntries),
                    ],

                    const SizedBox(height: 24),
                    const AbpProtectedFooter(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCalendarTimelineView(BuildContext context, List<FoalingDiaryEntry> allEntries) {
    final timelineAsync = ref.watch(calendarTimelineMilestonesProvider);

    return timelineAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGold)),
      error: (err, _) => Center(child: Text('Timeline error: $err', style: const TextStyle(color: AppColors.error))),
      data: (milestones) {
        final filteredMilestones = milestones.where((m) {
          if (_selectedTimelineFilter == 'scans') {
            return m.category.startsWith('scan');
          } else if (_selectedTimelineFilter == 'paddock') {
            return m.category == 'close_paddock' || m.category == 'foaling_barn';
          } else if (_selectedTimelineFilter == 'due') {
            return m.category == 'due_date';
          }
          return true;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline Intro Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.6)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sync_rounded, color: AppColors.primaryGold, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Live Synced Gestation Calendar', style: AppTypography.featureTitle),
                        const SizedBox(height: 2),
                        Text(
                          '${milestones.length} automated scan checks, paddock transfers & foaling milestones synced in real-time.',
                          style: AppTypography.finePrint.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Timeline Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _TimelineFilterChip(
                    label: 'All Events (${milestones.length})',
                    isSelected: _selectedTimelineFilter == 'all',
                    onTap: () => setState(() => _selectedTimelineFilter = 'all'),
                  ),
                  const SizedBox(width: 8),
                  _TimelineFilterChip(
                    label: 'Ultrasound Scans',
                    isSelected: _selectedTimelineFilter == 'scans',
                    onTap: () => setState(() => _selectedTimelineFilter = 'scans'),
                  ),
                  const SizedBox(width: 8),
                  _TimelineFilterChip(
                    label: 'Paddock Transfers',
                    isSelected: _selectedTimelineFilter == 'paddock',
                    onTap: () => setState(() => _selectedTimelineFilter = 'paddock'),
                  ),
                  const SizedBox(width: 8),
                  _TimelineFilterChip(
                    label: 'Foaling Due Dates',
                    isSelected: _selectedTimelineFilter == 'due',
                    onTap: () => setState(() => _selectedTimelineFilter = 'due'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            if (filteredMilestones.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                ),
                child: const Center(
                  child: Text('No upcoming calendar events for this category.', style: AppTypography.finePrint),
                ),
              )
            else
              ...filteredMilestones.map((m) => _TimelineMilestoneCard(milestone: m)),
          ],
        );
      },
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
  final VoidCallback? onDelete;

  const _MareDiaryCard({
    required this.entry,
    required this.onChangePaddock,
    this.onDelete,
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
          // Top Row: Mare Name, Stage Badge, & Delete Button
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
              const SizedBox(width: 6),
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
              if (onDelete != null) ...[
                const SizedBox(width: 4),
                InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                  ),
                ),
              ],
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

class _ViewTabButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _ViewTabButton({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGold : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.background : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.background : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimelineFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGold.withValues(alpha: 0.2) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryGold : AppColors.inputBorder,
            width: isSelected ? 1.2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primaryGold : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _TimelineMilestoneCard extends StatelessWidget {
  final CalendarTimelineMilestone milestone;

  const _TimelineMilestoneCard({required this.milestone});

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(milestone.date.year, milestone.date.month, milestone.date.day);
    final diffDays = target.difference(today).inDays;

    Color badgeColor;
    IconData icon;
    String timingText;

    if (milestone.isCompleted) {
      badgeColor = AppColors.success;
      icon = Icons.check_circle_rounded;
      timingText = 'COMPLETED';
    } else if (diffDays < 0) {
      badgeColor = AppColors.error;
      icon = Icons.warning_amber_rounded;
      timingText = '${diffDays.abs()}d OVERDUE';
    } else if (diffDays == 0) {
      badgeColor = AppColors.warning;
      icon = Icons.today_rounded;
      timingText = 'TODAY';
    } else if (diffDays <= 7) {
      badgeColor = AppColors.warning;
      icon = Icons.notifications_active_rounded;
      timingText = 'IN $diffDays DAYS';
    } else {
      badgeColor = AppColors.primaryGold;
      icon = Icons.event_available_rounded;
      timingText = 'IN $diffDays DAYS';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: milestone.isCompleted ? AppColors.inputBorder : badgeColor.withValues(alpha: 0.5),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: badgeColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            milestone.title,
                            style: AppTypography.inputText.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            timingText,
                            style: TextStyle(color: badgeColor, fontSize: 9.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const HorseshoeIcon(size: 13, color: AppColors.primaryGold),
                        const SizedBox(width: 5),
                        Text(
                          'Mare: ${milestone.mareName}',
                          style: const TextStyle(color: AppColors.primaryGold, fontSize: 11.5, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(milestone.date),
                          style: AppTypography.finePrint.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            milestone.description,
            style: AppTypography.finePrint.copyWith(color: AppColors.textMuted, fontSize: 10.5),
          ),
        ],
      ),
    );
  }
}

