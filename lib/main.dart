import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MonApplicationCV());
}

class MonApplicationCV extends StatelessWidget {
  const MonApplicationCV({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mon CV Flutter',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const PageConnexion(),
    );
  }
}

// ============================================================================
// MODÈLE DE DONNÉES : MEMBRE DE FAMILLE
// ============================================================================
class MembreFamille {
  final int id;
  final String nom;
  final String postnom;
  final String prenom;
  final String lieuNaissance;
  final String dateNaissance;
  final String parente;
  final String? imageUrl;

  MembreFamille({
    required this.id,
    required this.nom,
    required this.postnom,
    required this.prenom,
    required this.lieuNaissance,
    required this.dateNaissance,
    required this.parente,
    this.imageUrl,
  });

  factory MembreFamille.fromJson(Map<String, dynamic> json) {
    return MembreFamille(
      id: int.parse(json['id'].toString()),
      nom: json['nom'] ?? '',
      postnom: json['postnom'] ?? '',
      prenom: json['prenom'] ?? '',
      lieuNaissance: json['lieu_naissance'] ?? '',
      dateNaissance: json['date_naissance'] ?? '',
      parente: json['parente'] ?? '',
      imageUrl: json['image_url'],
    );
  }
}

// ============================================================================
// SERVICE API (CONNEXION + CRUD FAMILLE)
// ============================================================================
class ApiService {
  // ⚠️ REMPLACE CETTE ADRESSE PAR TON LIEN INFINITYFREE (ex: https://infinityfreeapp.com)
  static const String baseUrl = 'https://infinityfreeapp.com';

  static Future<Map<String, dynamic>> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/accounts/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/accounts/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  static Future<List<MembreFamille>> getMembres() async {
    final response = await http.get(Uri.parse('$baseUrl/famille-membres'));
    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      return (data['data'] as List).map((e) => MembreFamille.fromJson(e)).toList();
    }
    throw Exception(data['message'] ?? 'Erreur de chargement');
  }

  static Future<bool> ajouterMembre(Map<String, String> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/famille-membres'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return jsonDecode(response.body)['success'] == true;
  }

  static Future<bool> modifierMembre(int id, Map<String, String> body) async {
    final response = await http.put(
      Uri.parse('$baseUrl/famille-membres/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return jsonDecode(response.body)['success'] == true;
  }

  static Future<bool> supprimerMembre(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/famille-membres/$id'));
    return jsonDecode(response.body)['success'] == true;
  }
}

// ============================================================================
// PAGE 1 : PAGE DE CONNEXION & INSCRIPTION (AUTHENTIFICATION RÉELLE)
// ============================================================================
class PageConnexion extends StatefulWidget {
  const PageConnexion({super.key});

  @override
  State<PageConnexion> createState() => _PageConnexionState();
}

class _PageConnexionState extends State<PageConnexion> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _motDePasseController = TextEditingController();
  String _messageErreur = '';
  bool _modeConnexion = true;
  bool _chargement = false;
  bool _masquerMotDePasse = true;

  Future<void> _validerFormulaire() async {
    final email = _emailController.text.trim();
    final password = _motDePasseController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _messageErreur = 'Veuillez remplir tous les champs.');
      return;
    }

    setState(() {
      _chargement = true;
      _messageErreur = '';
    });

    try {
      final resultat = _modeConnexion
          ? await ApiService.login(email, password)
          : await ApiService.register(email, password);

      if (!mounted) return;

      if (resultat['success'] == true) {
        if (_modeConnexion) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const NavigationPrincipale()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Compte créé avec succès ! Connectez-vous.'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() => _modeConnexion = true);
        }
      } else {
        String msg = resultat['message'] ?? 'Identifiants incorrects.';
        if (resultat['errors'] != null && resultat['errors'] is Map) {
          msg = (resultat['errors'] as Map).values.join('\n');
        }
        setState(() => _messageErreur = msg);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messageErreur = 'Erreur de connexion à l\'API : $e';
      });
    } finally {
      if (mounted) setState(() => _chargement = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _modeConnexion ? Icons.lock_person : Icons.person_add,
                  size: 80,
                  color: Colors.indigo,
                ),
                const SizedBox(height: 20),
                Text(
                  _modeConnexion ? 'Bienvenue' : 'Créer un compte',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Adresse Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _motDePasseController,
                  obscureText: _masquerMotDePasse,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe (min. 6 caractères)',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_masquerMotDePasse ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _masquerMotDePasse = !_masquerMotDePasse),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_messageErreur.isNotEmpty)
                  Text(
                    _messageErreur,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _chargement ? null : _validerFormulaire,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                    child: _chargement
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _modeConnexion ? 'Se connecter' : 'S\'inscrire',
                            style: const TextStyle(fontSize: 18),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _modeConnexion = !_modeConnexion;
                      _messageErreur = '';
                    });
                  },
                  child: Text(
                    _modeConnexion
                        ? 'Pas de compte ? Créer un compte'
                        : 'Déjà inscrit ? Se connecter',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// NAVIGATION PRINCIPALE
// ============================================================================
class NavigationPrincipale extends StatefulWidget {
