import 'package:flutter/material.dart';

/// Langues proposées dans les formulaires parent et nounou.
const kRegisterLangOptions = ['Français', 'Fang', 'Myènè', 'Anglais', 'Autre'];

/// Ajoute [value] à [set] s'il est absent, le retire sinon.
void toggleSelection(Set<String> set, String value) {
  if (!set.add(value)) {
    set.remove(value);
  }
}

// ── Child data model ──────────────────────────────────────────────────────────
class ChildInfo {
  final TextEditingController firstName = TextEditingController();
  DateTime? birthDate;
  String gender = 'Garçon';
  String specialNeeds = 'Aucun';
  final TextEditingController allergies = TextEditingController();
  final TextEditingController medications = TextEditingController();

  void dispose() {
    firstName.dispose();
    allergies.dispose();
    medications.dispose();
  }
}

// ── Reference data model ──────────────────────────────────────────────────────
class Reference {
  final TextEditingController name = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController relation = TextEditingController();

  void dispose() {
    name.dispose();
    phone.dispose();
    relation.dispose();
  }
}

/// Détient l'ensemble des contrôleurs et valeurs du formulaire d'inscription.
///
/// La propriété (création + dispose) reste dans l'état de `RegisterScreen` ;
/// les widgets d'étapes reçoivent cette instance et n'en disposent jamais.
class RegisterFormData {
  // Section 1 — Identité (partagé)
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  DateTime? birthDate;
  String gender = 'Homme';
  final nationality = TextEditingController(text: 'Gabonaise');
  final phone = TextEditingController();
  final email = TextEditingController();
  String neighborhood = 'Akanda';
  final address = TextEditingController();
  String radius = '3 km';

  // Section 2 Parent — Enfants
  final List<ChildInfo> children = [ChildInfo()];

  // Section 3 Parent — Préférences
  String careType = 'À domicile (chez moi)';
  final Set<String> timeSlots = {};
  double maxBudget = 3000;
  final Set<String> homeLangs = {};
  final Set<String> careCriteria = {};

  // Section 4 Parent — Urgence
  final emerg1Name = TextEditingController();
  final emerg1Phone = TextEditingController();
  final emerg2Name = TextEditingController();
  final emerg2Phone = TextEditingController();
  final doctorName = TextEditingController();
  final doctorPhone = TextEditingController();
  String bloodGroup = 'Inconnu';
  bool transportAuth = false;
  bool photoAuth = false;

  // Section 5 Parent — Vérification
  bool acceptCGU = false;
  bool acceptPrivacy = false;
  bool certifyAccurate = false;

  // Section 2 Nanny — KYC
  //
  // Chemins des documents uploadés (chemin Storage `kyc/{uid}/{slot}.jpg`
  // quand Firebase est actif, chemin local du fichier choisi en mode démo).
  // `null` tant que le document n'a pas été fourni.
  final cniNumber = TextEditingController();
  String? cniRectoPath;
  String? cniVersoPath;
  String? selfiePath;
  String? criminalRecordPath;

  bool get hasCNIRecto => cniRectoPath != null;
  bool get hasCNIVerso => cniVersoPath != null;
  bool get hasSelfie => selfiePath != null;
  bool get hasCriminalRecord => criminalRecordPath != null;

  // Section 3 Nanny — Compétences
  String experience = 'Débutant (< 1 an)';
  final Set<String> ageGroups = {};
  final Set<String> nannySkills = {};
  String diploma = 'Aucun';
  final Set<String> nannyLangs = {};

  // Section 4 Nanny — Bio
  final shortBio = TextEditingController();
  final longBio = TextEditingController();

  // Section 5 Nanny — Disponibilités & Tarifs
  double hourlyRate = 2500;
  final Map<String, Set<String>> availability = {
    'Lundi': {},
    'Mardi': {},
    'Mercredi': {},
    'Jeudi': {},
    'Vendredi': {},
    'Samedi': {},
    'Dimanche': {},
  };
  bool urgentAvailable = false;
  String nannyCarMode = 'Les deux';
  String maxChildren = '2';

  // Section 6 Nanny — Paiement
  final Set<String> paymentMethods = {};
  final airtelNumber = TextEditingController();
  final moovNumber = TextEditingController();

  // Section 7 Nanny — Références
  final ref1 = Reference();
  final ref2 = Reference();

  // Section 8 Nanny — Engagement
  bool certifyNanny = false;
  bool acceptCGUNanny = false;
  bool acceptPrivacyNanny = false;
  bool acceptVerification = false;
  bool acceptCharter = false;

  // ── Brouillon (stocké sur l'appareil uniquement) ──────────────────────────
  // Les cases d'acceptation légales (CGU, confidentialité, engagements) ne
  // sont volontairement PAS restaurées : l'utilisateur re-confirme.

  Map<String, dynamic> toDraftJson() => {
    'firstName': firstName.text,
    'lastName': lastName.text,
    'birthDate': birthDate?.toIso8601String(),
    'gender': gender,
    'nationality': nationality.text,
    'phone': phone.text,
    'email': email.text,
    'neighborhood': neighborhood,
    'address': address.text,
    'radius': radius,
    'children': children
        .map(
          (c) => {
            'firstName': c.firstName.text,
            'birthDate': c.birthDate?.toIso8601String(),
            'gender': c.gender,
            'specialNeeds': c.specialNeeds,
            'allergies': c.allergies.text,
            'medications': c.medications.text,
          },
        )
        .toList(),
    'careType': careType,
    'timeSlots': timeSlots.toList(),
    'maxBudget': maxBudget,
    'homeLangs': homeLangs.toList(),
    'careCriteria': careCriteria.toList(),
    'emerg1Name': emerg1Name.text,
    'emerg1Phone': emerg1Phone.text,
    'emerg2Name': emerg2Name.text,
    'emerg2Phone': emerg2Phone.text,
    'doctorName': doctorName.text,
    'doctorPhone': doctorPhone.text,
    'bloodGroup': bloodGroup,
    'transportAuth': transportAuth,
    'photoAuth': photoAuth,
    'cniNumber': cniNumber.text,
    'cniRectoPath': cniRectoPath,
    'cniVersoPath': cniVersoPath,
    'selfiePath': selfiePath,
    'criminalRecordPath': criminalRecordPath,
    'experience': experience,
    'ageGroups': ageGroups.toList(),
    'nannySkills': nannySkills.toList(),
    'diploma': diploma,
    'nannyLangs': nannyLangs.toList(),
    'shortBio': shortBio.text,
    'longBio': longBio.text,
    'hourlyRate': hourlyRate,
    'availability': availability.map((d, s) => MapEntry(d, s.toList())),
    'urgentAvailable': urgentAvailable,
    'nannyCarMode': nannyCarMode,
    'maxChildren': maxChildren,
    'paymentMethods': paymentMethods.toList(),
    'airtelNumber': airtelNumber.text,
    'moovNumber': moovNumber.text,
    'ref1': {
      'name': ref1.name.text,
      'phone': ref1.phone.text,
      'relation': ref1.relation.text,
    },
    'ref2': {
      'name': ref2.name.text,
      'phone': ref2.phone.text,
      'relation': ref2.relation.text,
    },
  };

  static List<String> _strings(dynamic value) =>
      (value as List?)?.cast<String>() ?? const [];

  void restoreFromDraft(Map<String, dynamic> d) {
    firstName.text = d['firstName'] as String? ?? '';
    lastName.text = d['lastName'] as String? ?? '';
    birthDate = DateTime.tryParse(d['birthDate'] as String? ?? '');
    gender = d['gender'] as String? ?? gender;
    nationality.text = d['nationality'] as String? ?? nationality.text;
    phone.text = d['phone'] as String? ?? '';
    email.text = d['email'] as String? ?? '';
    neighborhood = d['neighborhood'] as String? ?? neighborhood;
    address.text = d['address'] as String? ?? '';
    radius = d['radius'] as String? ?? radius;

    final draftChildren = (d['children'] as List?) ?? const [];
    if (draftChildren.isNotEmpty) {
      for (final c in children) {
        c.dispose();
      }
      children
        ..clear()
        ..addAll(
          draftChildren.map((raw) {
            final json = (raw as Map).cast<String, dynamic>();
            final child = ChildInfo()
              ..firstName.text = json['firstName'] as String? ?? ''
              ..birthDate = DateTime.tryParse(
                json['birthDate'] as String? ?? '',
              )
              ..gender = json['gender'] as String? ?? 'Garçon'
              ..specialNeeds = json['specialNeeds'] as String? ?? 'Aucun'
              ..allergies.text = json['allergies'] as String? ?? ''
              ..medications.text = json['medications'] as String? ?? '';
            return child;
          }),
        );
    }

    careType = d['careType'] as String? ?? careType;
    timeSlots
      ..clear()
      ..addAll(_strings(d['timeSlots']));
    maxBudget = (d['maxBudget'] as num?)?.toDouble() ?? maxBudget;
    homeLangs
      ..clear()
      ..addAll(_strings(d['homeLangs']));
    careCriteria
      ..clear()
      ..addAll(_strings(d['careCriteria']));
    emerg1Name.text = d['emerg1Name'] as String? ?? '';
    emerg1Phone.text = d['emerg1Phone'] as String? ?? '';
    emerg2Name.text = d['emerg2Name'] as String? ?? '';
    emerg2Phone.text = d['emerg2Phone'] as String? ?? '';
    doctorName.text = d['doctorName'] as String? ?? '';
    doctorPhone.text = d['doctorPhone'] as String? ?? '';
    bloodGroup = d['bloodGroup'] as String? ?? bloodGroup;
    transportAuth = d['transportAuth'] as bool? ?? false;
    photoAuth = d['photoAuth'] as bool? ?? false;
    cniNumber.text = d['cniNumber'] as String? ?? '';
    cniRectoPath = d['cniRectoPath'] as String?;
    cniVersoPath = d['cniVersoPath'] as String?;
    selfiePath = d['selfiePath'] as String?;
    criminalRecordPath = d['criminalRecordPath'] as String?;
    experience = d['experience'] as String? ?? experience;
    ageGroups
      ..clear()
      ..addAll(_strings(d['ageGroups']));
    nannySkills
      ..clear()
      ..addAll(_strings(d['nannySkills']));
    diploma = d['diploma'] as String? ?? diploma;
    nannyLangs
      ..clear()
      ..addAll(_strings(d['nannyLangs']));
    shortBio.text = d['shortBio'] as String? ?? '';
    longBio.text = d['longBio'] as String? ?? '';
    hourlyRate = (d['hourlyRate'] as num?)?.toDouble() ?? hourlyRate;
    final draftAvailability =
        (d['availability'] as Map?)?.cast<String, dynamic>() ?? const {};
    for (final entry in draftAvailability.entries) {
      availability[entry.key]
        ?..clear()
        ..addAll(_strings(entry.value));
    }
    urgentAvailable = d['urgentAvailable'] as bool? ?? false;
    nannyCarMode = d['nannyCarMode'] as String? ?? nannyCarMode;
    maxChildren = d['maxChildren'] as String? ?? maxChildren;
    paymentMethods
      ..clear()
      ..addAll(_strings(d['paymentMethods']));
    airtelNumber.text = d['airtelNumber'] as String? ?? '';
    moovNumber.text = d['moovNumber'] as String? ?? '';
    final r1 = (d['ref1'] as Map?)?.cast<String, dynamic>() ?? const {};
    ref1.name.text = r1['name'] as String? ?? '';
    ref1.phone.text = r1['phone'] as String? ?? '';
    ref1.relation.text = r1['relation'] as String? ?? '';
    final r2 = (d['ref2'] as Map?)?.cast<String, dynamic>() ?? const {};
    ref2.name.text = r2['name'] as String? ?? '';
    ref2.phone.text = r2['phone'] as String? ?? '';
    ref2.relation.text = r2['relation'] as String? ?? '';
  }

  void dispose() {
    firstName.dispose();
    lastName.dispose();
    nationality.dispose();
    phone.dispose();
    email.dispose();
    address.dispose();
    for (final c in children) {
      c.dispose();
    }
    emerg1Name.dispose();
    emerg1Phone.dispose();
    emerg2Name.dispose();
    emerg2Phone.dispose();
    doctorName.dispose();
    doctorPhone.dispose();
    cniNumber.dispose();
    shortBio.dispose();
    longBio.dispose();
    airtelNumber.dispose();
    moovNumber.dispose();
    ref1.dispose();
    ref2.dispose();
  }
}
