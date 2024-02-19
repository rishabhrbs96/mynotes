import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Enter your email here',
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'Enter your password here',
            ),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;

              try {
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                final user = FirebaseAuth.instance.currentUser;
                await user?.sendEmailVerification();
                if (context.mounted) {
                  Navigator.of(context).pushNamed(
                    verifyEmailRoute,
                  );
                }
              } on FirebaseAuthException catch (e) {
                if (e.code == 'invalid-email') {
                  if (context.mounted) {
                    await showErroDialog(
                      context,
                      'Invalid email',
                    );
                  }
                } else if (e.code == 'email-already-in-use') {
                  if (context.mounted) {
                    await showErroDialog(
                      context,
                      'Email already in use',
                    );
                  }
                } else if (e.code == 'weak-password') {
                  if (context.mounted) {
                    await showErroDialog(
                      context,
                      'Weak password',
                    );
                  }
                } else {
                  if (context.mounted) {
                    await showErroDialog(
                      context,
                      'Register failed. Please try again; Error: ${e.code}',
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  await showErroDialog(
                    context,
                    'Register failed. Please try again; Error: $e',
                  );
                }
              }
            },
            child: const Text('Register'),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute,
                  (route) => false,
                );
              },
              child: const Text('Alredy registered? Login here!'))
        ],
      ),
    );
  }
}
