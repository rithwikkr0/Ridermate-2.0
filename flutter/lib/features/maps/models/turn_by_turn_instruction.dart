enum TurnDirection { straight, turnLeft, turnRight, uTurn, exitRoundabout }

class TurnByTurnInstruction {
  final String instructionText;
  final double distanceMeters;
  final TurnDirection direction;
  final String iconName;

  const TurnByTurnInstruction({
    required this.instructionText,
    required this.distanceMeters,
    required this.direction,
    required this.iconName,
  });
}
