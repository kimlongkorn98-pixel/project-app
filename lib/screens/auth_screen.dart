import 'package:flutter/material.dart';

import '../providers/app_state.dart';

class AuthScreen extends StatefulWidget {
  final AppState state;

  const AuthScreen({super.key, required this.state});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isRegistering = false;
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _switchMode() {
    FocusScope.of(context).unfocus();
    setState(() {
      _isRegistering = !_isRegistering;
      _errorMessage = null;
      _formKey.currentState?.reset();
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _errorMessage = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    final error = _isRegistering
        ? widget.state.register(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
          )
        : widget.state.login(
            email: _emailController.text,
            password: _passwordController.text,
          );

    if (mounted && error != null) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = error;
      });
    }
  }

  void _useDemoAccount() {
    _emailController.text = 'alex.morgan@example.com';
    _passwordController.text = 'Shop1234';
    setState(() => _errorMessage = null);
    _submit();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF6C5CE7,
                          ).withValues(alpha: 0.28),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shopping_bag_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: Column(
                      key: ValueKey(_isRegistering),
                      children: [
                        Text(
                          _isRegistering
                              ? 'Create your account'
                              : 'Welcome back',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isRegistering
                              ? 'Register to save products and track your orders.'
                              : 'Sign in to continue shopping with Luminary.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark
                            ? Colors.white10
                            : const Color(0xFFF1F2F6),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if (_isRegistering) ...[
                            TextFormField(
                              controller: _nameController,
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.words,
                              autofillHints: const [AutofillHints.name],
                              decoration: const InputDecoration(
                                labelText: 'Full name',
                                prefixIcon: Icon(Icons.person_outline_rounded),
                              ),
                              validator: (value) {
                                if ((value ?? '').trim().length < 2) {
                                  return 'Enter your full name.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                          ],
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            autocorrect: false,
                            decoration: const InputDecoration(
                              labelText: 'Email address',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (value) {
                              final email = (value ?? '').trim();
                              final valid = RegExp(
                                r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                              ).hasMatch(email);
                              return valid
                                  ? null
                                  : 'Enter a valid email address.';
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: _isRegistering
                                ? TextInputAction.next
                                : TextInputAction.done,
                            autofillHints: [
                              _isRegistering
                                  ? AutofillHints.newPassword
                                  : AutofillHints.password,
                            ],
                            onFieldSubmitted: (_) {
                              if (!_isRegistering) _submit();
                            },
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                              ),
                              suffixIcon: IconButton(
                                tooltip: _obscurePassword
                                    ? 'Show password'
                                    : 'Hide password',
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if ((value ?? '').length < 8) {
                                return 'Use at least 8 characters.';
                              }
                              return null;
                            },
                          ),
                          if (_isRegistering) ...[
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmation,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                              decoration: InputDecoration(
                                labelText: 'Confirm password',
                                prefixIcon: const Icon(
                                  Icons.verified_user_outlined,
                                ),
                                suffixIcon: IconButton(
                                  tooltip: _obscureConfirmation
                                      ? 'Show password'
                                      : 'Hide password',
                                  onPressed: () => setState(
                                    () => _obscureConfirmation =
                                        !_obscureConfirmation,
                                  ),
                                  icon: Icon(
                                    _obscureConfirmation
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                              ),
                              validator: (value) =>
                                  value == _passwordController.text
                                  ? null
                                  : 'Passwords do not match.',
                            ),
                          ],
                          AnimatedSize(
                            duration: const Duration(milliseconds: 180),
                            child: _errorMessage == null
                                ? const SizedBox.shrink()
                                : Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(top: 14),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFFF7675,
                                      ).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.error_outline_rounded,
                                          color: Color(0xFFFF7675),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _errorMessage!,
                                            style: const TextStyle(
                                              color: Color(0xFFFF7675),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submit,
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      _isRegistering
                                          ? 'Create account'
                                          : 'Sign in',
                                    ),
                            ),
                          ),
                          if (!_isRegistering) ...[
                            const SizedBox(height: 10),
                            TextButton.icon(
                              onPressed: _isSubmitting ? null : _useDemoAccount,
                              icon: const Icon(Icons.bolt_rounded, size: 18),
                              label: const Text('Try demo account'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 2,
                    children: [
                      Text(
                        _isRegistering
                            ? 'Already have an account?'
                            : 'New to Luminary?',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: _isSubmitting ? null : _switchMode,
                        child: Text(_isRegistering ? 'Sign in' : 'Register'),
                      ),
                    ],
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
