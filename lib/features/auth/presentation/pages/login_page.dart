import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/mamba_theme.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'user@mamba.com');
  final _passwordController = TextEditingController(text: 'mamba123');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      context.read<AuthCubit>().login(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: MambaTheme.alertRed,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Icon
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: MambaTheme.neonGold.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: MambaTheme.neonGold, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: MambaTheme.neonGold.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.bolt, size: 56, color: MambaTheme.neonGold),
                      ),

                      const SizedBox(height: 24),

                      // Title
                      const Text(
                        'MAMBA FAST TRACKER',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: MambaTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Sistema de Alta Performance em Jejum & Calorias',
                        style: TextStyle(
                          fontSize: 13,
                          color: MambaTheme.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: MambaTheme.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                          hintText: 'seu@email.com',
                          filled: true,
                          fillColor: MambaTheme.cardSurface,
                          prefixIcon: const Icon(Icons.email_outlined, color: MambaTheme.neonGold),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Informe seu e-mail';
                          if (!val.contains('@')) return 'E-mail inválido';
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: MambaTheme.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          hintText: '••••••••',
                          filled: true,
                          fillColor: MambaTheme.cardSurface,
                          prefixIcon: const Icon(Icons.lock_outline, color: MambaTheme.neonGreen),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: MambaTheme.textMuted,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Informe sua senha';
                          if (val.length < 4) return 'Senha deve ter no mínimo 4 caracteres';
                          return null;
                        },
                      ),

                      const SizedBox(height: 28),

                      // Submit Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MambaTheme.neonGold,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'ENTRAR NO MAMBA TRACKER',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      TextButton(
                        onPressed: () {
                          _emailController.text = 'mamba.user@tracker.com';
                          _passwordController.text = 'mamba123';
                        },
                        child: const Text(
                          'Preencher Credenciais Demo',
                          style: TextStyle(color: MambaTheme.textMuted, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
