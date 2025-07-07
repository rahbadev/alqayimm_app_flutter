import 'package:alqayimm_app_flutter/db/main/models/base_content_model.dart';
import 'package:alqayimm_app_flutter/db/user/db_constants.dart';
import 'package:alqayimm_app_flutter/db/user/repos/user_item_status_repository.dart';
import 'package:flutter/material.dart';
import '../../db/main/repo.dart';
import '../../db/main/db_helper.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<BookModel> _favoriteBooks = [];
  List<LessonModel> _favoriteLessons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);

    // جلب معرفات المفضلة
    final favoriteBooksIds = await UserItemStatusRepository.getFavoriteItems(
      itemType: ItemType.book,
    ).then((value) => value.map((e) => e.itemId).toList());
    final favoriteLessonIds = await UserItemStatusRepository.getFavoriteItems(
      itemType: ItemType.lesson,
    ).then((value) => value.map((e) => e.itemId).toList());

    // جلب بيانات المواد والدروس المفضلة
    final books = <BookModel>[];
    final lessons = <LessonModel>[];

    // إنشاء instance من Repo
    final db = await DbHelper.database;
    final repo = Repo(db);

    for (final bookId in favoriteBooksIds) {
      final book = await repo.getBookById(bookId);
      if (book != null) {
        books.add(book);
      }
    }

    for (final lessonId in favoriteLessonIds) {
      final lesson = await repo.getLessonById(lessonId);
      if (lesson != null) {
        lessons.add(lesson);
      }
    }

    setState(() {
      _favoriteBooks = books;
      _favoriteLessons = lessons;
      _isLoading = false;
    });
  }

  Future<void> _removeMaterialFromFavorites(BookModel book) async {
    final success = await UserItemStatusRepository.removeFromFavorite(
      book.id,
      ItemType.book,
    );
    if (success) {
      setState(() {
        _favoriteBooks.remove(book);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم إزالة "${book.name}" من المفضلة')),
        );
      }
    }
  }

  Future<void> _removeLessonFromFavorites(LessonModel lesson) async {
    final success = await UserItemStatusRepository.removeFromFavorite(
      lesson.id,
      ItemType.lesson,
    );
    if (success) {
      setState(() {
        _favoriteLessons.remove(lesson);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم إزالة "${lesson.lessonName}" من المفضلة')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavorites,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'الكتب (${_favoriteBooks.length})',
              icon: const Icon(Icons.library_books),
            ),
            Tab(
              text: 'الدروس (${_favoriteLessons.length})',
              icon: const Icon(Icons.play_circle_outline),
            ),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [_buildBooksTab(), _buildLessonsTab()],
              ),
    );
  }

  Widget _buildBooksTab() {
    if (_favoriteBooks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا توجد مواد مفضلة',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _favoriteBooks.length,
      itemBuilder: (context, index) {
        final material = _favoriteBooks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.library_books, color: Colors.teal),
            title: Text(
              material.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (material.authorName != null)
                  Text('المؤلف: ${material.authorName}'),
                if (material.categoryName != null)
                  Text('التصنيف: ${material.categoryName}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () => _removeMaterialFromFavorites(material),
            ),
            onTap: () {
              // TODO: فتح شاشة المادة
            },
          ),
        );
      },
    );
  }

  Widget _buildLessonsTab() {
    if (_favoriteLessons.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا توجد دروس مفضلة',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _favoriteLessons.length,
      itemBuilder: (context, index) {
        final lesson = _favoriteLessons[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.play_circle_outline, color: Colors.teal),
            title: Text(
              lesson.lessonName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (lesson.materialName != null)
                  Text('المادة: ${lesson.materialName}'),
                if (lesson.authorName != null)
                  Text('المؤلف: ${lesson.authorName}'),
                if (lesson.lessonNumber != null)
                  Text('رقم الدرس: ${lesson.lessonNumber}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () => _removeLessonFromFavorites(lesson),
            ),
            onTap: () {
              // TODO: فتح مشغل الصوت للدرس
            },
          ),
        );
      },
    );
  }
}
