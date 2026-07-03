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
  final cniNumber = TextEditingController();
  bool hasCNIRecto = false;
  bool hasCNIVerso = false;
  bool hasSelfie = false;
  bool hasCriminalRecord = false;

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
  bool acceptVerification = false;
  bool acceptCharter = false;

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
