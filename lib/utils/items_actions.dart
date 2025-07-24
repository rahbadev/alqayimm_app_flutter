import 'package:flutter/material.dart';
import 'package:alqayimm_app_flutter/db/user/db_constants.dart';
import 'package:alqayimm_app_flutter/db/user/repos/user_item_status_repository.dart';
import 'package:alqayimm_app_flutter/widgets/dialogs/bookmark_dialog.dart';
import 'package:alqayimm_app_flutter/widgets/dialogs/note_dialog.dart';

class ItemsActions {
  static Future<void> addBookmark({
    required BuildContext context,
    required int itemId,
    required ItemType itemType,
    String? materialName,
    String? lessonName,
    String? bookName,
    int? position,
  }) async {
    if (itemType == ItemType.lesson) {
      await BookmarkDialog.showForLesson(
        context: context,
        lessonId: itemId,
        position: position,
        materialName: materialName,
        lessonName: lessonName,
      );
    } else if (itemType == ItemType.book) {
      await BookmarkDialog.showForBook(
        context: context,
        bookId: itemId,
        pageNumber: position,
        bookName: bookName,
      );
    }
  }

  static Future<void> addNote({
    required BuildContext context,
    required String source,
  }) async {
    await NoteDialog.showNoteDialog(context: context, source: source);
  }

  static Future<bool> toggleFavorite({
    required int itemId,
    required ItemType itemType,
  }) async {
    return await UserItemStatusRepository.toggleFavorite(itemId, itemType);
  }

  static Future<bool> toggleComplete({
    required int itemId,
    required ItemType itemType,
  }) async {
    return await UserItemStatusRepository.toggleCompleted(itemId, itemType);
  }
}
