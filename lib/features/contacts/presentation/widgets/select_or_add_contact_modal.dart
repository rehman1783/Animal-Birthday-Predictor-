import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/app_uuid.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../domain/contact.dart';
import '../providers/contact_provider.dart';

class SelectOrAddContactModal extends ConsumerStatefulWidget {
  final String title;
  final String? defaultRole;
  final String? currentSelectedId;

  const SelectOrAddContactModal({
    super.key,
    required this.title,
    this.defaultRole,
    this.currentSelectedId,
  });

  static Future<Contact?> show(
    BuildContext context, {
    required String title,
    String? defaultRole,
    String? currentSelectedId,
  }) {
    return showModalBottomSheet<Contact>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectOrAddContactModal(
        title: title,
        defaultRole: defaultRole,
        currentSelectedId: currentSelectedId,
      ),
    );
  }

  @override
  ConsumerState<SelectOrAddContactModal> createState() => _SelectOrAddContactModalState();
}

class _SelectOrAddContactModalState extends ConsumerState<SelectOrAddContactModal> {
  bool _isCreatingNew = false;
  String _searchQuery = '';
  late String _selectedRole;

  // New Contact form controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _clinicController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.defaultRole ?? 'all';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _clinicController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveNewContact() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final repo = ref.read(contactRepositoryProvider);
      final newContact = Contact(
        id: AppUuid.generate(),
        accountId: '',
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        role: widget.defaultRole != null && widget.defaultRole != 'all'
            ? widget.defaultRole!
            : _selectedRole != 'all'
                ? _selectedRole
                : 'general',
        clinicOrBusiness: _clinicController.text.trim(),
        notes: _notesController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final saved = await repo.saveContact(newContact);
      ref.invalidate(contactsListProvider(null));
      ref.invalidate(contactsListProvider(widget.defaultRole));
      ref.invalidate(contactsListProvider(_selectedRole));

      if (mounted) {
        Navigator.pop(context, saved);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save contact: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsListProvider(
      _selectedRole == 'all' ? null : _selectedRole,
    ));

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              // Handle bar
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _isCreatingNew ? 'ADD NEW CONTACT' : widget.title.toUpperCase(),
                        style: AppTypography.sectionLabel,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textMuted),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.surface, height: 1),

              // View switcher: List vs New Form
              Expanded(
                child: _isCreatingNew ? _buildNewContactForm() : _buildContactList(contactsAsync),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactList(AsyncValue<List<Contact>> contactsAsync) {
    return Column(
      children: [
        // Action Button: Add New Contact
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _isCreatingNew = true),
                  icon: const Icon(Icons.person_add_alt_1, color: AppColors.primaryGold, size: 18),
                  label: Text(
                    '+ ADD NEW CONTACT',
                    style: AppTypography.buttonLabel.copyWith(color: AppColors.primaryGold, fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryGold),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.cardRadius)),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: TextField(
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search contacts by name, clinic, or phone...',
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

        // Role Filter Chips (if not locked to a specific role)
        if (widget.defaultRole == null)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _RoleFilterChip(
                  label: 'ALL',
                  isSelected: _selectedRole == 'all',
                  onSelected: () => setState(() => _selectedRole = 'all'),
                ),
                const SizedBox(width: 8),
                _RoleFilterChip(
                  label: 'VET',
                  isSelected: _selectedRole == 'vet',
                  onSelected: () => setState(() => _selectedRole = 'vet'),
                ),
                const SizedBox(width: 8),
                _RoleFilterChip(
                  label: 'FARRIER',
                  isSelected: _selectedRole == 'farrier',
                  onSelected: () => setState(() => _selectedRole = 'farrier'),
                ),
                const SizedBox(width: 8),
                _RoleFilterChip(
                  label: 'DENTIST',
                  isSelected: _selectedRole == 'dentist',
                  onSelected: () => setState(() => _selectedRole = 'dentist'),
                ),
                const SizedBox(width: 8),
                _RoleFilterChip(
                  label: 'BUYER / OWNER',
                  isSelected: _selectedRole == 'buyer' || _selectedRole == 'owner',
                  onSelected: () => setState(() => _selectedRole = 'buyer'),
                ),
              ],
            ),
          ),

        // Contacts List
        Expanded(
          child: contactsAsync.when(
            data: (contacts) {
              final filtered = contacts.where((c) {
                if (_searchQuery.isEmpty) return true;
                final nameMatch = c.name.toLowerCase().contains(_searchQuery);
                final phoneMatch = c.phone?.toLowerCase().contains(_searchQuery) ?? false;
                final clinicMatch = c.clinicOrBusiness?.toLowerCase().contains(_searchQuery) ?? false;
                return nameMatch || phoneMatch || clinicMatch;
              }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.contact_phone_outlined, size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          'No contacts found',
                          style: AppTypography.displayHeadline.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tap "+ Add New Contact" to save a new contact directly.',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final c = filtered[index];
                  final isSelected = c.id == widget.currentSelectedId;

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryGold : AppColors.surface,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.inputField,
                        child: Icon(
                          _getRoleIcon(c.role),
                          color: AppColors.primaryGold,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        c.name,
                        style: AppTypography.displayHeadline.copyWith(fontSize: 15),
                      ),
                      subtitle: Text(
                        [
                          if (c.clinicOrBusiness?.isNotEmpty == true) c.clinicOrBusiness!,
                          if (c.phone?.isNotEmpty == true) c.phone!,
                          c.role.toUpperCase(),
                        ].join(' • '),
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      trailing: const Icon(Icons.check_circle_outline, color: AppColors.primaryGold, size: 20),
                      onTap: () => Navigator.pop(context, c),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGold)),
            error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.redAccent))),
          ),
        ),
      ],
    );
  }

  Widget _buildNewContactForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              label: 'Full Name *',
              hintText: 'e.g. Dr. Sarah Jenkins',
              controller: _nameController,
              prefixIcon: Icons.person_outline,
              validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              label: 'Phone Number (Optional)',
              hintText: 'e.g. +1 (555) 019-2834',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              label: 'Email Address (Optional)',
              hintText: 'e.g. contact@clinic.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              label: 'Clinic / Business Name (Optional)',
              hintText: 'e.g. Valley Equine Hospital',
              controller: _clinicController,
              prefixIcon: Icons.business_outlined,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              label: 'Notes / Address (Optional)',
              hintText: 'e.g. 104 Highway 1, primary vet for ultrasound...',
              controller: _notesController,
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _isCreatingNew = false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.textMuted),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.cardRadius)),
                    ),
                    child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GradientCtaButton(
                    text: _isSaving ? 'SAVING...' : 'SAVE CONTACT',
                    onPressed: _isSaving ? null : _saveNewContact,
                  ),
                ),
              ],
            ),
          ],
        ),
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

class _RoleFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _RoleFilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGold : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryGold : AppColors.surface,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.background : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
