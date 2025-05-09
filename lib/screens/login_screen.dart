import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text("Connexion MyZik")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_errorMessage != null)
                  Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: "Email"),
                  validator: (value) => value!.isEmpty ? "Entrez votre email" : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: "Mot de passe"),
                  obscureText: true,
                  validator: (value) => value!.length < 6 ? "Mot de passe trop court" : null,
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isLoading = true;
                        _errorMessage = null;
                      });

                      final user = await auth.signInWithEmailAndPassword(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                      );

                      setState(() => _isLoading = false);

                      if (user != null) {
                        Navigator.pushReplacementNamed(context, '/home');
                      } else {
                        setState(() => _errorMessage = "Identifiants incorrects.");
                      }
                    }
                  },
                  child: Text("Se connecter"),
                ),

                // 👇 Nouveau bouton "Créer un compte"
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text("Créer un compte"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
