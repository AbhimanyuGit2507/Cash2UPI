class ParsedSms {
  final String bankName;
  final double amount;
  final bool isCredit;
  final String? accountLast4;

  ParsedSms({
    required this.bankName,
    required this.amount,
    required this.isCredit,
    this.accountLast4,
  });
}

abstract class BankParser {
  bool canParse(String body, String sender);
  ParsedSms? parse(String body, String sender);

  double? extractAmount(String body, RegExp amountRegex) {
    final match = amountRegex.firstMatch(body);
    if (match != null) {
      final amountStr = match.group(1)?.replaceAll(',', '');
      if (amountStr != null) {
        return double.tryParse(amountStr);
      }
    }
    return null;
  }
}

class IciciParser extends BankParser {
  @override
  bool canParse(String body, String sender) => sender.toUpperCase().contains('ICICI');

  @override
  ParsedSms? parse(String body, String sender) {
    final amount = extractAmount(body, RegExp(r'(?:INR|Rs\.?)\s*([\d,]+\.?\d*)', caseSensitive: false));
    if (amount == null) return null;

    final isCredit = body.toLowerCase().contains('credited') || body.toLowerCase().contains('deposited');
    return ParsedSms(bankName: 'ICICI', amount: amount, isCredit: isCredit);
  }
}

class SbiParser extends BankParser {
  @override
  bool canParse(String body, String sender) => sender.toUpperCase().contains('SBI');

  @override
  ParsedSms? parse(String body, String sender) {
    final amount = extractAmount(body, RegExp(r'(?:INR|Rs\.?)\s*([\d,]+\.?\d*)', caseSensitive: false));
    if (amount == null) return null;

    final isCredit = body.toLowerCase().contains('credited') || body.toLowerCase().contains('deposited');
    return ParsedSms(bankName: 'SBI', amount: amount, isCredit: isCredit);
  }
}

class HdfcParser extends BankParser {
  @override
  bool canParse(String body, String sender) => sender.toUpperCase().contains('HDFC');

  @override
  ParsedSms? parse(String body, String sender) {
    final amount = extractAmount(body, RegExp(r'(?:INR|Rs\.?)\s*([\d,]+\.?\d*)', caseSensitive: false));
    if (amount == null) return null;

    final isCredit = body.toLowerCase().contains('credited') || body.toLowerCase().contains('deposited');
    return ParsedSms(bankName: 'HDFC', amount: amount, isCredit: isCredit);
  }
}

class AxisParser extends BankParser {
  @override
  bool canParse(String body, String sender) => sender.toUpperCase().contains('AXIS');

  @override
  ParsedSms? parse(String body, String sender) {
    final amount = extractAmount(body, RegExp(r'(?:INR|Rs\.?)\s*([\d,]+\.?\d*)', caseSensitive: false));
    if (amount == null) return null;

    final isCredit = body.toLowerCase().contains('credited') || body.toLowerCase().contains('deposited');
    return ParsedSms(bankName: 'Axis', amount: amount, isCredit: isCredit);
  }
}

class SmsParserEngine {
  final List<BankParser> _parsers = [
    IciciParser(),
    SbiParser(),
    HdfcParser(),
    AxisParser(),
    // Additional banks like PNB, BOB can be added similarly
  ];

  ParsedSms? parse(String body, String sender) {
    for (var parser in _parsers) {
      if (parser.canParse(body, sender)) {
        return parser.parse(body, sender);
      }
    }
    return null;
  }
}
