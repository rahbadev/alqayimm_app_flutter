// ignore_for_file: constant_identifier_names

class DbConstants {
  // SQL Keywords
  static const String SELECT = " SELECT ";
  static const String ALL = " * ";
  static const String FROM = " FROM ";
  static const String WHERE = " WHERE ";
  static const String EQUALS = " = ";
  static const String COMMA = " , ";
  static const String LIKE = " LIKE ";
  static const String JOIN = " join ";
  static const String ON = " on ";
  static const String SPACE = " ";

  // Table Names
  static const String AUTHORS_TABLE = "authors_table";
  static const String BOOKS_TABLE = "books_table";
  static const String BOOKS_TYPES_TABLE = "institute_library_table";
  static const String CATEGORIES_TABLE = "categories_table";
  static const String LESSONS_TABLE = "lessons_table";
  static const String LEVELS_TABLE = "levels_table";
  static const String MATERIALS_BOOKS_TABLE = "materials_books_table";
  static const String MATERIALS_TABLE = "materials_table";

  // AUTHORS_TABLE Columns
  static const String AUTHORS_ID = "id";
  static const String AUTHORS_NAME = "name";
  static const String AUTHORS_ABOUT = "about_author";

  // BOOKS_TABLE Columns
  static const String BOOKS_ID = "id";
  static const String BOOKS_NAME = "name";
  static const String BOOKS_AUTHOR_ID = "author_id";
  static const String BOOKS_CATEGORY_ID = "category_id";
  static const String BOOKS_TYPE_ID = "institute_type_id";
  static const String BOOKS_ABOUT = "about_book";
  static const String BOOKS_URL = "book_url";
  static const String BOOKS_VER = "book_ver";
  static const String BOOKS_ABOUT_VER = "about_ver";
  static const String BOOKS_THUMB_URL = "book_thumb_url";

  // BOOKS_TYPES_TABLE Columns
  static const String BOOKS_TYPES_ID = "id";
  static const String BOOKS_TYPES_NAME = "name";

  // CATEGORIES_TABLE Columns
  static const String CATEGORIES_ID = "id";
  static const String CATEGORIES_NAME = "name";

  // LESSONS_TABLE Columns
  static const String LESSONS_ID = "id";
  static const String LESSONS_MATERIAL_ID = "material_id";
  static const String LESSONS_NUMBER = "lesson_number";
  static const String LESSONS_NAME = "lesson_name";
  static const String LESSONS_ABOUT = "about_lesson";
  static const String LESSONS_URL = "url";
  static const String LESSONS_VER = "ver";
  static const String LESSONS_ABOUT_VER = "about_ver";

  // LEVELS_TABLE Columns
  static const String LEVELS_ID = "id";
  static const String LEVELS_NAME = "name";

  // MATERIALS_BOOKS_TABLE Columns
  static const String MATERIALS_BOOKS_BOOK_ID = "book_id";
  static const String MATERIALS_BOOKS_MATERIAL_ID = "material_id";

  // MATERIALS_TABLE Columns
  static const String MATERIALS_ID = "id";
  static const String MATERIALS_NAME = "name";
  static const String MATERIALS_ABOUT = "about_material";
  static const String MATERIALS_AUTHOR_ID = "author_id";
  static const String MATERIALS_LEVEL_ID = "level_id";
  static const String MATERIALS_CATEGORY_ID = "category_id";
}
