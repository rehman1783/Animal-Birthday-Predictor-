enum FaqCategory {
  all('All Questions', 'Browse all topics'),
  equine('Equine & Foaling', 'Mares, AI, ET, foaling milestones'),
  canine('Canine & Puppies', 'Bitches, litters, preventative care'),
  scans('Ultrasound & Scans', 'Pregnancy confirmation & twin checks'),
  certificates('Certificates & Export', 'PDF breeding & health documents'),
  account('Account & App Data', 'Profiles, synchronization & backup');

  final String title;
  final String description;
  const FaqCategory(this.title, this.description);
}

class FaqItem {
  final String id;
  final FaqCategory category;
  final String question;
  final String answer;
  final List<String> tags;

  const FaqItem({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
    this.tags = const [],
  });
}
