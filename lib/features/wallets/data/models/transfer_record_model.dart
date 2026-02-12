class TransferRecordModel {
  TransferRecordModel({
    required this.id,
    required this.fromWalletName,
    required this.toWalletName,
    required this.amount,
    required this.date,
  });

  factory TransferRecordModel.fromJson(Map<String, dynamic> json) =>
      TransferRecordModel(
        id: json['id'].toString(),
        fromWalletName: json['fromWalletName'].toString(),
        toWalletName: json['toWalletName'].toString(),
        amount: (json['amount'] as num).toDouble(),
        date: DateTime.parse(json['date'].toString()),
      );
  final String id;
  final String fromWalletName;
  final String toWalletName;
  final double amount;
  final DateTime date;

  Map<String, dynamic> toJson() => {
    'id': id,
    'fromWalletName': fromWalletName,
    'toWalletName': toWalletName,
    'amount': amount,
    'date': date.toIso8601String(),
  };
}
