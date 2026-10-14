import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'transaction_model.dart';

class EditTransactionScreen extends StatefulWidget {
  // Nhận đối tượng giao dịch cần chỉnh sửa từ màn hình trước
  final TransactionModel? transaction;

  const EditTransactionScreen({super.key, this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late bool isExpense;
  late String selectedCategory;

  late TextEditingController amountController;
  late TextEditingController dateController;
  late TextEditingController noteController;

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Tự động điền dữ liệu cũ nếu có, nếu không thì dùng giá trị mặc định
    isExpense = widget.transaction?.isExpense ?? true;
    selectedCategory = widget.transaction?.category ?? (isExpense ? 'Ăn uống' : 'Lương');

    amountController = TextEditingController(
      text: widget.transaction != null ? widget.transaction!.amount.toString() : '100000',
    );
    dateController = TextEditingController(
      text: widget.transaction?.date ?? '12/04/2025',
    );
    noteController = TextEditingController(
      text: widget.transaction?.title ?? 'Ăn trưa',
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    dateController.dispose();
    noteController.dispose();
    super.dispose();
  }

  // Hàm chọn lại ngày giao dịch
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        dateController.text =
        "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sửa giao dịch',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Nút Xóa giao dịch
          if (widget.transaction != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () async {
                await DatabaseHelper.instance.deleteTransaction(widget.transaction!.id);
                if (!context.mounted) return;
                Navigator.pop(context, true);
              },
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Chuyển đổi loại Chi tiêu / Thu nhập
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          isExpense = true;
                          selectedCategory = 'Ăn uống';
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isExpense ? const Color(0xFFFF5252) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Chi tiêu',
                            style: TextStyle(
                              color: isExpense ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          isExpense = false;
                          selectedCategory = 'Lương';
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !isExpense ? const Color(0xFF2E9E6B) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Thu nhập',
                            style: TextStyle(
                              color: !isExpense ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Danh mục (Tự động cập nhật theo Chi tiêu / Thu nhập)
              const Text('Danh mục', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    items: isExpense
                        ? [
                      // Danh mục Chi tiêu
                      DropdownMenuItem(
                        value: 'Ăn uống',
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFEBEE),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.restaurant, color: Color(0xFFFF5252), size: 18),
                            ),
                            const SizedBox(width: 10),
                            const Text('Ăn uống'),
                          ],
                        ),
                      ),
                      const DropdownMenuItem(
                        value: 'Di chuyển',
                        child: Text('Di chuyển'),
                      ),
                      const DropdownMenuItem(
                        value: 'Mua sắm',
                        child: Text('Mua sắm'),
                      ),
                    ]
                        : [
                      // Danh mục Thu nhập
                      DropdownMenuItem(
                        value: 'Lương',
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8F5E9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.payments, color: Color(0xFF2E9E6B), size: 18),
                            ),
                            const SizedBox(width: 10),
                            const Text('Lương'),
                          ],
                        ),
                      ),
                      const DropdownMenuItem(
                        value: 'Thưởng',
                        child: Text('Thưởng'),
                      ),
                      const DropdownMenuItem(
                        value: 'Thu nhập khác',
                        child: Text('Thu nhập khác'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => selectedCategory = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 3. Số tiền
              const Text('Số tiền', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  suffixText: 'đ',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 4. Ngày giao dịch
              const Text('Ngày giao dịch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: dateController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  suffixIcon: const Icon(Icons.calendar_month_outlined, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 5. Ghi chú
              const Text('Ghi chú', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 6. Nút Lưu
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    // Loại bỏ dấu chấm nếu có trước khi chuyển sang kiểu số
                    final cleanAmount = amountController.text.replaceAll('.', '').trim();
                    final parsedAmount = int.tryParse(cleanAmount) ?? 0;

                    if (parsedAmount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ!')),
                      );
                      return;
                    }

                    // 1. Tạo đối tượng giao dịch đã cập nhật
                    final updatedTx = TransactionModel(
                      id: widget.transaction?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                      title: noteController.text.trim().isEmpty
                          ? selectedCategory
                          : noteController.text.trim(),
                      amount: parsedAmount,
                      isExpense: isExpense,
                      date: dateController.text,
                      category: selectedCategory,
                    );

                    // 2. Gọi hàm cập nhật sqlite
                    await DatabaseHelper.instance.updateTransaction(updatedTx);

                    // 3. chuẩn hóa context.mounted để tránh lỗi cảnh báo
                    if (!context.mounted) return;
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1967D2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Lưu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}