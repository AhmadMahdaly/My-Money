import 'package:flutter/material.dart';

class CalculatorDialog extends StatefulWidget {
  const CalculatorDialog({super.key, this.initialValue = 0.0});
  final double initialValue;

  @override
  State<CalculatorDialog> createState() => _CalculatorDialogState();
}

class _CalculatorDialogState extends State<CalculatorDialog> {
  String _output = '0';
  String _currentNumber = '';
  double _num1 = 0;
  String _operand = '';

  void _buttonPressed(String buttonText) {
    setState(() {
      if ('0123456789.'.contains(buttonText)) {
        if (_currentNumber.contains('.') && buttonText == '.') return;
        _currentNumber += buttonText;
        _output = _currentNumber;
      } else if ('+-*/'.contains(buttonText)) {
        if (_currentNumber.isEmpty) return;
        _num1 = double.parse(_currentNumber);
        _operand = buttonText;
        _currentNumber = '';
      } else if (buttonText == 'C') {
        _output = '0';
        _currentNumber = '';
        _num1 = 0;
        _operand = '';
      } else if (buttonText == '=') {
        if (_currentNumber.isEmpty || _operand.isEmpty) return;
        final num2 = double.parse(_currentNumber);
        double result = 0;
        if (_operand == '+') result = _num1 + num2;
        if (_operand == '-') result = _num1 - num2;
        if (_operand == '*') result = _num1 * num2;
        if (_operand == '/') result = _num1 / num2;
        _output = result.toStringAsFixed(2);
        _currentNumber = _output;
        _operand = '';
      }
    });
  }

  Widget _buildButton(String buttonText, {Color? color}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(20),
            backgroundColor: color,
          ),
          onPressed: () => _buttonPressed(buttonText),
          child: Text(
            buttonText,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Calculator'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
              child: Text(
                _output,
                style: const TextStyle(
                  fontSize: 48,
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
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(double.tryParse(_output) ?? 0.0);
          },
          child: const Text('Use Value'),
        ),
      ],
    );
  }
}
