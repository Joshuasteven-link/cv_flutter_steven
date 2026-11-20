import 'package:flutter/material.dart';

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
// PAGE 1 : PAGE DE CONNEXION
// ============================================================================
class PageConnexion extends StatefulWidget {
  const PageConnexion({super.key});

  @override
  State<PageConnexion> createState() => _PageConnexionState();
}

class _PageConnexionState extends State<PageConnexion> {
  final TextEditingController _identifiantController = TextEditingController();
  final TextEditingController _motDePasseController = TextEditingController();
  String _messageErreur = '';

  void _seConnecter() {
    if (_identifiantController.text.isNotEmpty &&
        _motDePasseController.text.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NavigationPrincipale()),
      );
    } else {
      setState(() {
        _messageErreur = 'Veuillez remplir tous les champs.';
      });
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
                const Icon(Icons.lock_person, size: 80, color: Colors.indigo),
                const SizedBox(height: 20),
                const Text(
                  'Bienvenue',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _identifiantController,
                  decoration: const InputDecoration(
                    labelText: 'Identifiant',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _motDePasseController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 12),
                if (_messageErreur.isNotEmpty)
                  Text(
                    _messageErreur,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _seConnecter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Se connecter',
                      style: TextStyle(fontSize: 18),
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
}

// ============================================================================
// NAVIGATION PRINCIPALE
// ============================================================================
class NavigationPrincipale extends StatefulWidget {
  const NavigationPrincipale({super.key});

  @override
  State<NavigationPrincipale> createState() => _NavigationPrincipaleState();
}

class _NavigationPrincipaleState extends State<NavigationPrincipale> {
  int _indexActuel = 0;

  final List<Widget> _pages = const [
    PageAccueilCV(),
    PageFamille(),
    PageContact(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_indexActuel],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indexActuel,
        selectedItemColor: Colors.indigo,
        onTap: (index) {
          setState(() {
            _indexActuel = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Mon CV'),
          BottomNavigationBarItem(icon: Icon(Icons.family_restroom), label: 'Famille'),
          BottomNavigationBarItem(icon: Icon(Icons.contact_mail), label: 'Contact'),
        ],
      ),
    );
  }
}

// ============================================================================
// PAGE 2 : PAGE D'ACCUEIL (CV COMPLET)
// ============================================================================
class PageAccueilCV extends StatelessWidget {
  const PageAccueilCV({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon CV')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 55,
                    backgroundImage: AssetImage('profil.jpg'),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ton Nom Complet',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Étudiant en Informatique & Développeur Mobile',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Divider(height: 32),

            _construireTitreSection('Formation'),
            const ListTile(
              leading: Icon(Icons.school, color: Colors.indigo),
              title: Text('Licence en Informatique'),
              subtitle: Text('Université - 2024 à Présent'),
            ),

            _construireTitreSection('Expériences'),
            const ListTile(
              leading: Icon(Icons.work, color: Colors.indigo),
              title: Text('Stage Développeur Mobile'),
              subtitle: Text('Création d\'applications avec Flutter'),
            ),
            const ListTile(
              leading: Icon(Icons.code, color: Colors.indigo),
              title: Text('Projet Académique'),
              subtitle: Text('Développement d\'une application de gestion'),
            ),

            _construireTitreSection('Compétences Techniques'),
            Wrap(
              spacing: 8.0,
              children: const [
                Chip(label: Text('Flutter & Dart')),
                Chip(label: Text('Git & GitHub')),
                Chip(label: Text('HTML / CSS')),
                Chip(label: Text('Algorithmique')),
              ],
            ),
            const SizedBox(height: 16),
            _construireTitreSection('Compétences Linguistiques'),
            const Text('• Français : Courant\n• Anglais : Intermédiaire\n• Swahili : Courant'),
            const SizedBox(height: 16),

            _construireTitreSection('Centres d\'intérêt'),
            const Text('• Programmation, Lecture, Sport, Musique'),
          ],
        ),
      ),
    );
  }

  Widget _construireTitreSection(String titre) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Text(
        titre,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
      ),
    );
  }
}

// ============================================================================
// PAGE 3 : PAGE FAMILLE
// ============================================================================
class PageFamille extends StatelessWidget {
  const PageFamille({super.key});

  final List<Map<String, String>> membres = const [
    {
      'nom': 'Famille',
      'lien': 'Famille',
      'profession': 'Famille',
      'photo': 'PXL 20260301 155423 X 274.PORTRAIT.jpg.jpg',
    },
    {
      'nom': 'Cousinage',
      'lien': 'Cousinage',
      'profession': 'Cousonage',
      'photo': 'PXL 20260213 0824189 X 42.PORTRAIT.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ma Famille')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: membres.length,
        itemBuilder: (context, index) {
          final membre = membres[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12.0),
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(membre['photo']!),
              ),
              title: Text(
                membre['nom']!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text(
                'Lien : ${membre['lien']}\nProfession : ${membre['profession']}',
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}

