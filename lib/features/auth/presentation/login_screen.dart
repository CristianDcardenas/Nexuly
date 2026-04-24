import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/role.dart';
import '../../../core/errors/failures.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../shared/widgets/google_logo_icon.dart';
import '../../../shared/widgets/nexuly_gradient_button.dart';
import '../../../shared/widgets/nexuly_logo.dart';
import '../../../shared/widgets/nexuly_text_field.dart';
import '../../../shared/widgets/role_selector_card.dart';
import '../providers/auth_providers.dart';

/// Pantalla de login unificada (login + signup + selector de rol).
///
/// Replica el mockup React:
/// - Header superior con logo sobre gradiente morado
/// - Hoja blanca redondeada arriba ocupando el resto de pantalla
/// - Toggle entre "Iniciar sesión" y "Crear cuenta"
/// - Selector de rol (Paciente / Profesional)
/// - Formulario adaptativo
/// - Botones sociales
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _isSignUp = false;
  UserRole _accountType = UserRole.patient;
  bool _obscurePassword = true;
  bool _acceptedTerms = false;
  bool _rememberMe = true;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isSignUp && !_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes aceptar los términos y condiciones')),
      );
      return;
    }

    final controller = ref.read(authControllerProvider.notifier);

    if (_isSignUp) {
      await controller.signUpWithEmail(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
        fullName: _fullNameCtrl.text,
        role: _accountType,
      );
    } else {
      await controller.signInWithEmail(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_isSignUp && !_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes aceptar los términos y condiciones')),
      );
      return;
    }
    await ref.read(authControllerProvider.notifier).signInWithGoogle(
          role: _accountType,
        );
  }

  @override
  Widget build(BuildContext context) {
    // Escucha errores y los muestra en un SnackBar.
    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        final error = next.error;
        final message = error is NexulyFailure
            ? error.message
            : 'Ocurrió un error inesperado';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    });

    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.brandGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // --- Header con logo ---
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: NexulyLogo(size: 40, onDark: true),
                ),
              ),

              // --- Título arriba del gradiente ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isSignUp ? 'Crear cuenta' : 'Bienvenido de nuevo',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _isSignUp
                          ? 'Regístrate para conectar con profesionales de salud'
                          : 'Inicia sesión para continuar',
                      style: TextStyle(
                        color: AppColors.violet100,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // --- Hoja blanca (formulario) ---
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppRadii.xxl),
                      topRight: Radius.circular(AppRadii.xxl),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // --- Selector de rol ---
                          Text(
                            'Tipo de cuenta',
                            style: TextStyle(
                              color: AppColors.gray700,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              Expanded(
                                child: RoleSelectorCard(
                                  icon: Icons.people_outline,
                                  label: 'Paciente',
                                  selected: _accountType == UserRole.patient,
                                  onTap: () => setState(
                                    () => _accountType = UserRole.patient,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: RoleSelectorCard(
                                  icon: Icons.shield_outlined,
                                  label: 'Profesional',
                                  selected: _accountType == UserRole.professional,
                                  onTap: () => setState(
                                    () => _accountType = UserRole.professional,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.xxl),

                          // --- Campo nombre (solo signup) ---
                          if (_isSignUp) ...[
                            NexulyTextField(
                              controller: _fullNameCtrl,
                              label: 'Nombre completo',
                              hint: 'María García',
                              autofillHints: const [AutofillHints.name],
                              validator: (v) {
                                if (!_isSignUp) return null;
                                if (v == null || v.trim().isEmpty) {
                                  return 'Ingresa tu nombre';
                                }
                                if (v.trim().length < 3) {
                                  return 'Nombre demasiado corto';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),
                          ],

                          // --- Email ---
                          NexulyTextField(
                            controller: _emailCtrl,
                            label: 'Correo electrónico',
                            hint: 'correo@ejemplo.com',
                            prefixIcon: Icons.mail_outline,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Ingresa tu correo';
                              }
                              final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                              if (!re.hasMatch(v.trim())) {
                                return 'Correo no válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // --- Password ---
                          NexulyTextField(
                            controller: _passwordCtrl,
                            label: 'Contraseña',
                            hint: '••••••••',
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            autofillHints: _isSignUp
                                ? const [AutofillHints.newPassword]
                                : const [AutofillHints.password],
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.gray400,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Ingresa tu contraseña';
                              }
                              if (_isSignUp && v.length < 6) {
                                return 'Mínimo 6 caracteres';
                              }
                              return null;
                            },
                          ),

                          // --- Opciones por debajo ---
                          const SizedBox(height: AppSpacing.md),
                          if (!_isSignUp)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: Checkbox(
                                          value: _rememberMe,
                                          onChanged: (v) => setState(
                                            () => _rememberMe = v ?? false,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Flexible(
                                        child: Text(
                                          'Recordarme',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: AppColors.gray600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Flexible(
                                  child: TextButton(
                                    onPressed: () =>
                                        context.go('/forgot-password'),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      '¿Olvidaste tu contraseña?',
                                      style: TextStyle(fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: Checkbox(
                                    value: _acceptedTerms,
                                    onChanged: (v) => setState(
                                      () => _acceptedTerms = v ?? false,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: Text.rich(
                                      TextSpan(
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.gray600,
                                        ),
                                        children: [
                                          const TextSpan(text: 'Acepto los '),
                                          TextSpan(
                                            text: 'términos y condiciones',
                                            style: TextStyle(
                                              color: AppColors.violet600,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                          const TextSpan(text: ' y la '),
                                          TextSpan(
                                            text: 'política de privacidad',
                                            style: TextStyle(
                                              color: AppColors.violet600,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          const SizedBox(height: AppSpacing.xl),

                          // --- Botón principal ---
                          NexulyGradientButton(
                            label: _isSignUp ? 'Crear cuenta' : 'Iniciar sesión',
                            onPressed: isLoading ? null : _submit,
                            isLoading: isLoading,
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          // --- Divider "o continúa con" ---
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                ),
                                child: Text(
                                  'o continúa con',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.gray500,
                                  ),
                                ),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // --- Botones sociales ---
                          _SocialButton(
                            icon: const GoogleLogoIcon(size: 18),
                            label: 'Google',
                            onPressed: isLoading ? null : _signInWithGoogle,
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          // --- Toggle login/signup ---
                          Center(
                            child: Text.rich(
                              TextSpan(
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.gray600,
                                ),
                                children: [
                                  TextSpan(
                                    text: _isSignUp
                                        ? '¿Ya tienes cuenta? '
                                        : '¿No tienes una cuenta? ',
                                  ),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.baseline,
                                    baseline: TextBaseline.alphabetic,
                                    child: GestureDetector(
                                      onTap: () => setState(() {
                                        _isSignUp = !_isSignUp;
                                        _formKey.currentState?.reset();
                                      }),
                                      child: Text(
                                        _isSignUp
                                            ? 'Iniciar sesión'
                                            : 'Regístrate',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.violet600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Espacio inferior para respetar el safe area del teclado.
                          SizedBox(
                            height: MediaQuery.of(context).viewInsets.bottom + 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final Widget icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        backgroundColor: Colors.white,
        side: const BorderSide(color: AppColors.gray200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.gray700,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}