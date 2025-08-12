import 'package:alqayimm_app_flutter/screens/items/lessons_books_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:alqayimm_app_flutter/db/main/models/base_content_model.dart';
import 'package:alqayimm_app_flutter/db/user/models/user_item_state_model.dart';
import 'package:alqayimm_app_flutter/db/enums.dart';
import 'package:alqayimm_app_flutter/db/user/db_constants.dart';
import 'package:alqayimm_app_flutter/db/main/repo.dart';
import 'package:alqayimm_app_flutter/db/main/db_helper.dart';
import 'package:alqayimm_app_flutter/db/user/repos/user_item_status_repository.dart';
import 'package:alqayimm_app_flutter/main.dart';

class LessonsBooksProvider with ChangeNotifier {
  List<BaseContentModel> _items = [];
  bool _isLoading = false;
  String? _error;
  final Set<int> _processingItems = {};

  // Getters
  List<BaseContentModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool isProcessing(int itemId) => _processingItems.contains(itemId);

  // تحميل البيانات
  Future<void> loadItems({
    required ScreenType screenType,
    int? authorId,
    int? materialId,
    int? levelId,
    int? categoryId,
    CategorySel? categorySel,
    BookTypeSel? bookTypeSel,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final db = await DbHelper.database;
      final repo = Repo(db);

      // جلب العناصر من قاعدة البيانات
      final items = await _fetchItemsFromRepo(
        repo,
        screenType,
        authorId: authorId,
        materialId: materialId,
        levelId: levelId,
        categoryId: categoryId,
        categorySel: categorySel,
        bookTypeSel: bookTypeSel,
      );

      // جلب حالات المستخدم
      final userStatuses = await _fetchUserStatuses(screenType);

      // دمج الحالات مع العناصر
      _items = _mergeItemsWithStatuses(items, userStatuses);

      _setLoading(false);
    } catch (e) {
      logger.e('Error loading items: $e');
      _error = e.toString();
      _setLoading(false);
    }
  }

  // تحديث حالة المفضلة
  Future<bool> toggleFavorite(BaseContentModel item) async {
    if (_processingItems.contains(item.id)) return false;

    _processingItems.add(item.id);
    notifyListeners();

    try {
      final success = await UserItemStatusRepository.toggleFavorite(
        item.id,
        _getItemType(item),
      );

      if (success) {
        final index = _items.indexWhere((i) => i.id == item.id);
        if (index >= 0) {
          _items[index] = _items[index].copyWith(
            isFavorite: !_items[index].isFavorite,
          );
        }
      }

      _processingItems.remove(item.id);
      notifyListeners();
      return success;
    } catch (e) {
      logger.e('Error toggling favorite: $e');
      _processingItems.remove(item.id);
      notifyListeners();
      return false;
    }
  }

  // تحديث حالة الإكمال
  Future<bool> toggleComplete(BaseContentModel item) async {
    if (_processingItems.contains(item.id)) return false;

    _processingItems.add(item.id);
    notifyListeners();

    try {
      final success = await UserItemStatusRepository.toggleCompleted(
        item.id,
        _getItemType(item),
      );

      if (success) {
        final index = _items.indexWhere((i) => i.id == item.id);
        if (index >= 0) {
          _items[index] = _items[index].copyWith(
            isCompleted: !_items[index].isCompleted,
          );
        }
      }

      _processingItems.remove(item.id);
      notifyListeners();
      return success;
    } catch (e) {
      logger.e('Error toggling complete: $e');
      _processingItems.remove(item.id);
      notifyListeners();
      return false;
    }
  }

  // ==================== Private Methods ====================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<List<BaseContentModel>> _fetchItemsFromRepo(
    Repo repo,
    ScreenType screenType, {
    int? authorId,
    int? materialId,
    int? levelId,
    int? categoryId,
    CategorySel? categorySel,
    BookTypeSel? bookTypeSel,
  }) async {
    if (screenType == ScreenType.books) {
      return await repo.fetchBooks(
        authorId: authorId,
        categorySel: categorySel ?? CategorySel.all(),
        bookTypeSel: bookTypeSel ?? BookTypeSel.all(),
      );
    } else {
      return await repo.fetchLessons(
        materialId: materialId,
        authorId: authorId,
        levelId: levelId,
        categoryId: categoryId,
      );
    }
  }

  Future<List<UserItemStatusModel>> _fetchUserStatuses(
    ScreenType screenType,
  ) async {
    return await UserItemStatusRepository.getItems(
      itemType:
          screenType == ScreenType.lessons ? ItemType.lesson : ItemType.book,
    );
  }

  List<BaseContentModel> _mergeItemsWithStatuses(
    List<BaseContentModel> items,
    List<UserItemStatusModel> userStatuses,
  ) {
    try {
      final statusMap = {for (var s in userStatuses) s.itemId: s};
      return items.map((item) {
        final status = statusMap[item.id];
        return item.copyWith(
          isFavorite: status?.isFavorite ?? false,
          isCompleted: status?.isCompleted ?? false,
        );
      }).toList();
    } catch (e) {
      logger.e('Error merging items with statuses: $e');
      return items;
    }
  }

  ItemType _getItemType(BaseContentModel item) {
    return item is LessonModel ? ItemType.lesson : ItemType.book;
  }

  @override
  void dispose() {
    _items.clear();
    super.dispose();
  }
}
