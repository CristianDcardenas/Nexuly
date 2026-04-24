import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/profile_photo_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

/// Muestra un bottom sheet que deja al usuario elegir entre cámara, galería,
/// o eliminar la foto actual. Retorna `true` si hubo cambio.
Future<bool> showPhotoPickerSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String uid,
  bool allowRemove = true,
}) async {
  final choice = await showModalBottomSheet<_PhotoAction>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
    ),
    builder: (_) => _PhotoPickerSheet(allowRemove: allowRemove),
  );

  if (choice == null) return false;

  final service = ref.read(profilePhotoServiceProvider);
  if (choice == _PhotoAction.remove) {
    await service.remove(uid);
    return true;
  }

  final source = choice == _PhotoAction.camera
      ? ImageSource.camera
      : ImageSource.gallery;
  final result = await service.pickAndSave(uid: uid, source: source);
  return result != null;
}

enum _PhotoAction { camera, gallery, remove }

class _PhotoPickerSheet extends StatelessWidget {
  const _PhotoPickerSheet({required this.allowRemove});
  final bool allowRemove;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const Text(
              'Foto de perfil',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Se guarda localmente en tu dispositivo.',
              style: TextStyle(fontSize: 12, color: AppColors.gray500),
            ),
            const SizedBox(height: AppSpacing.lg),

            _OptionTile(
              icon: Icons.photo_camera_outlined,
              label: 'Tomar foto',
              iconBg: AppColors.violet100,
              iconColor: AppColors.violet600,
              onTap: () => Navigator.pop(context, _PhotoAction.camera),
            ),
            const SizedBox(height: AppSpacing.sm),
            _OptionTile(
              icon: Icons.photo_library_outlined,
              label: 'Elegir de galería',
              iconBg: AppColors.infoBg,
              iconColor: AppColors.info,
              onTap: () => Navigator.pop(context, _PhotoAction.gallery),
            ),
            if (allowRemove) ...[
              const SizedBox(height: AppSpacing.sm),
              _OptionTile(
                icon: Icons.delete_outline,
                label: 'Eliminar foto actual',
                iconBg: AppColors.dangerBg,
                iconColor: AppColors.danger,
                labelColor: AppColors.danger,
                onTap: () => Navigator.pop(context, _PhotoAction.remove),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.label,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
    this.labelColor,
  });

  final IconData icon;
  final String label;
  final Color iconBg;
  final Color iconColor;
  final Color? labelColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.gray50,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: labelColor ?? AppColors.gray900,
                  ),
                ),
              ),
              Icon(Icons.chevron_right,
                  color: AppColors.gray400, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
