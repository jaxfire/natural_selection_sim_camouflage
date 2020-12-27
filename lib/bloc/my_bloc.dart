import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:natural_selection_colour_camo/Creature.dart';

import 'bloc.dart';

class MyBloc implements Bloc {
  List<Creature> creatures = List<Creature>();

  int _numOfCreatures;

  Color background1 = Colors.black;
  Color background2 = Colors.white;
  double lerpValue = 0.0;
  double lerpStep = 0.1;
  Color currentBackgroundColor = Colors.black;

  double predatorPercentCull = 0.25;
  double randomPercentCull = 0.25;

  MyBloc(int numOfCreatures) {
    _numOfCreatures = numOfCreatures;

    for (int i = 0; i < _numOfCreatures; i++) {
      creatures.add(
        Creature(
          colour: Color(
            Random().nextInt(0xffffffff),
          ),
        ),
      );
    }
  }
  final _creatureController = StreamController<List<Creature>>();
  final _backgroundController = StreamController<Color>();

  // OUTPUT
  Stream<List<Creature>> get creatureStream => _creatureController.stream;
  Stream<Color> get backgroundStream => _backgroundController.stream;

  // INPUT
  void nextGeneration() {
    // Generate fitness value

    creatures.forEach((it) {
      calcFitnessScore(it);
    });

    _creatureController.sink.add(creatures);

    // Culling
    // Worst 25% Eaten
    predatorsCull();

    // Then, Random 25% Die of bad luck
    randomCull();

    // Mating
    // Mating is random until population size is back to 100
    // Survivors mix colours 50/50

    // Set the next background colour
    currentBackgroundColor = generateNextBackgroundColour();
    _backgroundController.sink.add(currentBackgroundColor);
  }

  void calcFitnessScore(Creature it) {
    int redDiff = (it.colour.red - currentBackgroundColor.red).abs();
    int greenDiff = (it.colour.green - currentBackgroundColor.green).abs();
    int blueDiff = (it.colour.blue - currentBackgroundColor.blue).abs();

    double avgDiff = (redDiff + greenDiff + blueDiff) / 3.0;

    it.fitnessScore = FitnessScore(score: avgDiff);
  }

  @override
  void dispose() {
    _creatureController.close();
    _backgroundController.close();
  }

  Color generateNextBackgroundColour() {
    if (lerpValue > 1.0 || lerpValue < 0) {
      lerpStep *= -1;
    }
    lerpValue += lerpStep;
    return Color.lerp(background1, background2, lerpValue);
  }

  void predatorsCull() {
    creatures
        .sort((a, b) => b.fitnessScore.score.compareTo(a.fitnessScore.score));
    int numEaten = (creatures.length * predatorPercentCull).toInt();
    creatures = creatures.getRange(numEaten, creatures.length).toList();
  }

  void randomCull() {
    int numToBeCulled = (_numOfCreatures * randomPercentCull).toInt();
    print(numToBeCulled);
    int numCulled = 0;
    while (numCulled < numToBeCulled) {
      creatures.remove(Random().nextInt(creatures.length));
      numCulled++;
    }
  }
}

class FitnessScore {
  double score;
  FitnessScore({this.score});
}
