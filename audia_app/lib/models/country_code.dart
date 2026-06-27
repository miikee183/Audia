import 'package:flutter/widgets.dart';

class CountryCode {
  final String flag;
  final String code;
  final String name;
  final String isoCode;

  const CountryCode(this.flag, this.code, this.name, this.isoCode);
}

const countries = [
  CountryCode('\u{1F1EE}\u{1F1F3}', '+91', 'India', 'IN'),
  CountryCode('\u{1F1E8}\u{1F1F3}', '+86', 'China', 'CN'),
  CountryCode('\u{1F1FA}\u{1F1F8}', '+1', 'USA', 'US'),
  CountryCode('\u{1F1EE}\u{1F1E9}', '+62', 'Indonesia', 'ID'),
  CountryCode('\u{1F1F5}\u{1F1F0}', '+92', 'PakistÃ¡n', 'PK'),
  CountryCode('\u{1F1F3}\u{1F1EC}', '+234', 'Nigeria', 'NG'),
  CountryCode('\u{1F1E7}\u{1F1F7}', '+55', 'Brasil', 'BR'),
  CountryCode('\u{1F1E7}\u{1F1E9}', '+880', 'Bangladesh', 'BD'),
  CountryCode('\u{1F1F7}\u{1F1FA}', '+7', 'Rusia', 'RU'),
  CountryCode('\u{1F1F2}\u{1F1FD}', '+52', 'MÃ©xico', 'MX'),
  CountryCode('\u{1F1EF}\u{1F1F5}', '+81', 'JapÃ³n', 'JP'),
  CountryCode('\u{1F1F5}\u{1F1ED}', '+63', 'Filipinas', 'PH'),
  CountryCode('\u{1F1EA}\u{1F1EC}', '+20', 'Egipto', 'EG'),
  CountryCode('\u{1F1FB}\u{1F1F3}', '+84', 'Vietnam', 'VN'),
  CountryCode('\u{1F1E9}\u{1F1EA}', '+49', 'Alemania', 'DE'),
  CountryCode('\u{1F1F9}\u{1F1F7}', '+90', 'TurquÃ­a', 'TR'),
  CountryCode('\u{1F1EE}\u{1F1F7}', '+98', 'IrÃ¡n', 'IR'),
  CountryCode('\u{1F1F9}\u{1F1ED}', '+66', 'Tailandia', 'TH'),
  CountryCode('\u{1F1EC}\u{1F1E7}', '+44', 'Reino Unido', 'GB'),
  CountryCode('\u{1F1EB}\u{1F1F7}', '+33', 'Francia', 'FR'),
  CountryCode('\u{1F1EE}\u{1F1F9}', '+39', 'Italia', 'IT'),
  CountryCode('\u{1F1F0}\u{1F1F7}', '+82', 'Corea del Sur', 'KR'),
  CountryCode('\u{1F1E8}\u{1F1F1}', '+57', 'Colombia', 'CO'),
  CountryCode('\u{1F1EA}\u{1F1F8}', '+34', 'EspaÃ±a', 'ES'),
  CountryCode('\u{1F1E6}\u{1F1F7}', '+54', 'Argentina', 'AR'),
  CountryCode('\u{1F1E8}\u{1F1F4}', '+56', 'Chile', 'CL'),
  CountryCode('\u{1F1EA}\u{1F1E8}', '+51', 'PerÃº', 'PE'),
  CountryCode('\u{1F1FB}\u{1F1EA}', '+598', 'Uruguay', 'UY'),
  CountryCode('\u{1F1E6}\u{1F1EA}', '+58', 'Venezuela', 'VE'),
];

CountryCode detectCountry() {
  final locale = WidgetsBinding.instance.platformDispatcher.locales.first;
  final iso = locale.countryCode;
  if (iso != null && iso.isNotEmpty) {
    return countries.where((c) => c.isoCode == iso).firstOrNull ?? countries[0];
  }
  return countries[0];
}

