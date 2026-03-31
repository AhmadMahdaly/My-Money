// ignore_for_file: unnecessary_breaks, parameter_assignments

import 'package:flutter/material.dart';
import 'package:opration/core/constants.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';

class CalculatorDialog extends StatefulWidget {
  const CalculatorDialog({super.key, this.initialValue = 0.0});
  final double initialValue;

  @override
  State<CalculatorDialog> createState() => _CalculatorDialogState();
}

class _CalculatorDialogState extends State<CalculatorDialog> {
  String _expression = ''; // التعبير الكامل
  String _output = '0'; // الناتج النهائي
  bool _justCalculated = false;

  //--------------------------------------------------------------------
  //  دالة حساب التعبير بالكامل مع دعم الأقواس
  //--------------------------------------------------------------------
  double _evaluateExpression(String expr) {
    try {
      expr = expr.replaceAll('×', '*').replaceAll('÷', '/');

      final tokens = _tokenize(expr);
      final postfix = _toPostfix(tokens);
      return _evalPostfix(postfix);
    } catch (e) {
      return double.nan;
    }
  }

  //--------------------------------------------------------------------
  // تجزئة التعبير إلى Tokens
  //--------------------------------------------------------------------
  List<String> _tokenize(String expr) {
    final tokens = <String>[];
    var number = '';

    for (var i = 0; i < expr.length; i++) {
      final c = expr[i];

      if ('0123456789.'.contains(c)) {
        number += c;
      } else {
        if (number.isNotEmpty) {
          tokens.add(number);
          number = '';
        }
        tokens.add(c);
      }
    }
    if (number.isNotEmpty) tokens.add(number);

    return tokens;
  }

  //--------------------------------------------------------------------
  // تحويل INFIX → POSTFIX (خوارزمية Shunting Yard)
  //--------------------------------------------------------------------
  List<String> _toPostfix(List<String> tokens) {
    final output = <String>[];
    final stack = <String>[];

    final prec = {'+': 1, '-': 1, '*': 2, '/': 2};

    for (final token in tokens) {
      if (double.tryParse(token) != null) {
        output.add(token);
      } else if ('+-*/'.contains(token)) {
        while (stack.isNotEmpty &&
            '+-*/'.contains(stack.last) &&
            prec[stack.last]! >= prec[token]!) {
          output.add(stack.removeLast());
        }
        stack.add(token);
      } else if (token == '(') {
        stack.add(token);
      } else if (token == ')') {
        while (stack.isNotEmpty && stack.last != '(') {
          output.add(stack.removeLast());
        }
        if (stack.isNotEmpty) stack.removeLast(); // remove "("
      }
    }

    while (stack.isNotEmpty) {
      output.add(stack.removeLast());
    }

    return output;
  }

  //--------------------------------------------------------------------
  // تنفيذ POSTFIX
  //--------------------------------------------------------------------
  double _evalPostfix(List<String> postfix) {
    final stack = <double>[];

    for (final token in postfix) {
      if (double.tryParse(token) != null) {
        stack.add(double.parse(token));
      } else {
        final b = stack.removeLast();
        final a = stack.removeLast();

        switch (token) {
          case '+':
            stack.add(a + b);
            break;
          case '-':
            stack.add(a - b);
            break;
          case '*':
            stack.add(a * b);
            break;
          case '/':
            stack.add(a / b);
            break;
        }
      }
    }
    return stack.first;
  }

  //--------------------------------------------------------------------
  // ضغط الأزرار
  //--------------------------------------------------------------------
  void _buttonPressed(String buttonText) {
    if (buttonText == '⌫') {
      _backspace();
      return;
    }

    if (_justCalculated && '0123456789('.contains(buttonText)) {
      _expression = '';
      _justCalculated = false;
    }

    if ('0123456789.+-*/()'.contains(buttonText)) {
      setState(() {
        _expression += buttonText;
        _output = _expression;
      });
    } else if (buttonText == 'C') {
      _clear();
    } else if (buttonText == '=') {
      _calculate();
    }
  }

  void _calculate() {
    final result = _evaluateExpression(_expression);

    setState(() {
      if (result.isNaN) {
        _output = 'غلطة';
      } else {
        // إذا كان الناتج عددًا صحيحًا → عرضه بدون كسور
        if (result % 1 == 0) {
          _output = result.toInt().toString();
        } else {
          _output = result.toString();
        }
      }

      _justCalculated = true;
    });
  }

  void _backspace() {
    setState(() {
      if (_expression.isNotEmpty) {
        _expression = _expression.substring(0, _expression.length - 1);
        _output = _expression.isEmpty ? '0' : _expression;
      }
    });
  }

  void _clear() {
    setState(() {
      _expression = '';
      _output = '0';
      _justCalculated = false;
    });
  }

  //--------------------------------------------------------------------
  // زر واحد
  //--------------------------------------------------------------------
  Widget _buildButton(String text, {Color? color}) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(4.r),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? AppColors.primaryColor,
            padding: EdgeInsets.all(10.r),
          ),
          onPressed: () => _buttonPressed(text),
          child: Text(
            text,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != 0.0) {
      _expression = widget.initialValue.toString();
      _output = _expression;
    }
  }

  //--------------------------------------------------------------------
  // واجهة الـ Dialog
  //--------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'اعمل حسبتك',
        style: AppTextStyle.style18Bold.copyWith(fontFamily: kPrimaryFont),
      ),
      content: SizedBox(
        width: 300.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.all(12.r),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _output,
                  style: TextStyle(
                    fontSize: 48.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const Divider(),

            // الأزرار
            Column(
              children: [
                Row(
                  children: [
                    _buildButton('('),
                    _buildButton(')'),
                    _buildButton('C', color: Colors.grey),
                    _buildButton('/', color: Colors.orange),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('7'),
                    _buildButton('8'),
                    _buildButton('9'),
                    _buildButton('*', color: Colors.orange),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('4'),
                    _buildButton('5'),
                    _buildButton('6'),
                    _buildButton('-', color: Colors.orange),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('1'),
                    _buildButton('2'),
                    _buildButton('3'),
                    _buildButton('+', color: Colors.orange),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('0'),
                    _buildButton('.'),
                    _buildButton('⌫', color: Colors.red),
                    _buildButton('=', color: Colors.green),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, double.tryParse(_output) ?? 0.0);
          },
          child: const Text('استخدم الناتج'),
        ),
      ],
    );
  }
}
