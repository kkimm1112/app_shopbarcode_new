class SalesHistory {
  final int? id;
  final DateTime dateTime;
  final List<Map<String, dynamic>> items; // ชื่อ, ราคา, จำนวน
  final double total;

  SalesHistory({
    this.id,
    required this.dateTime,
    required this.items,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'dateTime': dateTime.toIso8601String(),
      'items': items.map((e) => e.toString()).join('|'),
      'total': total,
    };
  }

  static SalesHistory fromMap(Map<String, dynamic> map) {
    final rawItems = map['items'].toString().split('|');
    final itemList = rawItems.map((e) {
      final match = RegExp(r'name: (\S+), price: ([\d.]+), qty: (\d+)').firstMatch(e);
      if (match != null) {
        return {
          'name': match.group(1),
          'price': double.parse(match.group(2)!),
          'qty': int.parse(match.group(3)!),
        };
      }
      return {};
    }).toList();

    return SalesHistory(
      id: map['id'],
      dateTime: DateTime.parse(map['dateTime']),
      items: itemList.cast<Map<String, dynamic>>(),
      total: map['total'],
    );
  }
}
