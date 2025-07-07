import 'package:alqayimm_app_flutter/screens/bookmarks/all_notes_page.dart';
import 'package:flutter/material.dart';
import '../../db/user/models/user_profile_model.dart';
import '../../db/user/repos/user_profile_repository.dart';
import '../../db/user/user_backup_service.dart';
import '../../db/user/user_db_helper.dart';
import 'favorites_screen.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({super.key});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  UserProfileModel? _userProfile;
  Map<String, int> _userStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    final profile = await UserProfileRepository.getUserProfile();
    final stats = await _getUserStats();

    setState(() {
      _userProfile = profile;
      _userStats = stats;
      _isLoading = false;
    });
  }

  Future<Map<String, int>> _getUserStats() async {
    try {
      return await UserProfileRepository.getUserStats();
    } catch (e) {
      return {'favorites': 0, 'notes': 0, 'completions': 0};
    }
  }

  Future<void> _signInWithGoogle() async {
    // TODO: تنفيذ تسجيل الدخول بـ Google
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تسجيل الدخول'),
            content: const Text(
              'سيتم تنفيذ تسجيل الدخول بـ Google Drive قريباً',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('موافق'),
              ),
            ],
          ),
    );
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تسجيل الخروج'),
            content: const Text('هل تريد تسجيل الخروج؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('تسجيل الخروج'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final success = await UserProfileRepository.signOutUser();
      if (success) {
        _loadUserData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تسجيل الخروج بنجاح')),
          );
        }
      }
    }
  }

  Future<void> _createBackup() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final backupFile = await UserBackupService.saveBackupToFile();

    if (mounted) {
      Navigator.of(context).pop(); // إغلاق مؤشر التحميل

      if (backupFile != null) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('تم إنشاء النسخة الاحتياطية'),
                content: Text(
                  'تم حفظ النسخة الاحتياطية في:\n${backupFile.path}',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('موافق'),
                  ),
                ],
              ),
        );
        _loadUserData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في إنشاء النسخة الاحتياطية')),
        );
      }
    }
  }

  Future<void> _resetUserData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('إعادة تعيين البيانات'),
            content: const Text(
              'هذا سيحذف جميع بياناتك الشخصية (المفضلة، الملاحظات، التقدم).\nهل أنت متأكد؟',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('حذف البيانات'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await UserDbHelper.deleteDatabase();

      if (mounted) {
        Navigator.of(context).pop(); // إغلاق مؤشر التحميل
        _loadUserData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف جميع البيانات الشخصية')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات المستخدم'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadUserData),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileSection(),
                    const SizedBox(height: 24),
                    _buildStatsSection(),
                    const SizedBox(height: 24),
                    _buildDataSection(),
                    const SizedBox(height: 24),
                    _buildBackupSection(),
                    const SizedBox(height: 24),
                    _buildDangerZone(),
                  ],
                ),
              ),
    );
  }

  Widget _buildProfileSection() {
    final isSignedIn = _userProfile?.isSignedIn ?? false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الملف الشخصي',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (isSignedIn) ...[
              ListTile(
                leading: const Icon(Icons.account_circle, color: Colors.green),
                title: Text(_userProfile?.fullName ?? 'مستخدم'),
                subtitle: Text(_userProfile?.email ?? ''),
                trailing: TextButton(
                  onPressed: _signOut,
                  child: const Text('تسجيل الخروج'),
                ),
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.account_circle_outlined),
                title: const Text('غير مسجل الدخول'),
                subtitle: const Text('سجل الدخول للنسخ الاحتياطي والمزامنة'),
                trailing: ElevatedButton(
                  onPressed: _signInWithGoogle,
                  child: const Text('تسجيل الدخول'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إحصائياتي',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'المفضلة',
                    '${_userStats['favorites'] ?? 0}',
                    Icons.favorite,
                    Colors.red,
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FavoritesScreen(),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'الملاحظات',
                    '${_userStats['notes'] ?? 0}',
                    Icons.note,
                    Colors.orange,
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AllNotesPage(),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'المكتمل',
                    '${_userStats['completions'] ?? 0}',
                    Icons.check_circle,
                    Colors.green,
                    null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'البيانات الشخصية',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('المفضلة'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const FavoritesScreen(),
                    ),
                  ),
            ),
            ListTile(
              leading: const Icon(Icons.note),
              title: const Text('ملاحظاتي'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AllNotesPage(),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupSection() {
    final lastBackup = _userProfile?.lastBackupDate;
    final lastRestore = _userProfile?.lastRestoreDate;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'النسخ الاحتياطي',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (lastBackup != null)
              Text(
                'آخر نسخة احتياطية: ${_formatDate(lastBackup)}',
                style: const TextStyle(color: Colors.grey),
              ),
            if (lastRestore != null)
              Text(
                'آخر استعادة: ${_formatDate(lastRestore)}',
                style: const TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _createBackup,
                    icon: const Icon(Icons.backup),
                    label: const Text('إنشاء نسخة احتياطية'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: تنفيذ الاستعادة من ملف
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('قريباً: استعادة من ملف')),
                      );
                    },
                    icon: const Icon(Icons.restore),
                    label: const Text('استعادة'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZone() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'المنطقة الخطيرة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('حذف جميع البيانات الشخصية'),
              subtitle: const Text('هذا سيحذف المفضلة والملاحظات والتقدم'),
              onTap: _resetUserData,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
