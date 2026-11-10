import 'package:flutter/foundation.dart';

/// Oyun tahtasındaki tek bir hücrenin değişmez (immutable) veri modeli.
@immutable
class CellModel {
  const CellModel({
    required this.row,
    required this.col,
    this.isMine = false,
    this.isRevealed = false,
    this.isFlagged = false,
    this.isExploded = false,
    this.neighborMines = 0,
  });

  final int row;
  final int col;
  final bool isMine;
  final bool isRevealed;
  final bool isFlagged;

  /// Oyuncunun basarak patlattığı spesifik mayını vurgular.
  final bool isExploded;
  final int neighborMines;

  /// Eski kodlardaki mantığın aksine immutable kopya döndürür.
  CellModel copyWith({
    bool? isMine,
    bool? isRevealed,
    bool? isFlagged,
    bool? isExploded,
    int? neighborMines,
  }) {
    return CellModel(
      row: row,
      col: col,
      isMine: isMine ?? this.isMine,
      isRevealed: isRevealed ?? this.isRevealed,
      isFlagged: isFlagged ?? this.isFlagged,
      isExploded: isExploded ?? this.isExploded,
      neighborMines: neighborMines ?? this.neighborMines,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CellModel &&
        other.row == row &&
        other.col == col &&
        other.isMine == isMine &&
        other.isRevealed == isRevealed &&
        other.isFlagged == isFlagged &&
        other.isExploded == isExploded &&
        other.neighborMines == neighborMines;
  }

  @override
  int get hashCode => Object.hash(
        row,
        col,
        isMine,
        isRevealed,
        isFlagged,
        isExploded,
        neighborMines,
      );
}

