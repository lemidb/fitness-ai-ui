import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IntStepper extends StatelessWidget {
  const IntStepper({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1000,
    this.step = 1,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final int step;

  @override
  Widget build(BuildContext context) {
    return _StepperFrame(
      label: label,
      onMinus: () => onChanged((value - step).clamp(min, max)),
      onPlus: () => onChanged((value + step).clamp(min, max)),
      minusLabel: '-$step',
      child: Text('$value', style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class WeightField extends StatefulWidget {
  const WeightField({
    super.key,
    required this.value,
    required this.onChanged,
    this.step = 2.5,
    this.min = 0,
    this.max = 1000,
    this.unitLabel = 'kg',
  });

  final double value;
  final ValueChanged<double> onChanged;
  final double step;
  final double min;
  final double max;
  final String unitLabel;

  @override
  State<WeightField> createState() => _WeightFieldState();
}

class _WeightFieldState extends State<WeightField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.value));
  }

  @override
  void didUpdateWidget(covariant WeightField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final formatted = _format(widget.value);
    if (_controller.text != formatted && !_controller.value.composing.isValid) {
      _controller.text = formatted;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _format(double value) {
    return value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return _StepperFrame(
      label: widget.unitLabel,
      minusLabel: '-${widget.step}',
      plusLabel: '+${widget.step}',
      onMinus: () => widget.onChanged((widget.value - widget.step).clamp(widget.min, widget.max)),
      onPlus: () => widget.onChanged((widget.value + widget.step).clamp(widget.min, widget.max)),
      child: SizedBox(
        width: 72,
        child: TextField(
          controller: _controller,
          textAlign: TextAlign.center,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
          onSubmitted: (text) {
            final parsed = double.tryParse(text);
            if (parsed != null) {
              widget.onChanged(parsed.clamp(widget.min, widget.max));
            }
          },
        ),
      ),
    );
  }
}

class _StepperFrame extends StatelessWidget {
  const _StepperFrame({
    required this.label,
    required this.onMinus,
    required this.onPlus,
    required this.child,
    this.minusLabel = '-',
    this.plusLabel = '+',
  });

  final String label;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final Widget child;
  final String minusLabel;
  final String plusLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 4),
        Row(
          children: [
            IconButton.filledTonal(
              onPressed: onMinus,
              icon: Text(minusLabel, style: const TextStyle(fontSize: 11)),
              style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
            ),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: child),
            IconButton.filledTonal(
              onPressed: onPlus,
              icon: Text(plusLabel, style: const TextStyle(fontSize: 11)),
              style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
            ),
          ],
        ),
      ],
    );
  }
}
