/// Quantities are stored as REAL and rounded to [quantityDecimals] places on
/// every write, so a reserve/release cycle puts stock back exactly where it
/// was and `Equatable` props stay stable across bloc emissions.
const quantityDecimals = 3;

const _scale = 1000.0;

/// Rounds [value] to the precision quantities are kept at. Every arithmetic
/// result that gets stored or compared goes through this.
double qty(num value) => (value * _scale).roundToDouble() / _scale;

/// Whether two quantities are the same once rounded. Stored quantities are
/// doubles, so `==` would call 0.999 and 1.0 different; this doesn't. Takes
/// [num] so a `StepperInput` callback can pass its value straight in.
bool sameQty(num a, num b) => (a - b).abs() * _scale < 0.5;
