class TransactionModel {
  final String id;
  final String title;
  final int amount;
  final bool isExpense; // true: Chi tiêu, false: Thu nhập
  final String date;
  final String category;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.isExpense,
    required this.date,
    required this.category,
  });

  // Chuyển đối tượng sang Map để lưu vào SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'isExpense': isExpense ? 1 : 0,
      'date': date,
      'category': category,
    };
  }

  // chuyển Map từ SQLite về lại đối tượng Dart
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      isExpense: map['isExpense'] == 1,
      date: map['date'],
      category: map['category'],
    );
  }
}