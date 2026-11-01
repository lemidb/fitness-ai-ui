enum WeightUnit { kg, lb }

const kgToLb = 2.2046226218;

double kgToDisplay(double kg, WeightUnit unit) {
  return unit == WeightUnit.kg ? kg : kg * kgToLb;
}

double displayToKg(double display, WeightUnit unit) {
  return unit == WeightUnit.kg ? display : display / kgToLb;
}

String unitLabel(WeightUnit unit) => unit == WeightUnit.kg ? 'kg' : 'lb';
