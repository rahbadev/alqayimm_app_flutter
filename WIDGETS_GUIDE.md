# دليل الودجيتات المخصصة للملاحظات

هذا الدليل يوضح الودجيتات المخصصة الجديدة التي تم إنشاؤها لتحسين تنظيم الكود وتقليل التكرار في شاشتي الملاحظات.

## 🔧 الودجيتات الأساسية

### 1. IconCard (`lib/widget/icons/icon_card.dart`)
ودجيت لعرض أيقونة داخل Card مع تخصيص الألوان والحجم.

```dart
// استخدام الأساسي
IconCard.primary(
  icon: Icons.note_add_rounded,
  size: 28,
)

// استخدام ثانوي
IconCard.secondary(
  icon: Icons.edit_rounded,
  size: 24,
)
```

### 2. InfoContainer (`lib/widget/containers/info_container.dart`)
حاوية لعرض المعلومات السياقية مع أيقونة.

```dart
// حاوية أساسية
InfoContainer.primary(
  text: 'معلومات مهمة',
  icon: Icons.info_rounded,
)

// حاوية تحذير
InfoContainer.warning(
  text: 'تحذير',
  icon: Icons.warning_rounded,
)
```

### 3. EmptyStateWidget (`lib/widget/states/empty_state_widget.dart`)
ودجيت للحالات الفارغة (لا توجد ملاحظات/علامات/نتائج بحث).

```dart
// حالة فارغة للملاحظات
EmptyStateWidget.notes()

// حالة فارغة للعلامات
EmptyStateWidget.tags()

// حالة فارغة للبحث
EmptyStateWidget.search()
```

### 4. CustomButton (`lib/widget/buttons/custom_button.dart`)
زر مخصص يدعم الأنماط المختلفة والحالات.

```dart
// زر أساسي
CustomButton.primary(
  text: 'حفظ',
  icon: Icons.save_rounded,
  onPressed: () => _save(),
  isLoading: _isLoading,
)

// زر ثانوي
CustomButton.secondary(
  text: 'إلغاء',
  icon: Icons.close_rounded,
  onPressed: () => Navigator.pop(context),
)
```

## 🎴 ودجيتات البطاقات

### 5. NoteCard (`lib/widget/cards/note_card.dart`)
بطاقة موحدة لعرض الملاحظة مع كل التفاصيل.

```dart
NoteCard(
  note: noteModel,
  onTap: () => _openNote(note),
  onActionSelected: (action) => _handleAction(action, note),
)
```

### 6. TagChip (`lib/widget/chips/tag_chip.dart`)
ودجيت مخصص لعرض شرائح العلامات.

```dart
// شريحة عادية
TagChip.standard(
  label: 'تعليم',
  isSelected: true,
  onSelected: (selected) => _toggleTag(selected),
)

// شريحة صغيرة
TagChip.small(
  label: 'مهم',
  isSelected: false,
)
```

## 📋 ودجيتات الحوارات

### 7. DialogHeader (`lib/widget/headers/dialog_header.dart`)
رأس موحد للحوارات مع الأيقونة والعنوان.

```dart
DialogHeader.primary(
  title: 'إضافة ملاحظة جديدة',
  subtitle: 'أضف ملاحظة جديدة لحفظ أفكارك المهمة',
  icon: Icons.note_add_rounded,
)
```

### 8. DialogFooter (`lib/widget/footers/dialog_footer.dart`)
ذيل موحد للحوارات مع أزرار العمليات.

```dart
// ذيل بزرين
DialogFooter.dualAction(
  secondaryAction: CustomButton.secondary(
    text: 'إلغاء',
    onPressed: () => Navigator.pop(context),
  ),
  primaryAction: CustomButton.primary(
    text: 'حفظ',
    onPressed: () => _save(),
  ),
)
```

## 🔍 ودجيتات البحث والفلترة

### 9. SearchField (`lib/widget/fields/search_field.dart`)
حقل بحث مخصص للاستخدامات المختلفة.

```dart
// بحث الملاحظات
SearchField.notes(
  controller: _searchController,
  onSubmitted: (query) => _search(query),
)

// بحث العلامات
SearchField.tags(
  controller: _tagController,
  onSubmitted: (tag) => _addTag(tag),
)
```

### 10. FilterContainer (`lib/widget/containers/filter_container.dart`)
حاوية موحدة للفلاتر والبحث.

```dart
// حاوية بزاوية منحنية سفلية
FilterContainer.bottomRounded(
  child: Column(
    children: [
      SearchField.notes(),
      // فلاتر أخرى...
    ],
  ),
)
```

## 📖 أمثلة عملية

### مثال: إنشاء حوار جديد
```dart
Dialog(
  child: Column(
    children: [
      DialogHeader.primary(
        title: 'عنوان الحوار',
        subtitle: 'وصف الحوار',
        icon: Icons.add_rounded,
      ),
      
      // محتوى الحوار
      Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            SearchField.standard(),
            SizedBox(height: 16),
            EmptyStateWidget.search(),
          ],
        ),
      ),
      
      DialogFooter.dualAction(
        secondaryAction: CustomButton.secondary(
          text: 'إلغاء',
          onPressed: () => Navigator.pop(context),
        ),
        primaryAction: CustomButton.primary(
          text: 'تأكيد',
          onPressed: () => _confirm(),
        ),
      ),
    ],
  ),
)
```

### مثال: قائمة بالبطاقات
```dart
ListView.builder(
  itemBuilder: (context, index) {
    final note = notes[index];
    return NoteCard(
      note: note,
      onTap: () => _openNote(note),
      onActionSelected: (action) => _handleAction(action, note),
    );
  },
)
```

## 🎨 مزايا الودجيتات الجديدة

1. **تقليل التكرار**: تم تجميع الودجيتات المتكررة في مكونات قابلة لإعادة الاستخدام
2. **التناسق**: تصميم موحد عبر التطبيق
3. **سهولة الصيانة**: تعديل الودجيت في مكان واحد يؤثر على جميع الاستخدامات
4. **المرونة**: إمكانية التخصيص حسب الحاجة
5. **الوضوح**: أسماء واضحة ومعبرة للودجيتات والمعاملات

## 🔄 نصائح للاستخدام

1. استخدم المُنشئات المسماة (named constructors) للحصول على أنماط محددة
2. تأكد من استيراد الودجيت المطلوب قبل الاستخدام
3. استخدم الودجيتات المناسبة للسياق (مثل TagChip.small للمساحات الضيقة)
4. يمكن دمج الودجيتات مع بعضها لإنشاء واجهات معقدة

## 📁 هيكل الملفات
```
lib/widget/
├── buttons/
│   └── custom_button.dart
├── cards/
│   └── note_card.dart
├── chips/
│   └── tag_chip.dart
├── containers/
│   ├── info_container.dart
│   └── filter_container.dart
├── fields/
│   └── search_field.dart
├── footers/
│   └── dialog_footer.dart
├── headers/
│   └── dialog_header.dart
├── icons/
│   └── icon_card.dart
└── states/
    └── empty_state_widget.dart
```

---

تم تطوير هذه الودجيتات لتحسين تنظيم الكود في تطبيق **الملاحظات** مع ضمان التناسق والمرونة في التصميم.
