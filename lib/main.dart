import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dashboard_screen.dart';

void main() {
  runApp(const ExpenseManagerApp());
}

class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Tắt chữ DEBUG ở góc màn hình
      home: Builder(
        builder: (context) => Scaffold(
          backgroundColor: Colors.white,   // Nền màn hình màu trắng tinh khiết
          body: SafeArea(                  // Bảo vệ không bị che bởi tai thỏ, pin
            child: Padding(
              padding: const EdgeInsets.all(24), // Cách đều 4 mép màn hình 24px
              child: Column(
                children: [
                  // 1. Khối nội dung chính ở giữa (dùng Expanded để đẩy nút xuống đáy)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center, // Gom vào giữa
                      children: [
                        // Logo ví tiền gốc
                        Image.asset(
                          'assets/images/logo.png',
                          width: 140, // Kích thước to rõ, nổi bật
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.account_balance_wallet_rounded,
                            size: 100,
                            color: Color(0xFF1967D2),
                          ),
                        ),
                        const SizedBox(height: 32), // Khoảng cách giữa ảnh và chữ

                        // Tiêu đề ứng dụng
                        const Text(
                          'Expense Manager',
                          style: TextStyle(
                            fontSize: 32,                 // Chữ to bản 32px
                            fontWeight: FontWeight.w800,  // In đậm đầm mắt
                            letterSpacing: -0.6,          // Khoảng cách chữ hiện đại
                            color: Color(0xFF0F172A),     // Màu xanh đen Slate-900
                          ),
                        ),
                        const SizedBox(height: 14), // Khoảng cách giữa 2 dòng chữ

                        // Dòng mô tả 2 dòng căn giữa
                        const Text(
                          'Quản lý chi tiêu cá nhân\nđơn giản và hiệu quả',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            letterSpacing: 0.2,
                            color: Color(0xFF64748B),     // Màu xám nhã nhặn
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. Nút bấm ở đáy màn hình
                  SizedBox(
                    width: double.infinity, // Kéo rộng hết chiều ngang màn hình
                    child: ElevatedButton(
                      onPressed: () {
                        // Bấm nút "Bắt đầu" sẽ chuyển thẳng sang Màn hình chính Dashboard
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DashboardScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1967D2), // Xanh dương đặc
                        foregroundColor: Colors.white,              // Chữ màu trắng
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),  // Bo góc chữ nhật nhẹ
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14), // Chiều cao vừa vặn
                        elevation: 2,
                      ),
                      child: const Text(
                        'Bắt đầu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// MODEL (dành cho Form giao dịch)
// ---------------------------------------------------------------------------

enum TxType { expense, income }

class Category {
  const Category(this.id, this.name, this.icon, this.type);
  final String id;
  final String name;
  final IconData icon;
  final TxType type;
}

const kCategories = <Category>[
  Category('food', 'Ăn uống', Icons.restaurant, TxType.expense),
  Category('transport', 'Di chuyển', Icons.directions_bike, TxType.expense),
  Category('shopping', 'Mua sắm', Icons.shopping_bag, TxType.expense),
  Category('bill', 'Hóa đơn', Icons.receipt_long, TxType.expense),
  Category('salary', 'Lương', Icons.payments, TxType.income),
  Category('bonus', 'Thưởng', Icons.card_giftcard, TxType.income),
];

class TransactionItem {
  const TransactionItem({
    required this.id,
    required this.type,
    required this.categoryId,
    required this.amount, // đơn vị: đồng, kiểu int (KHÔNG dùng double)
    required this.date,
    this.note = '',
  });

  final String id;
  final TxType type;
  final String categoryId;
  final int amount;
  final DateTime date;
  final String note;
}

// ---------------------------------------------------------------------------
// TIỆN ÍCH ĐỊNH DẠNG TIỀN
// ---------------------------------------------------------------------------

/// 100000 -> "100.000"
String formatVnd(int value) => value
    .toString()
    .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');

/// Chỉ cho nhập chữ số, tự thêm dấu chấm ngăn cách hàng nghìn.
class VndInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 12) digits = digits.substring(0, 12); // tránh tràn số
    if (digits.isEmpty) return const TextEditingValue();
    final text = formatVnd(int.parse(digits));
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

// ---------------------------------------------------------------------------
// MÀN HÌNH: dùng chung cho Thêm (initial == null) và Sửa (initial != Null)
// ---------------------------------------------------------------------------

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key, this.initial});

  final TransactionItem? initial;
  bool get isEdit => initial != null;

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateFormat = DateFormat('dd/MM/yyyy');

  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;
  late TxType _type;
  late DateTime _date;
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    final t = widget.initial;
    _type = t?.type ?? TxType.expense;
    _categoryId = t?.categoryId;
    _date = t?.date ?? DateTime.now();
    _amountCtrl = TextEditingController(
        text: t == null ? '' : formatVnd(t.amount));
    _noteCtrl = TextEditingController(text: t?.note ?? '');
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  List<Category> get _categories =>
      kCategories.where((c) => c.type == _type).toList();

  Color get _typeColor =>
      _type == TxType.expense ? const Color(0xFFFF6B6B) : const Color(0xFF2E9E6B);

  void _changeType(TxType type) {
    if (type == _type) return;
    setState(() {
      _type = type;
      _categoryId = null; // danh mục của loại cũ không còn hợp lệ
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final amount = int.parse(_amountCtrl.text.replaceAll('.', ''));
    final item = TransactionItem(
      id: widget.initial?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      type: _type,
      categoryId: _categoryId!,
      amount: amount,
      date: _date,
      note: _noteCtrl.text.trim(),
    );

    Navigator.pop(context, item);
  }

  InputDecoration _decoration({String? hint, String? suffixText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      suffixText: suffixText,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.isEdit ? 'Sửa giao dịch' : 'Thêm giao dịch'),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TypeToggle(
                    value: _type,
                    activeColor: _typeColor,
                    onChanged: _changeType,
                  ),
                  const SizedBox(height: 20),

                  const _Label('Danh mục'),
                  DropdownButtonFormField<String>(
                    key: ValueKey(_type),
                    initialValue: _categoryId,
                    isExpanded: true,
                    decoration: _decoration(hint: 'Chọn danh mục'),
                    items: [
                      for (final c in _categories)
                        DropdownMenuItem(
                          value: c.id,
                          child: Row(children: [
                            Icon(c.icon, size: 20, color: _typeColor),
                            const SizedBox(width: 10),
                            Text(c.name),
                          ]),
                        ),
                    ],
                    onChanged: (v) => setState(() => _categoryId = v),
                    validator: (v) => v == null ? 'Vui lòng chọn danh mục' : null,
                  ),
                  const SizedBox(height: 20),

                  const _Label('Số tiền'),
                  TextFormField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [VndInputFormatter()],
                    decoration: _decoration(hint: 'Nhập số tiền', suffixText: 'đ'),
                    validator: (v) {
                      final raw = (v ?? '').replaceAll('.', '');
                      if (raw.isEmpty) return 'Vui lòng nhập số tiền';
                      if ((int.tryParse(raw) ?? 0) <= 0) {
                        return 'Số tiền phải lớn hơn 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  const _Label('Ngày giao dịch'),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: _decoration(
                        suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
                      ),
                      child: Text(_dateFormat.format(_date)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const _Label('Ghi chú'),
                  TextFormField(
                    controller: _noteCtrl,
                    maxLines: 4,
                    maxLength: 200,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _decoration(hint: 'Nhập ghi chú (tùy chọn)'),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Lưu'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// WIDGET CON
// ---------------------------------------------------------------------------

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.w600)),
  );
}

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  final TxType value;
  final Color activeColor;
  final ValueChanged<TxType> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget tab(String label, TxType type) {
      final selected = value == type;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? activeColor : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        tab('Chi tiêu', TxType.expense),
        tab('Thu nhập', TxType.income),
      ]),
    );
  }
}