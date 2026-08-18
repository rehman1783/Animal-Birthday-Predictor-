import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_feedback_snackbar.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../domain/contact.dart';
import '../providers/contact_provider.dart';
import '../widgets/select_or_add_contact_modal.dart';

class ContactsDirectoryScreen extends ConsumerStatefulWidget {
  const ContactsDirectoryScreen({super.key});

  @override
  ConsumerState<ContactsDirectoryScreen> createState() => _ContactsDirectoryScreenState();
}

class _ContactsDirectoryScreenState extends ConsumerState<ContactsDirectoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _roles = const ['all', 'vet', 'farrier', 'dentist', 'buyer'];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _roles.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _launchCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot initiate phone call to $phone')),
      );
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot launch email client for $email')),
      );
    }
  }

  Future<void> _confirmDeleteContact(Contact contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Delete Contact', style: AppTypography.displayHeadline.copyWith(fontSize: 18)),
        content: Text(
          'Are you sure you want to delete ${contact.name}? This contact will be removed from your directory.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repo = ref.read(contactRepositoryProvider);
      await repo.deleteContact(contact.id);
      ref.invalidate(contactsListProvider(null));
      ref.invalidate(contactsListProvider(contact.role));
      for (final r in _roles) {
        ref.invalidate(contactsListProvider(r == 'all' ? null : r));
      }
      if (mounted) {
        AppFeedbackSnackbar.showSuccess(
          context,
          title: 'Contact Deleted',
          message: '${contact.name} deleted from directory.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('CONTACTS DIRECTORY', style: AppTypography.sectionLabel),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryGold,
          labelColor: AppColors.primaryGold,
          unselectedLabelColor: AppColors.textMuted,
          isScrollable: true,
          labelStyle: AppTypography.buttonLabel.copyWith(fontSize: 12),
          tabs: const [
            Tab(text: 'ALL'),
            Tab(text: 'VETS'),
            Tab(text: 'FARRIERS'),
            Tab(text: 'DENTISTS'),
            Tab(text: 'BUYERS & OWNERS'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search by name, phone, or clinic...',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: AppColors.primaryGold, size: 20),
                  filled: true,
                  fillColor: AppColors.inputField,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    borderSide: const BorderSide(color: AppColors.surface),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    borderSide: const BorderSide(color: AppColors.surface),
                  ),
                ),
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _roles.map((role) {
                  return _ContactsRoleList(
                    role: role == 'all' ? null : role,
                    searchQuery: _searchQuery,
                    onCall: _launchCall,
                    onEmail: _launchEmail,
                    onDelete: _confirmDeleteContact,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.person_add_alt_1, color: AppColors.background),
        label: const Text('Add Contact', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () async {
          final currentRole = _roles[_tabController.index];
          final created = await SelectOrAddContactModal.show(
            context,
            title: 'Add New Contact',
            defaultRole: currentRole == 'all' ? null : currentRole,
          );
          if (created != null) {
            ref.invalidate(contactsListProvider(null));
            for (final r in _roles) {
              ref.invalidate(contactsListProvider(r == 'all' ? null : r));
            }
          }
        },
      ),
    );
  }
}

class _ContactsRoleList extends ConsumerWidget {
  final String? role;
  final String searchQuery;
  final Function(String) onCall;
  final Function(String) onEmail;
  final Function(Contact) onDelete;

  const _ContactsRoleList({
    required this.role,
    required this.searchQuery,
    required this.onCall,
    required this.onEmail,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(contactsListProvider(role));

    return contactsAsync.when(
      data: (contacts) {
        final filtered = contacts.where((c) {
          if (searchQuery.isEmpty) return true;
          final nameMatch = c.name.toLowerCase().contains(searchQuery);
          final phoneMatch = c.phone?.toLowerCase().contains(searchQuery) ?? false;
          final clinicMatch = c.clinicOrBusiness?.toLowerCase().contains(searchQuery) ?? false;
          return nameMatch || phoneMatch || clinicMatch;
        }).toList();

        if (filtered.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: ResponsiveBody(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.contact_phone_outlined, size: 56, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text(
                      'No Contacts in Directory',
                      style: AppTypography.displayHeadline.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Save your regular Veterinarians, Farriers, Dentists, and Buyers here for 1-tap reuse anywhere in the app.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primaryGold,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            ref.invalidate(contactsListProvider(role));
            ref.invalidate(contactsListProvider(null));
          },
          child: ResponsiveBody(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final c = filtered[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(color: AppColors.surface),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.inputField,
                              child: Icon(
                                _getRoleIcon(c.role),
                                color: AppColors.primaryGold,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.name,
                                    style: AppTypography.displayHeadline.copyWith(fontSize: 16),
                                  ),
                                  if (c.clinicOrBusiness?.isNotEmpty == true)
                                    Text(
                                      c.clinicOrBusiness!,
                                      style: AppTypography.bodySmall.copyWith(color: AppColors.primaryGold, fontSize: 12),
                                    ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.inputField,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                c.role.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                              tooltip: 'Delete Contact',
                              onPressed: () => onDelete(c),
                            ),
                          ],
                        ),
                        if (c.notes?.isNotEmpty == true) ...[
                          const SizedBox(height: 8),
                          Text(
                            c.notes!,
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (c.phone?.isNotEmpty == true)
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => onCall(c.phone!),
                                  icon: const Icon(Icons.phone, color: AppColors.primaryGold, size: 16),
                                  label: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      c.phone!,
                                      style: const TextStyle(color: AppColors.primaryGold, fontSize: 12),
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.primaryGold),
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                            if (c.phone?.isNotEmpty == true && c.email?.isNotEmpty == true)
                              const SizedBox(width: 8),
                            if (c.email?.isNotEmpty == true)
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => onEmail(c.email!),
                                  icon: const Icon(Icons.email_outlined, color: AppColors.textSecondary, size: 16),
                                  label: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      c.email!,
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.surface),
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
      loading: () => const AppLoadingView(message: 'Loading contacts...'),
      error: (e, _) => AppErrorView(
        error: e,
        onRetry: () => ref.invalidate(contactsListProvider(role)),
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'vet':
        return Icons.medical_services_outlined;
      case 'farrier':
        return Icons.build_outlined;
      case 'dentist':
        return Icons.health_and_safety_outlined;
      case 'owner':
      case 'buyer':
        return Icons.person_pin_outlined;
      default:
        return Icons.person_outline;
    }
  }
}
