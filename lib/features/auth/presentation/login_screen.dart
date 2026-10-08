import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/result.dart';
import '../../../core/router/repository_scope.dart';
import '../domain/app_user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final authRepository = RepositoryScope.of(context).authRepository;
    final result = await authRepository.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    switch (result) {
      case Ok<AppUser>():
        break; // the router's auth-state redirect takes over from here
      case Err<AppUser>(:final failure):
        _showError(failure.message);
    }
  }

  Future<void> _signInWithGoogle() async {
    final authRepository = RepositoryScope.of(context).authRepository;
    final result = await authRepository.signInWithGoogle();
    if (!mounted) return;
    switch (result) {
      case Ok<void>():
        break;
      case Err<void>(:final failure):
        _showError(failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: colorScheme.secondaryContainer,
                    child: Icon(Icons.wb_cloudy, size: 40, color: colorScheme.onSecondaryContainer),
                  ),
                  const SizedBox(height: 12),
                  Text('MétéoNow', style: Theme.of(context).textTheme.headlineMedium),
                  Text(
                    'Your weather, wherever you are.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Welcome back', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.mail_outline)),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) return 'Email is required';
                                if (!value.contains('@')) return 'Enter a valid email address';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: (value) =>
                                  (value == null || value.isEmpty) ? 'Password is required' : null,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => _showError("Password reset isn't available in this demo."),
                                child: const Text('Forgot password?'),
                              ),
                            ),
                            const SizedBox(height: 8),
                            FilledButton(
                              onPressed: _isSubmitting ? null : _submit,
                              child: _isSubmitting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Log in'),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: Divider(color: colorScheme.outlineVariant)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text('OR', style: Theme.of(context).textTheme.labelSmall),
                                ),
                                Expanded(child: Divider(color: colorScheme.outlineVariant)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: _signInWithGoogle,
                              icon: const Text('G', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4285F4))),
                              label: const Text('Continue with Google'),
                              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Wrap(
                                children: [
                                  const Text("Don't have an account? "),
                                  GestureDetector(
                                    onTap: () => context.pushNamed('register'),
                                    child: Text(
                                      'Create account',
                                      style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
