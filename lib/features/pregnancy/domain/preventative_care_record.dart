class PreventativeCareRecord {
  final String id;
  final String ownerType; // 'mare', 'foal'
  final String ownerId;

  final DateTime? wormerDate;
  final bool wormerDone;

  final DateTime? tetanusDate;
  final bool tetanusDone;

  final DateTime? stranglesDate;
  final bool stranglesDone;

  final DateTime? eqHerpesDate;
  final bool eqHerpesDone;

  final DateTime? rotavirusDate;
  final bool rotavirusDone;

  final DateTime? hendraDate;
  final bool hendraDone;

  final DateTime? eqInfluenzaDate;
  final bool eqInfluenzaDone;

  final DateTime? eeeWeeWnvDate;
  final bool eeeWeeWnvDone;

  final DateTime? rabiesDate;
  final bool rabiesDone;

  final DateTime? dentalDate;
  final bool dentalDone;
  final String? dentistNumber;

  final DateTime? farrierDate;
  final bool farrierDone;
  final String? farrierNumber;

  final DateTime createdAt;

  const PreventativeCareRecord({
    required this.id,
    required this.ownerType,
    required this.ownerId,
    this.wormerDate,
    this.wormerDone = false,
    this.tetanusDate,
    this.tetanusDone = false,
    this.stranglesDate,
    this.stranglesDone = false,
    this.eqHerpesDate,
    this.eqHerpesDone = false,
    this.rotavirusDate,
    this.rotavirusDone = false,
    this.hendraDate,
    this.hendraDone = false,
    this.eqInfluenzaDate,
    this.eqInfluenzaDone = false,
    this.eeeWeeWnvDate,
    this.eeeWeeWnvDone = false,
    this.rabiesDate,
    this.rabiesDone = false,
    this.dentalDate,
    this.dentalDone = false,
    this.dentistNumber,
    this.farrierDate,
    this.farrierDone = false,
    this.farrierNumber,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_type': ownerType,
      'owner_id': ownerId,
      'wormer_date': wormerDate?.toIso8601String(),
      'wormer_done': wormerDone,
      'tetanus_date': tetanusDate?.toIso8601String(),
      'tetanus_done': tetanusDone,
      'strangles_date': stranglesDate?.toIso8601String(),
      'strangles_done': stranglesDone,
      'eq_herpes_date': eqHerpesDate?.toIso8601String(),
      'eq_herpes_done': eqHerpesDone,
      'rotavirus_date': rotavirusDate?.toIso8601String(),
      'rotavirus_done': rotavirusDone,
      'hendra_date': hendraDate?.toIso8601String(),
      'hendra_done': hendraDone,
      'eq_influenza_date': eqInfluenzaDate?.toIso8601String(),
      'eq_influenza_done': eqInfluenzaDone,
      'eee_wee_wnv_date': eeeWeeWnvDate?.toIso8601String(),
      'eee_wee_wnv_done': eeeWeeWnvDone,
      'rabies_date': rabiesDate?.toIso8601String(),
      'rabies_done': rabiesDone,
      'dental_date': dentalDate?.toIso8601String(),
      'dental_done': dentalDone,
      'dentist_number': dentistNumber,
      'farrier_date': farrierDate?.toIso8601String(),
      'farrier_done': farrierDone,
      'farrier_number': farrierNumber,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PreventativeCareRecord.fromJson(Map<String, dynamic> json) {
    return PreventativeCareRecord(
      id: json['id'] as String,
      ownerType: json['owner_type'] as String,
      ownerId: json['owner_id'] as String,
      wormerDate: json['wormer_date'] != null ? DateTime.parse(json['wormer_date'] as String) : null,
      wormerDone: json['wormer_done'] as bool? ?? false,
      tetanusDate: json['tetanus_date'] != null ? DateTime.parse(json['tetanus_date'] as String) : null,
      tetanusDone: json['tetanus_done'] as bool? ?? false,
      stranglesDate: json['strangles_date'] != null ? DateTime.parse(json['strangles_date'] as String) : null,
      stranglesDone: json['strangles_done'] as bool? ?? false,
      eqHerpesDate: json['eq_herpes_date'] != null ? DateTime.parse(json['eq_herpes_date'] as String) : null,
      eqHerpesDone: json['eq_herpes_done'] as bool? ?? false,
      rotavirusDate: json['rotavirus_date'] != null ? DateTime.parse(json['rotavirus_date'] as String) : null,
      rotavirusDone: json['rotavirus_done'] as bool? ?? false,
      hendraDate: json['hendra_date'] != null ? DateTime.parse(json['hendra_date'] as String) : null,
      hendraDone: json['hendra_done'] as bool? ?? false,
      eqInfluenzaDate: json['eq_influenza_date'] != null ? DateTime.parse(json['eq_influenza_date'] as String) : null,
      eqInfluenzaDone: json['eq_influenza_done'] as bool? ?? false,
      eeeWeeWnvDate: json['eee_wee_wnv_date'] != null ? DateTime.parse(json['eee_wee_wnv_date'] as String) : null,
      eeeWeeWnvDone: json['eee_wee_wnv_done'] as bool? ?? false,
      rabiesDate: json['rabies_date'] != null ? DateTime.parse(json['rabies_date'] as String) : null,
      rabiesDone: json['rabies_done'] as bool? ?? false,
      dentalDate: json['dental_date'] != null ? DateTime.parse(json['dental_date'] as String) : null,
      dentalDone: json['dental_done'] as bool? ?? false,
      dentistNumber: json['dentist_number'] as String?,
      farrierDate: json['farrier_date'] != null ? DateTime.parse(json['farrier_date'] as String) : null,
      farrierDone: json['farrier_done'] as bool? ?? false,
      farrierNumber: json['farrier_number'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
    );
  }
}
