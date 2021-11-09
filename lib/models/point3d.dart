class Point3d {
  final double x;
  final double y;
  final double z;

  Point3d({required this.x, required this.y, required this.z});

  factory Point3d.fromMap(Map<Object?, Object?> map) {
    return Point3d(
      x: map['x'] as double,
      y: map['y'] as double,
      z: map['z'] as double,
    );
  }
}
