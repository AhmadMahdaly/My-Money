class AppCurrency {
  const AppCurrency({
    required this.code,
    required this.symbol,
    required this.nameAr,
  });

  final String code;
  final String symbol;
  final String nameAr;
}

const String kDefaultCurrencyCode = 'EGP';

const List<AppCurrency> kAppCurrencies = [
  AppCurrency(code: 'EGP', symbol: 'ج.م', nameAr: 'جنيه مصري'),
  AppCurrency(code: 'SAR', symbol: 'ر.س', nameAr: 'ريال سعودي'),
  AppCurrency(code: 'AED', symbol: 'د.إ', nameAr: 'درهم إماراتي'),
  AppCurrency(code: 'KWD', symbol: 'د.ك', nameAr: 'دينار كويتي'),
  AppCurrency(code: 'QAR', symbol: 'ر.ق', nameAr: 'ريال قطري'),
  AppCurrency(code: 'BHD', symbol: 'د.ب', nameAr: 'دينار بحريني'),
  AppCurrency(code: 'OMR', symbol: 'ر.ع', nameAr: 'ريال عماني'),
  AppCurrency(code: 'JOD', symbol: 'د.أ', nameAr: 'دينار أردني'),
  AppCurrency(code: 'USD', symbol: r'$', nameAr: 'دولار أمريكي'),
  AppCurrency(code: 'EUR', symbol: '€', nameAr: 'يورو'),
];

AppCurrency currencyByCode(String code) {
  return kAppCurrencies.firstWhere(
    (c) => c.code == code,
    orElse: () => kAppCurrencies.first,
  );
}
