import 'package:flutter_test/flutter_test.dart';
import 'package:animal_birthday_predictor/features/contacts/data/contact_repository.dart';
import 'package:animal_birthday_predictor/features/contacts/domain/contact.dart';
import 'package:animal_birthday_predictor/features/puppy/data/puppy_repository.dart';
import 'package:animal_birthday_predictor/features/puppy/domain/puppy.dart';
import 'package:animal_birthday_predictor/features/puppy/domain/puppy_weight.dart';
import 'package:animal_birthday_predictor/features/animals/domain/animal.dart';
import 'package:animal_birthday_predictor/features/foal/domain/foal_record.dart';
import 'package:animal_birthday_predictor/features/certificates/data/pdf_certificate_service.dart';

void main() {
  group('ABP Complete Feature Suite Tests', () {
    test('Contacts Directory: CRUD and Role Filtering', () async {
      final repo = ContactRepository();

      // Add contacts
      final vet = Contact(
        id: 'vet-1',
        accountId: 'acc-1',
        name: 'Dr. John Doe (Equine Clinic)',
        phone: '+1 555 123 4567',
        role: 'vet',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final farrier = Contact(
        id: 'farrier-1',
        accountId: 'acc-1',
        name: 'Sam Farrier Services',
        phone: '+1 555 987 6543',
        role: 'farrier',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final buyer = Contact(
        id: 'buyer-1',
        accountId: 'acc-1',
        name: 'Alice Cooper',
        phone: '+1 555 333 4444',
        role: 'buyer',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repo.saveContact(vet);
      final savedFarrier = await repo.saveContact(farrier);
      await repo.saveContact(buyer);

      final allContacts = await repo.getContacts();
      expect(allContacts.length, 3);

      final vetsOnly = await repo.getContacts(role: 'vet');
      expect(vetsOnly.length, 1);
      expect(vetsOnly.first.name, 'Dr. John Doe (Equine Clinic)');

      final farriersOnly = await repo.getContacts(role: 'farrier');
      expect(farriersOnly.length, 1);
      expect(farriersOnly.first.role, 'farrier');

      // Delete contact
      await repo.deleteContact(savedFarrier.id);
      final updatedFarriers = await repo.getContacts(role: 'farrier');
      expect(updatedFarriers.isEmpty, true);
    });

    test('Puppy Module: CRUD, Weights and Dual-Date Health Protocols', () async {
      final repo = PuppyRepository();

      final puppy = Puppy(
        id: 'puppy-101',
        accountId: 'acc-1',
        puppyName: 'Thor',
        collarTagColour: 'Red',
        sex: 'male',
        colour: 'Golden Sable',
        birthOrder: 1,
        dateOfBirth: DateTime(2026, 3, 1),
        birthWeight: '450g',
        currentWeight: '3.8kg',
        status: 'reserved',
        newOwnerName: 'Michael Scott',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final saved = await repo.savePuppy(puppy);
      expect(saved.puppyName, 'Thor');
      expect(saved.collarTagColour, 'Red');
      expect(saved.status, 'reserved');

      // Weights logging
      final weight1 = PuppyWeight(
        id: 'w-1',
        puppyId: saved.id,
        accountId: 'acc-1',
        weightDate: DateTime(2026, 3, 1),
        ageInDays: 0,
        weight: '450g',
        notes: 'Birth weight recorded',
        createdAt: DateTime.now(),
      );

      final weight2 = PuppyWeight(
        id: 'w-2',
        puppyId: saved.id,
        accountId: 'acc-1',
        weightDate: DateTime(2026, 3, 8),
        ageInDays: 7,
        weight: '720g',
        notes: '1 week healthy growth',
        createdAt: DateTime.now(),
      );

      await repo.savePuppyWeight(weight1);
      await repo.savePuppyWeight(weight2);

      final weights = await repo.getPuppyWeights(saved.id);
      expect(weights.length, 2);
      expect(weights.first.weight, '450g');
      expect(weights.last.weight, '720g');

      // Health Schedule initialization (Date Given + Date Due pairs)
      final schedule = await repo.initializeDefaultDogSchedule(
        ownerType: 'puppy',
        ownerId: saved.id,
        dateOfBirth: saved.dateOfBirth,
      );

      expect(schedule.isNotEmpty, true);
      final worming2Wks = schedule.firstWhere((item) => item.title.contains('2 Weeks'));
      expect(worming2Wks.treatmentType, 'worming');
      expect(worming2Wks.dateDue, DateTime(2026, 3, 15));
      expect(worming2Wks.isCompleted, false);

      // Complete item with Date Given
      final updatedWorming = worming2Wks.copyWith(
        isCompleted: true,
        dateGiven: DateTime(2026, 3, 15),
        administeredBy: 'Breeder Self',
      );
      await repo.saveDogPreventativeCareItem(updatedWorming);

      final reloadedCare = await repo.getDogPreventativeCare('puppy', saved.id);
      final completedItem = reloadedCare.firstWhere((i) => i.id == updatedWorming.id);
      expect(completedItem.isCompleted, true);
      expect(completedItem.dateGiven, DateTime(2026, 3, 15));
    });

    test('Foal Module: Buyer Information & Sold Status', () {
      final foal = FoalRecord(
        id: 'foal-1',
        accountId: 'acc-1',
        mareAnimalId: 'mare-1',
        foalName: 'Starlight Eclipse',
        sex: 'colt',
        status: 'sold',
        buyerName: 'David H. Miller',
        buyerPhone: '+1 555 777 8888',
        buyerAddress: '99 Equine Way, Lexington KY',
        saleDate: DateTime(2026, 6, 1),
        salePrice: '15000.00',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(foal.status, 'sold');
      expect(foal.buyerName, 'David H. Miller');
      expect(foal.salePrice, '15000.00');

      final json = foal.toJson();
      expect(json['buyer_name'], 'David H. Miller');
      expect(json['sale_price'], '15000.00');

      final deserialized = FoalRecord.fromJson(json);
      expect(deserialized.buyerName, 'David H. Miller');
      expect(deserialized.status, 'sold');
    });

    test('PDF Certificate Generator: Produces valid Equine and Canine PDFs', () async {
      final damMare = Animal(
        id: 'mare-1',
        accountId: 'acc-1',
        name: 'Lady Aurelia',
        species: 'horse',
        breed: 'Thoroughbred',
        microchipNo: '985141001234567',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final foal = FoalRecord(
        id: 'foal-1',
        accountId: 'acc-1',
        mareAnimalId: damMare.id,
        foalName: 'Golden Sunrise',
        stallion: 'Frankel',
        breed: 'Thoroughbred',
        sex: 'filly',
        dateOfBirth: DateTime(2026, 4, 15),
        foalMicrochipNo: '985141009876543',
        dna: 'DNA-KY-88912',
        studBookAssociation: 'The Jockey Club',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final equinePdfBytes = await PdfCertificateService.generateFoalCertificate(
        foal: foal,
        dam: damMare,
        prevCare: null,
        breederName: 'Bluegrass Stud Farm',
        breederEmail: 'records@bluegrass.com',
      );

      expect(equinePdfBytes.isNotEmpty, true);
      expect(equinePdfBytes.length, greaterThan(1000));

      final puppy = Puppy(
        id: 'puppy-1',
        accountId: 'acc-1',
        puppyName: 'Bella',
        collarTagColour: 'Pink',
        sex: 'female',
        colour: 'Ruby Red',
        birthOrder: 2,
        dateOfBirth: DateTime(2026, 5, 10),
        birthWeight: '380g',
        currentWeight: '2.9kg',
        newOwnerName: 'Sarah Jenkins',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final caninePdfBytes = await PdfCertificateService.generatePuppyCertificate(
        puppy: puppy,
        dam: null,
        healthItems: [],
        breederName: 'Royal Kennels',
        breederEmail: 'sarah@royalkennels.com',
      );

      expect(caninePdfBytes.isNotEmpty, true);
      expect(caninePdfBytes.length, greaterThan(1000));
    });
  });
}
