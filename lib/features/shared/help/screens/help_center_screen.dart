import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _expandedIndex;

  final List<FAQItem> _faqItems = [
    // Umum
    FAQItem(
      question: 'Bagaimana cara memesan layanan?',
      answer: '1. Pilih divisi layanan yang Anda butuhkan\n'
          '2. Pilih layanan spesifik\n'
          '3. Klik "Pesan Sekarang" atau chat admin\n'
          '4. Isi formulir pemesanan (alamat, jadwal, catatan)\n'
          '5. Lakukan pembayaran\n'
          '6. Tunggu teknisi datang ke lokasi Anda',
      category: 'Umum',
    ),
    FAQItem(
      question: 'Berapa lama estimasi pengerjaan?',
      answer: 'Estimasi pengerjaan bervariasi tergantung jenis layanan:\n'
          '• Cuci AC: 1-2 jam\n'
          '• Ganti LCD HP: 1-2 jam\n'
          '• Servis TV: 1-3 jam\n'
          '• Instalasi WiFi: 1-2 jam\n'
          'Detail estimasi dapat dilihat di halaman masing-masing layanan.',
      category: 'Umum',
    ),
    FAQItem(
      question: 'Apakah ada garansi servis?',
      answer: 'Ya, kami memberikan garansi servis selama 7 hari setelah pengerjaan. '
          'Jika ada masalah terkait servis yang sama dalam masa garansi, '
          'teknisi kami akan kembali tanpa biaya tambahan.',
      category: 'Umum',
    ),
    
    // Pembayaran
    FAQItem(
      question: 'Metode pembayaran apa saja yang tersedia?',
      answer: 'Kami menerima pembayaran melalui:\n'
          '• Transfer Bank (BCA, Mandiri, BNI, BRI)\n'
          '• E-Wallet (GoPay, OVO, Dana, ShopeePay)\n'
          '• Tunai (langsung ke teknisi setelah servis selesai)',
      category: 'Pembayaran',
    ),
    FAQItem(
      question: 'Bagaimana cara konfirmasi pembayaran?',
      answer: '1. Setelah transfer, buka halaman pesanan Anda\n'
          '2. Pilih pesanan yang ingin dikonfirmasi\n'
          '3. Klik "Upload Bukti Pembayaran"\n'
          '4. Upload foto/struk transfer\n'
          '5. Admin akan memverifikasi pembayaran Anda',
      category: 'Pembayaran',
    ),
    FAQItem(
      question: 'Apakah bisa bayar di tempat?',
      answer: 'Ya, Anda bisa membayar tunai langsung ke teknisi setelah servis selesai. '
          'Pilih metode pembayaran "Tunai" saat checkout.',
      category: 'Pembayaran',
    ),
    
    // Teknisi
    FAQItem(
      question: 'Kapan teknisi akan datang?',
      answer: 'Teknisi akan datang sesuai jadwal yang Anda pilih saat pemesanan. '
          'Anda akan menerima notifikasi ketika teknisi sedang dalam perjalanan (OTW).',
      category: 'Teknisi',
    ),
    FAQItem(
      question: 'Apakah teknisi membawa peralatan?',
      answer: 'Ya, semua teknisi kami dilengkapi dengan peralatan lengkap dan '
          'sparepart umum. Untuk sparepart khusus, teknisi akan menginformasikan terlebih dahulu.',
      category: 'Teknisi',
    ),
    FAQItem(
      question: 'Bagaimana jika teknisi terlambat?',
      answer: 'Jika teknisi terlambat, Anda akan mendapat notifikasi. '
          'Anda juga bisa menghubungi admin melalui chat untuk informasi lebih lanjut.',
      category: 'Teknisi',
    ),
    
    // Akun
    FAQItem(
      question: 'Bagaimana cara mengubah profil?',
      answer: '1. Buka halaman Profil\n'
          '2. Klik "Edit Profil"\n'
          '3. Ubah informasi yang diperlukan\n'
          '4. Klik "Simpan"',
      category: 'Akun',
    ),
    FAQItem(
      question: 'Saya lupa password, bagaimana?',
      answer: 'Saat ini aplikasi masih dalam tahap prototype. '
          'Untuk demo, gunakan tombol "Masuk" dan pilih peran yang diinginkan tanpa password.',
      category: 'Akun',
    ),
    
    // Lainnya
    FAQItem(
      question: 'Bagaimana cara membatalkan pesanan?',
      answer: 'Pesanan dapat dibatalkan sebelum teknisi berangkat (status "Menunggu" atau "Dikonfirmasi"). '
          'Hubungi admin melalui chat untuk membatalkan pesanan.',
      category: 'Lainnya',
    ),
    FAQItem(
      question: 'Apakah bisa reschedule?',
      answer: 'Ya, Anda bisa mengubah jadwal servis dengan menghubungi admin melalui chat. '
          'Perubahan jadwal harus dilakukan minimal 2 jam sebelum jadwal yang ditentukan.',
      category: 'Lainnya',
    ),
  ];

  List<String> get _categories {
    return ['Semua', ..._faqItems.map((item) => item.category).toSet().toList()..sort()];
  }

  String _selectedCategory = 'Semua';

  List<FAQItem> get _filteredFAQs {
    var filtered = _faqItems;
    
    if (_selectedCategory != 'Semua') {
      filtered = filtered.where((item) => item.category == _selectedCategory).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) =>
        item.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        item.answer.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        title: 'Pusat Bantuan',
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari pertanyaan...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          
          // Category Chips
          if (_searchQuery.isEmpty)
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedCategory = category);
                    },
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.primary.withOpacity(0.1),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  );
                },
              ),
            ),
          
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1),
          
          // FAQ List
          Expanded(
            child: _filteredFAQs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Tidak ada hasil',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Coba kata kunci lain',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                    itemCount: _filteredFAQs.length,
                    itemBuilder: (context, index) {
                      final faq = _filteredFAQs[index];
                      final originalIndex = _faqItems.indexOf(faq);
                      return _buildFAQCard(faq, originalIndex);
                    },
                  ),
          ),
          
          // Contact Support Button
          Container(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Masih butuh bantuan?',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    height: AppSpacing.buttonHeight,
                    child: ElevatedButton.icon(
                      onPressed: _showContactOptions,
                      icon: const Icon(Icons.headset_mic_outlined),
                      label: const Text('Hubungi Kami'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQCard(FAQItem faq, int index) {
    final isExpanded = _expandedIndex == index;
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          title: Text(
            faq.question,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            faq.category,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
            ),
          ),
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _expandedIndex = expanded ? index : null;
            });
          },
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  faq.answer,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContactOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardBorderRadius),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'Hubungi Kami',
                  style: AppTextStyles.titleMedium,
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: AppColors.success,
                  ),
                ),
                title: const Text('Live Chat'),
                subtitle: Text(
                  'Balasan dalam beberapa menit',
                  style: AppTextStyles.caption,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showMockMessage('Live Chat');
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone_outlined,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(AppConfig.supportPhone),
                subtitle: Text(
                  'Senin-Minggu, 08:00-20:00',
                  style: AppTextStyles.caption,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showMockMessage('Telepon ${AppConfig.supportPhone}');
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.email_outlined,
                    color: AppColors.warning,
                  ),
                ),
                title: Text(AppConfig.supportEmail),
                subtitle: Text(
                  'Balasan dalam 1x24 jam',
                  style: AppTextStyles.caption,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showMockMessage('Email ${AppConfig.supportEmail}');
                },
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }

  void _showMockMessage(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Fitur untuk prototype'),
        backgroundColor: AppColors.info,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;
  final String category;

  FAQItem({
    required this.question,
    required this.answer,
    required this.category,
  });
}