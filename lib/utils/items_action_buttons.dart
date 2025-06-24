// ignore_for_file: constant_identifier_names

import 'package:alqayimm_app_flutter/main.dart';
import 'package:alqayimm_app_flutter/models/main_db/book_model.dart';
import 'package:flutter/material.dart';

enum ActionButtonType { EDIT, DOWNLOAD, DELETE, SHARE }

typedef ActionButtonCallback<T> = void Function(T model);

class ItemActionButton<T> {
  final ActionButtonType type;
  final ActionButtonCallback<T> callback;

  ItemActionButton({required this.type, required this.callback});
}

List<ItemActionButton<BookModel>> buildBookActionButtons(BookModel book) {
  return [
    ItemActionButton<BookModel>(
      type: ActionButtonType.DELETE,
      callback: (book) {
        logger.info('Delete book: ${book.name}');
      },
    ),
  ];
}
