import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'transaction_model.dart';
import 'add_transaction_screen.dart';
import 'edit_transaction_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // 1. Tải danh sách giao dịch từ CSDL SQLite
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.getAllTransactions();
    setState(() {
      _transactions = data;
      _isLoading = false;
    });
  }

  // 2. Định dạng hiển thị tiền VNĐ (Ví dụ: 5000000 -> 5.000.000)
  String _formatVnd(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
    );
  }

  // 3. Tính toán Tổng Thu nhập, Tổng Chi tiêu và Số dư
  int get _totalIncome => _transactions
      .where((item) => !item.isExpense)
      .fold(0, (sum, item) => sum + item.amount);

  int get _totalExpense => _transactions
      .where((item) => item.isExpense)
      .fold(0, (sum, item) => sum + item.amount);

  int get _balance => _totalIncome - _totalExpense;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.black87),
        title: const Text(
          'Quản lý thu chi',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.black87),
                onPressed: () {},
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                  child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // THẺ SỐ DƯ HIỆN TẠI (TỰ ĐỘNG CẬP NHẬT)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('SỐ DƯ HIỆN TẠI', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                        SizedBox(width: 6),
                        Icon(Icons.visibility, color: Colors.white70, size: 16),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_formatVnd(_balance)} đ',
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // TỔNG THU NHẬP & TỔNG CHI TIÊU
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          const CircleAvatar(radius: 16, backgroundColor: Colors.green, child: Icon(Icons.arrow_downward, color: Colors.white, size: 18)),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('TỔNG THU NHẬP', style: TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold)),
                              Text('${_formatVnd(_totalIncome)} đ', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          const CircleAvatar(radius: 16, backgroundColor: Colors.red, child: Icon(Icons.arrow_upward, color: Colors.white, size: 18)),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('TỔNG CHI TIÊU', style: TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold)),
                              Text('${_formatVnd(_totalExpense)} đ', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // DANH SÁCH GIAO DỊCH GẦN ĐÂY
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Giao dịch gần đây', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () {}, child: const Text('Xem tất cả')),
                ],
              ),

              const SizedBox(height: 8),

              _transactions.isEmpty
                  ? const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('Chưa có giao dịch nào. Nhấn + để thêm!')),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  final item = _transactions[index];
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    child: ListTile(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditTransactionScreen(transaction: item),
                          ),
                        );
                        if (result == true) _loadData();
                      },
                      leading: CircleAvatar(
                        backgroundColor: (item.isExpense ? Colors.orange : Colors.green).withValues(alpha: 0.15),
                        child: Icon(
                          item.isExpense ? Icons.restaurant : Icons.account_balance_wallet,
                          color: item.isExpense ? Colors.orange : Colors.green,
                        ),
                      ),
                      title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${item.category} • ${item.date}', style: const TextStyle(fontSize: 12)),
                      trailing: Text(
                        '${item.isExpense ? '-' : '+'}${_formatVnd(item.amount)} đ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: item.isExpense ? Colors.red : Colors.green,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),

      // NÚT THÊM GIAO DỊCH (+)
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
          );
          if (result == true) _loadData();
        },
        backgroundColor: const Color(0xFF2563EB),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),

      // THANH MENU DƯỚI CÙNG
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Giao dịch'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Thống kê'),
        ],
      ),
    );
  }
}