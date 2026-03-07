import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/router/app_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Base Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedNeighborhood = 'Akanda';
  int _childrenCount = 1;
  bool _acceptedTerms = false;

  // Nanny specific
  DateTime? _birthDate;
  final _cniController = TextEditingController();
  int _experienceYears = 0;
  final _rateController = TextEditingController();
  final _bioController = TextEditingController();
  final List<String> _selectedSkills = [];

  String role = 'parent';

  final List<String> _neighborhoods = [
    'Akanda',
    'Angondjé',
    'Nzeng-Ayong',
    'Owendo',
    'Glass',
    'Nombakélé',
    'Alibandeng',
    'Autre',
  ];

  final List<String> _availableSkills = [
    'Premiers secours',
    'Cuisine',
    'Aide aux devoirs',
    'Éveil musical',
    'Jeux créatifs',
    'Hygiène bébé',
    'Langues étrangères',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uri = Uri.parse(GoRouterState.of(context).uri.toString());
    role = uri.queryParameters['role'] ?? 'parent';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cniController.dispose();
    _rateController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState!.validate() && _acceptedTerms) {
      if (role == 'nanny' && _birthDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner une date de naissance.'),
          ),
        );
        return;
      }
      // Simulation: registration complete
      await setUserRole(role);
      await setAuthenticated(true);
      if (mounted) context.go('/home');
    } else if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez accepter les conditions d\'utilisation.'),
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 365 * 18),
      ), // 18 years ago minimum
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(
        const Duration(days: 365 * 16),
      ), // Minimum 16 yo
    );
    if (picked != null && picked != _birthDate) {
      setState(() => _birthDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNanny = role == 'nanny';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Créer un compte',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/auth/login?role=$role');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Avatar Upload Placeholder
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color(0xFFFF6B35),
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Base Fields
                _buildInputLabel('Nom complet'),
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration(
                    icon: Icons.person_outline,
                    hint: 'Ex: Marie Ndong',
                  ),
                  validator: (v) => Validators.validateRequired(v, 'Le nom'),
                ),
                const SizedBox(height: 20),

                _buildInputLabel('Adresse email'),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(
                    icon: Icons.email_outlined,
                    hint: 'Ex: marie@email.com',
                  ),
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 20),

                _buildInputLabel('Quartier de résidence'),
                DropdownButtonFormField<String>(
                  initialValue: _selectedNeighborhood,
                  decoration: _inputDecoration(
                    icon: Icons.location_on_outlined,
                  ),
                  items: _neighborhoods.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) =>
                      setState(() => _selectedNeighborhood = newValue!),
                ),
                const SizedBox(height: 20),

                _buildInputLabel(
                  isNanny
                      ? 'Nombre d\'enfants à charge (optionnel)'
                      : 'Nombre d\'enfants',
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      color: const Color(0xFFFF6B35),
                      onPressed: () {
                        if (_childrenCount > 0) {
                          setState(() => _childrenCount--);
                        }
                      },
                    ),
                    Text(
                      '$_childrenCount',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      color: const Color(0xFFFF6B35),
                      onPressed: () => setState(() => _childrenCount++),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Nanny Specific Fields
                if (isNanny) ...[
                  const Divider(thickness: 1.5),
                  const SizedBox(height: 24),
                  Text(
                    'Informations Professionnelles',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildInputLabel('Date de naissance'),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade50,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _birthDate == null
                                ? 'Sélectionner une date'
                                : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
                            style: TextStyle(
                              color: _birthDate == null
                                  ? Colors.grey.shade600
                                  : Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildInputLabel('Numéro CNI / Passeport'),
                  TextFormField(
                    controller: _cniController,
                    decoration: _inputDecoration(
                      icon: Icons.credit_card,
                      hint: 'Ex: 123456789',
                    ),
                    validator: Validators.validateCNI,
                  ),
                  const SizedBox(height: 20),

                  _buildInputLabel('Années d\'expérience'),
                  DropdownButtonFormField<int>(
                    initialValue: _experienceYears,
                    decoration: _inputDecoration(icon: Icons.work_outline),
                    items: List.generate(
                      21,
                      (i) =>
                          DropdownMenuItem(value: i, child: Text('$i an(s)')),
                    ),
                    onChanged: (val) => setState(() => _experienceYears = val!),
                  ),
                  const SizedBox(height: 20),

                  _buildInputLabel('Tarif horaire souhaité'),
                  TextFormField(
                    controller: _rateController,
                    keyboardType: TextInputType.number,
                    decoration:
                        _inputDecoration(
                          icon: Icons.payments_outlined,
                          hint: 'Ex: 3000',
                        ).copyWith(
                          suffixText: 'FCFA/h',
                          suffixStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    validator: (v) =>
                        Validators.validateRequired(v, 'Le tarif horaire'),
                  ),
                  const SizedBox(height: 20),

                  _buildInputLabel('Bio / Présentation (300 car. max)'),
                  TextFormField(
                    controller: _bioController,
                    maxLength: 300,
                    maxLines: 4,
                    decoration: _inputDecoration(
                      hint: 'Présentez-vous en quelques mots...',
                    ),
                    validator: (v) => Validators.validateRequired(v, 'La bio'),
                  ),
                  const SizedBox(height: 20),

                  _buildInputLabel('Compétences'),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _availableSkills.map((skill) {
                      final isSelected = _selectedSkills.contains(skill);
                      return FilterChip(
                        label: Text(skill),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedSkills.add(skill);
                            } else {
                              _selectedSkills.remove(skill);
                            }
                          });
                        },
                        selectedColor: const Color(
                          0xFFFF6B35,
                        ).withValues(alpha: 0.2),
                        checkmarkColor: const Color(0xFFFF6B35),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                ],

                // Terms Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _acceptedTerms,
                      activeColor: const Color(0xFFFF6B35),
                      onChanged: (val) =>
                          setState(() => _acceptedTerms = val ?? false),
                    ),
                    const Expanded(
                      child: Text(
                        'J\'accepte les conditions d\'utilisation et la politique de confidentialité',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: _onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Créer mon compte',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({IconData? icon, String? hint}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: Colors.grey.shade500) : null,
      filled: true,
      fillColor: Colors.grey.shade50,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}
