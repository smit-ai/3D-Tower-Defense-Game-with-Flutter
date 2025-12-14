import 'dart:ui';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/resources.dart';

enum EnemyType {
  standard,
  fast,
  heavy,
}

class Enemy extends MeshComponent {
  final Vector3 targetPosition;
  late double speed;
  final EnemyType type;

  Enemy({
    required Vector3 position,
    required this.targetPosition,
    this.type = EnemyType.standard,
  }) : super(position: position, mesh: _meshForType(type)) {
    speed = _speedForType(type);
  }

  static Mesh _meshForType(EnemyType type) {
    switch (type) {
      case EnemyType.standard:
        return CuboidMesh(
          size: Vector3(0.8, 0.8, 0.8),
          material: SpatialMaterial(
            albedoColor: const Color(0xFFFF0000), // Red
            metallic: 0.5,
          ),
        );
      case EnemyType.fast:
        return CuboidMesh(
          size: Vector3(0.5, 0.5, 0.5),
          material: SpatialMaterial(
            albedoColor: const Color(0xFFFFFF00), // Yellow
            metallic: 0.5,
          ),
        );
      case EnemyType.heavy:
        return CuboidMesh(
          size: Vector3(1.2, 1.2, 1.2),
          material: SpatialMaterial(
            albedoColor: const Color(0xFF800080), // Purple
            metallic: 0.5,
          ),
        );
    }
  }

  static double _speedForType(EnemyType type) {
    switch (type) {
      case EnemyType.standard:
        return 3.0;
      case EnemyType.fast:
        return 5.0;
      case EnemyType.heavy:
        return 1.5;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move towards target
    final direction = targetPosition - position;
    direction.y = 0; // Keep movement on the ground plane

    if (direction.length > 0.1) {
      direction.normalize();
      position.add(direction * speed * dt);

      // Also look at target
      _lookAt(targetPosition);
    } else {
      // Reached target (Game Over or Damage logic later)
      removeFromParent();
    }
  }

  void _lookAt(Vector3 target) {
    final forward = (position - target)..normalize();
    if (forward.length2 < 0.0001 || (forward.x == 0 && forward.z == 0)) return;

    final up = Vector3(0, 1, 0);
    final right = up.cross(forward)..normalize();
    final realUp = forward.cross(right)..normalize();

    final rotMat = Matrix3(
      right.x, realUp.x, forward.x,
      right.y, realUp.y, forward.y,
      right.z, realUp.z, forward.z,
    );

    transform.rotation = Quaternion.fromRotation(rotMat);
  }
}
