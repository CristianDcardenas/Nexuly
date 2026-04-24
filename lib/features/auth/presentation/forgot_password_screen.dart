import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/failures.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../shared/widgets/nexuly_gradient_button.dart';
import '../../../shared/widgets/nexuly_text_field.dart';
import '../providers/auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref
        .read(authControllerProvider.notifier)
        .sendPasswordResetEmail(_emailCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

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
        return;
      }
      if (previous?.isLoading == true && next is AsyncData<void>) {
        setState(() => _emailSent = true);
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: _emailSent
              ? _SuccessView(email: _emailCtrl.text.trim())
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpacing.md),
                      const Text(
                        'Recuperar contraseña',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray900,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Text(
                        'Ingresa tu correo y te enviaremos un enlace '
                        'para restablecer tu contraseña.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.gray600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      NexulyTextField(
                        controller: _emailCtrl,
                        label: 'Correo electrónico',
                        hint: 'correo@ejemplo.com',
                        prefixIcon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        autofillHints: const [AutofillHints.email],
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Ingresa tu correo';
                          }
                          final re =
                              RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                          if (!re.hasMatch(v.trim())) {
                            return 'Correo no válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      NexulyGradientButton(
                        label: 'Enviar enlace',
                        onPressed: isLoading ? null : _submit,
                        isLoading: isLoading,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        const Icon(
          Icons.mark_email_read_outlined,
          size: 96,
          color: AppColors.violet600,
        ),
        const SizedBox(height: AppSpacing.xxl),
        const Text(
          'Revisa tu correo',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.gray900,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Enviamos un enlace de recuperación a $email. '
          'Revisa tu bandeja de entrada (y el spam).',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.gray600,
          ),
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        NexulyGradientButton(
          label: 'Volver al inicio',
          onPressed: () => context.go('/login'),
        ),
      ],
    );
  }
}
