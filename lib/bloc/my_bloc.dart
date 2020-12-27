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
  double lerpStep = 0.0025;
  Color currentBackgroundColor = Colors.black;
  int timeStepMillis = 150;

  double predatorPercentCull = 0.25;
  double randomPercentCull = 0.25;

  MyBloc() {
    _numOfCreatures = 200;

    for (int i = 0; i < _numOfCreatures; i++) {
      int brightness = Random().nextInt(255);
      creatures.add(
        Creature(
          colour: Color.fromARGB(255, brightness, brightness, brightness),
        ),
      );
    }

    Timer.periodic(Duration(milliseconds: timeStepMillis), (timer) {
      nextGeneration();
    });
  }

  final _creatureController = StreamController<List<Creature>>();
  final _backgroundController = StreamController<Color>();
  final _colourDiffController = StreamController<String>();

  // OUTPUT
  Stream<List<Creature>> get creatureStream => _creatureController.stream;
  Stream<Color> get backgroundStream => _backgroundController.stream;
  Stream<String> get colourDiffStream => _colourDiffController.stream;

  // INPUT
  void nextGeneration() {
    // Generate fitness value

    creatures.forEach((it) {
      calcFitnessScore(it);
    });

    // Culling
    // Worst 25% Eaten
    predatorsCull();

    // Then, Random 25% Die of bad luck
    randomCull();

    // Mating
    // Mating is random until population size is back to 100
    // Survivors mix colours 50/50
    mate();

    creatures.shuffle();
    _creatureController.sink.add(creatures);

    // Set the next background colour
    currentBackgroundColor = generateNextBackgroundColour();
    _backgroundController.sink.add(currentBackgroundColor);

    _colourDiffController.sink.add(
        'Avg. Colour Diff: ${(averageBrightness() - currentBackgroundColor.red).abs()}');
  }

  void calcFitnessScore(Creature it) {
    int brightnessDiff = (it.colour.red - currentBackgroundColor.red).abs();

    it.fitnessScore = FitnessScore(score: brightnessDiff);
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
    int numCulled = 0;
    while (numCulled < numToBeCulled) {
      creatures.remove(Random().nextInt(creatures.length));
      numCulled++;
    }
  }

  void mate() {
    int requiredOffSpring = _numOfCreatures - creatures.length;
    for (int i = 0; i < requiredOffSpring; i++) {
      Creature mateA = creatures[Random().nextInt(creatures.length)];
      Creature mateB = creatures[Random().nextInt(creatures.length)];
      Creature offspring = reproduce(mateA, mateB);
      creatures.add(offspring);
    }
  }

  Creature reproduce(Creature mateA, Creature mateB) {
    Color colour =
        Color.lerp(mateA.colour, mateB.colour, Random().nextDouble());

    // Random brightness mutation
    if (Random().nextDouble() > 0.9) {
      int adjustmentAmount = Random().nextInt(25);
      if (Random().nextDouble() > 0.5) {
        adjustmentAmount *= -1;
      }
      if (colour.red + adjustmentAmount > 255 ||
          colour.red - adjustmentAmount < 0) {
        adjustmentAmount *= -1;
      }
      colour = colour.withRed(colour.red + adjustmentAmount);
      colour = colour.withGreen(colour.green + adjustmentAmount);
      colour = colour.withBlue(colour.blue + adjustmentAmount);
    }

    return Creature(colour: colour);
  }

  int averageBrightness() {
    int redTotal = 0;
    int greenTotal = 0;
    int blueTotal = 0;

    creatures.forEach((it) {
      redTotal += it.colour.red;
      greenTotal += it.colour.green;
      blueTotal += it.colour.blue;
    });

    return (redTotal ~/ creatures.length +
            greenTotal ~/ creatures.length +
            blueTotal ~/ creatures.length) ~/
        3;
  }
}

class FitnessScore {
  int score;
  FitnessScore({this.score});
}
