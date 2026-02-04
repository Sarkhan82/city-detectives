import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:city_detectives/core/router/app_router.dart';
import 'package:city_detectives/core/services/auth_provider.dart';

/// Écran d'inscription (Story 1.2) – email, mot de passe, confirmation.
/// Erreurs affichées = source de vérité backend.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  /// État async du submit (architecture : AsyncValue, pas de bool isLoading).
  AsyncValue<void> _submitState = const AsyncValue.data(null);

  void _clearErrorIfUserEditsPassword() {
    if (_submitState.hasError && mounted) {
      setState(() => _submitState = const AsyncValue.data(null));
    }
  }

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_clearErrorIfUserEditsPassword);
    _confirmController.addListener(_clearErrorIfUserEditsPassword);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_clearErrorIfUserEditsPassword);
    _confirmController.removeListener(_clearErrorIfUserEditsPassword);
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;
    if (password != confirm) {
      setState(() {
        _submitState = AsyncValue.error(
          Exception('Les mots de passe ne correspondent pas.'),
          StackTrace.current,
        );
      });
      return;
    }
    setState(() => _submitState = const AsyncValue.loading());
    try {
      final auth = ref.read(authServiceProvider);
      await auth.register(email: email, password: password);
      if (!mounted) return;
      ref.invalidate(currentUserProvider);
      context.go(AppRouter.onboarding);
    } catch (e, st) {
      if (!mounted) return;
      setState(() => _submitState = AsyncValue.error(e, st));
    }
  }

  String? get _errorMessage => _submitState.whenOrNull(
    error: (e, _) => e.toString().replaceFirst('Exception: ', ''),
  );

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Écran d\'inscription – email, mot de passe, confirmation',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Créer un compte'),
          leading: Semantics(
            label: 'Retour à l\'écran d\'accueil',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _submitState.isLoading
                  ? null
                  : () => context.go(AppRouter.welcome),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Semantics(
                    label: 'Adresse email',
                    child: TextFormField(
                      key: const Key('register_email'),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        hintText: 'vous@exemple.com',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    label: 'Mot de passe (minimum 8 caractères)',
                    child: TextFormField(
                      key: const Key('register_password'),
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Mot de passe',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    label: 'Confirmer le mot de passe',
                    child: TextFormField(
                      key: const Key('register_confirm'),
                      controller: _confirmController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirmer le mot de passe',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Semantics(
                      label: 'Message d\'erreur',
                      liveRegion: true,
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Semantics(
                    label: 'Valider l\'inscription',
                    button: true,
                    child: FilledButton(
                      onPressed: _submitState.isLoading ? null : _submit,
                      child: _submitState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Créer mon compte'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
