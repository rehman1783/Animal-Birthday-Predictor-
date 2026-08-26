import '../domain/faq_item.dart';

/// Centralized FAQ repository containing all questions, answers, and category filters.
/// The client can easily provide or update questions and answers directly in this file.
class FaqData {
  static const List<FaqItem> defaultFaqs = [
    // --- EQUINE & FOALING ---
    FaqItem(
      id: 'eq_1',
      category: FaqCategory.equine,
      question: 'How is the equine due date calculated for Natural vs. AI vs. Embryo Transfer?',
      answer:
          'For Natural Service and Artificial Insemination (AI), the expected due date is calculated at 340 days from the service date (safe range 320–365 days).\n\nFor Embryo Transfer (ET), calculation begins from the Recipient Mare transfer date plus 7 days of embryo development age (total gestation 340 days from effective fertilization).',
      tags: ['due date', 'gestation', 'ai', 'et', 'embryo transfer', 'mare'],
    ),
    FaqItem(
      id: 'eq_2',
      category: FaqCategory.equine,
      question: 'What is the standard ultrasound scanning schedule for pregnant mares?',
      answer:
          'Standard veterinarian scanning milestones recommended for Thoroughbred and Sport Horse breeding:\n'
          '• Scan 1 (14–16 Days): Early pregnancy confirmation and crucial twin vesicle detection.\n'
          '• Scan 2 (28–30 Days): Embryonic heartbeat verification and development check.\n'
          '• Scan 3 (45 Days): Final confirmation of organogenesis and fetus viability for commercial breeding certificates.',
      tags: ['scans', 'ultrasound', '14 days', '28 days', '45 days', 'twins'],
    ),
    FaqItem(
      id: 'eq_3',
      category: FaqCategory.equine,
      question: 'When should mares be moved into closer paddocks and the foaling barn?',
      answer:
          'Standard stud management protocol:\n'
          '• Move to close foaling paddocks: Approximately 30 days before the estimated due date for daily udder monitoring.\n'
          '• Move into foaling barn/box: 7–14 days prior to due date or upon wax appearance and calcium test softening.',
      tags: ['foaling barn', 'paddock', 'due date', 'management'],
    ),

    // --- CANINE & PUPPIES ---
    FaqItem(
      id: 'can_1',
      category: FaqCategory.canine,
      question: 'How long is the canine gestation period and when is whelping expected?',
      answer:
          'The average canine gestation period is 63 days (range 58–68 days) from the first mating or ovulation date. Ovulation timing via progesterone testing provides the most precise whelping forecast (+/- 1 day).',
      tags: ['dog', 'bitch', 'puppy', 'gestation', 'whelping', '63 days'],
    ),
    FaqItem(
      id: 'can_2',
      category: FaqCategory.canine,
      question: 'What preventative care schedule is recommended for newborn puppies?',
      answer:
          'Standard recommended canine care protocol in the app:\n'
          '• Worming: Every 2 weeks from 2 weeks of age until 8 weeks (2, 4, 6, and 8 weeks), then monthly to 6 months.\n'
          '• 1st Vaccination (C3/C5): 6–8 weeks of age.\n'
          '• 2nd Vaccination Booster: 10–12 weeks of age.\n'
          '• Microchipping: 6–8 weeks before rehoming.\n'
          '• Full Vet Check: 6-week and 8-week pre-departure check.',
      tags: ['puppy', 'worming', 'vaccine', 'c5', 'microchip', 'health'],
    ),

    // --- ULTRASOUND & SCANS ---
    FaqItem(
      id: 'scan_1',
      category: FaqCategory.scans,
      question: 'What happens if twins are detected on the first ultrasound scan?',
      answer:
          'The app triggers a high-priority Twin Alert with amber/red notification badges. Equine twins carry severe risks of abortion or dystocia. When twins are detected, prompt veterinarian intervention (manual vesicle reduction before Day 16 fixation) and an organised re-scan are strongly recommended.',
      tags: ['twins', 'warning', 'ultrasound', 'rescan', 'manual reduction'],
    ),
    FaqItem(
      id: 'scan_2',
      category: FaqCategory.scans,
      question: 'How do I generate a 45-Day Scan Certificate?',
      answer:
          'Navigate to the Pregnancy section for your Mare, select the 45-Day Scan record, ensure vet details and confirmation are entered, and tap "Generate 45-Day Scan Certificate". You can view, print, or export a PDF certificate complete with microchip, sire, and veterinarian credentials.',
      tags: ['45 day', 'certificate', 'pdf', 'vet', 'scan'],
    ),

    // --- CERTIFICATES & EXPORT ---
    FaqItem(
      id: 'cert_1',
      category: FaqCategory.certificates,
      question: 'Can I export certificates as PDF documents for stud records and buyers?',
      answer:
          'Yes. All official certificates generated in Animal Birthday Predictor (45-Day Scan Certificates, Breeding Certificates, and Puppy Health & Immunization Certificates) can be instantly downloaded, shared, or printed directly to AirPrint/wireless printers.',
      tags: ['pdf', 'print', 'export', 'download', 'share'],
    ),
    FaqItem(
      id: 'cert_2',
      category: FaqCategory.certificates,
      question: 'Are certificates compliant with Thoroughbred and Sport Horse breeding standards?',
      answer:
          'Yes. Our certificates include all key industry fields: Mare & Stallion registered names, passport/microchip IDs, recipient mare details (where applicable), service dates, 45-day ultrasound verification status, veterinarian signature placeholders, and legal disclaimer footers.',
      tags: ['thoroughbred', 'sport horse', 'compliance', 'standards'],
    ),

    // --- ACCOUNT & DATA ---
    FaqItem(
      id: 'acc_1',
      category: FaqCategory.account,
      question: 'Is my breeding data backed up and secure?',
      answer:
          'Yes. All records, animal profiles, pregnancy milestones, and preventative care entries are securely encrypted and synchronized to your private Supabase cloud account with Row Level Security (RLS) isolation.',
      tags: ['cloud', 'backup', 'security', 'supabase', 'privacy'],
    ),
    FaqItem(
      id: 'acc_2',
      category: FaqCategory.account,
      question: 'Can I use the application offline or on mobile devices?',
      answer:
          'Yes. The application is built with a mobile-first responsive architecture and local caching fallback, allowing you to access animal records and calculate due dates even in barn areas with intermittent connectivity.',
      tags: ['offline', 'mobile', 'web', 'responsive', 'sync'],
    ),
  ];
}
