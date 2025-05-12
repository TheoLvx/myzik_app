import 'package:flutter/material.dart';
import '../services/auth_services.dart';
import '../widgets/custom_drawer.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController(); // Ajout du contrôleur pour le nom
  String _errorMessage = '';
  bool _isLoading = false;

  Future<void> _register() async {
    String email = _emailController.text;
    String password = _passwordController.text;
    String name = _nameController.text;

    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      setState(() {
        _errorMessage = 'Tous les champs doivent être remplis.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      var result = await AuthService().register(email, password, name);
      if (result != null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Créer un compte')),
      drawer: CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nom',
                errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
              ),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
              ),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _register,
              child: Text('Créer un compte'),
            ),
          ],
        ),
      ),
    );
  }
}
