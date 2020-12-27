import 'dart:math';

import 'package:flutter/material.dart';
import 'package:natural_selection_colour_camo/bloc/my_bloc.dart';

import '../Creature.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  final MyBloc myBloc = MyBloc();

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Color backgroundColour = Colors.white;

  @override
  void dispose() {
    widget.myBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.myBloc.backgroundStream,
      builder: (context, snapshot) {
        return Scaffold(
          backgroundColor: snapshot.data,
          body: SafeArea(
            child: StreamBuilder<List<Creature>>(
              stream: widget.myBloc.creatureStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 10,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, i) {
                              return Container(
                                color: snapshot.data[i].colour,
                              );
                            },
                          ),
                        ),
                      ),
                      StreamBuilder<String>(
                          stream: widget.myBloc.colourDiffStream,
                          builder: (context, snapshot) {
                            String text = '';
                            if (snapshot.hasData) {
                              text = snapshot.data;
                            }
                            return Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Text(
                                  text,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                  ),
                                ),
                              ),
                            );
                          }),
                    ],
                  );
                } else {
                  return Stack(children: [
                    Center(
                      child: Text('No Data'),
                    ),
                  ]);
                }
              },
            ),
          ),
        );
      },
    );
  }
}
