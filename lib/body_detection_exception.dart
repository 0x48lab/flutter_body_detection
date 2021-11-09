class BodyDetectionException implements Exception {
  BodyDetectionException(this.code, this.description);

  String code;

  String? description;

  @override
  String toString() => 'BodyDetectionException($code, $description)';
}
