import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DataInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset < oldValue.selection.baseOffset) {
      return newValue;
    }
    var text = newValue.text.replaceAll('/', '');
    if (text.length > 8) text = text.substring(0, 8);
    
    var formatted = '';
    for (var i = 0; i < text.length; i++) {
      formatted += text[i];
      if ((i == 1 || i == 3) && i != text.length - 1) {
        formatted += '/';
      }
    }
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class TelefoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset < oldValue.selection.baseOffset) return newValue;

    var text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (text.length > 11) text = text.substring(0, 11);

    var formatted = '';
    if (text.isNotEmpty) {
      formatted = '(';
      if (text.length > 2) {
        formatted += '${text.substring(0, 2)}) ';
        if (text.length > 7) {
          formatted += '${text.substring(2, 7)}-${text.substring(7)}';
        } else {
          formatted += text.substring(2);
        }
      } else {
        formatted += text;
      }
    }

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class MoedaInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) return newValue;

    String onlyDigits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    double value = double.parse(onlyDigits);

    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: '');
    String newText = formatter.format(value / 100).trim();

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}