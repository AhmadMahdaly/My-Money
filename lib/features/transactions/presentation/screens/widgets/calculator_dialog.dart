// ignore_for_file: unnecessary_breaks

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
  String _output = '0';
  String _currentNumber = '';
  double? _num1;
  String _operand = '';
  bool _justCalculated = false;

  void _buttonPressed(String buttonText) {
    if ('0123456789.'.contains(buttonText)) {
      _enterNumber(buttonText);
    } else if ('+-*/'.contains(buttonText)) {
      _chooseOperation(buttonText);
    } else if (buttonText == 'C') {
      _clear();
    } else if (buttonText == '=') {
      _calculate();
    }
  }

  void _enterNumber(String digit) {
    setState(() {
      if (_justCalculated) {
        _currentNumber = '';
        _justCalculated = false;
      }
      if (_currentNumber.contains('.') && digit == '.') return;
      if (_currentNumber.isEmpty && digit == '.') {
        _currentNumber = '0.';
      } else {
        _currentNumber += digit;
      }
      _output = _currentNumber;
    });
  }

  void _chooseOperation(String op) {
    setState(() {
      if (_currentNumber.isEmpty && _num1 == null) {
        return;
      }

      if (_currentNumber.isNotEmpty) {
        if (_num1 == null) {
          _num1 = double.parse(_currentNumber);
        } else if (!_justCalculated) {
          _calculate();
        }
      }

      _operand = op;
      _currentNumber = '';
      _justCalculated = false;
    });
  }

  void _calculate() {
    if (_currentNumber.isEmpty || _operand.isEmpty || _num1 == null) return;

    final num2 = double.parse(_currentNumber);
    double result = 0;

    switch (_operand) {
      case '+':
        result = _num1! + num2;
        break;
      case '-':
        result = _num1! - num2;
        break;
      case '*':
        result = _num1! * num2;
        break;
      case '/':
        if (num2 == 0) {
          setState(() {
            _output = 'غلطة';
            _currentNumber = '';
            _num1 = null;
            _operand = '';
          });
          return;
        }
        result = _num1! / num2;
        break;
    }

    setState(() {
      _output = result.toStringAsFixed(2);
      _currentNumber = _output;
      _num1 = result;
      _operand = '';
      _justCalculated = true;
    });
  }

  void _clear() {
    setState(() {
      _output = '0';
      _currentNumber = '';
      _num1 = null;
      _operand = '';
      _justCalculated = false;
    });
  }

  Widget _buildButton(String buttonText, {Color? color}) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(4.r),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(10.r),
            backgroundColor: color ?? AppColors.primaryColor,
          ),
          onPressed: () => _buttonPressed(buttonText),
          child: Text(
            buttonText,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != 0.0) {
      _currentNumber = widget.initialValue.toString();
      _output = _currentNumber;
      _num1 = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'اعمل حسبتك',
        style: AppTextStyles.style18Bold.copyWith(fontFamily: kPrimaryFont),
      ),
      content: SizedBox(
        width: 300.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_num1 != null && _operand.isNotEmpty)
              Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Text(
                  '${_num1!.toStringAsFixed(2)} $_operand',
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                ),
              ),
            Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.all(12.r),
              child: Text(
                _output,
                style: TextStyle(
                  fontSize: 48.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            Column(
              children: [
                Row(
                  children: [
                    _buildButton('7'),
                    _buildButton('8'),
                    _buildButton('9'),
                    _buildButton('/', color: Colors.orange),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('4'),
                    _buildButton('5'),
                    _buildButton('6'),
                    _buildButton('*', color: Colors.orange),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('1'),
                    _buildButton('2'),
                    _buildButton('3'),
                    _buildButton('-', color: Colors.orange),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('.'),
                    _buildButton('0'),
                    _buildButton('C', color: Colors.grey),
                    _buildButton('+', color: Colors.orange),
                  ],
                ),
                Row(
                  children: [
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(double.tryParse(_output) ?? 0.0);
          },
          child: const Text('استخدم الناتج'),
        ),
      ],
    );
  }
}
