import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../data/models/employee_documentation_model.dart';
import '../../../../core/routing/route_names.dart';
import '../../scaffold/employee_scaffold.dart';

class AddDocumentationScreen extends StatefulWidget {
  final int orderId;

  const AddDocumentationScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<AddDocumentationScreen> createState() => _AddDocumentationScreenState();
}

class _AddDocumentationScreenState extends State<AddDocumentationScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DocumentationStage _selectedStage = DocumentationStage.before;
  final List<String> _selectedMedia = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _canSave => _titleController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return EmployeeScaffold(
      appBar: AppAppBar(
        title: 'Tambah Dokumentasi',
        actions: [
          TextButton(
            onPressed: _canSave && !_isSaving ? _saveDocumentation : null,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Simpan',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: _canSave ? AppColors.primary : AppColors.textTertiary,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            
            // Stage Selection
            Text('Tahap Pengerjaan', style: AppTextStyles.titleSmall),
            const SizedBox(height: AppSpacing.md),
            _buildStageSelector(),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Title
            Text('Judul', style: AppTextStyles.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Contoh: Kondisi AC sebelum dicuci',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Description
            Text('Deskripsi (Opsional)', style: AppTextStyles.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Jelaskan kondisi atau progress pengerjaan...',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Media Upload
            Text('Foto / Video', style: AppTextStyles.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            _buildMediaUpload(),
            
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildStageSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildStageOption(
            label: 'Sebelum',
            stage: DocumentationStage.before,
            icon: Icons.photo_camera_outlined,
            color: AppColors.info,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildStageOption(
            label: 'Saat Pengerjaan',
            stage: DocumentationStage.during,
            icon: Icons.engineering_outlined,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildStageOption(
            label: 'Setelah',
            stage: DocumentationStage.after,
            icon: Icons.check_circle_outline,
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStageOption({
    required String label,
    required DocumentationStage stage,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedStage == stage;
    
    return InkWell(
      onTap: () => setState(() => _selectedStage = stage),
      borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.textTertiary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaUpload() {
    return Column(
      children: [
        // Selected media preview
        if (_selectedMedia.isNotEmpty)
          Container(
            height: 100,
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedMedia.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.image_outlined,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMedia.removeAt(index);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        
        // Upload buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Kamera'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickFromGallery,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Galeri'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _pickImage() {
    setState(() {
      _selectedMedia.add('camera_${DateTime.now().millisecondsSinceEpoch}');
    });
    _showMockMessage('Kamera (Prototype)');
  }

  void _pickFromGallery() {
    setState(() {
      _selectedMedia.add('gallery_${DateTime.now().millisecondsSinceEpoch}');
    });
    _showMockMessage('Galeri (Prototype)');
  }

  void _showMockMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$message - Fitur upload untuk prototype'),
        backgroundColor: AppColors.info,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveDocumentation() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() => _isSaving = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dokumentasi berhasil disimpan!'),
          backgroundColor: AppColors.success,
        ),
      );
      
      context.go(RouteNames.employeeOrderDocumentationsPath(widget.orderId));
    }
  }
}