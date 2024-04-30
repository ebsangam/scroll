import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int counter = 1;
  late List<int> newMessages = [];
  late List<int> oldMessages = [counter];
  final centerKey = const ValueKey('bottom-sliver-list');
  final controller = ScrollController();
  bool atEndCached = false;
  bool userInteracting = false;
  final bool onlyAddToNewMessage = true;

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      print('MinScrollExtent: ${controller.position.minScrollExtent}');
      print('MaxScrollExtent: ${controller.position.maxScrollExtent}');
      print('Pixels: ${controller.position.pixels}');
      print('UserInteracting: $userInteracting');
      print('UserInteracting: $userInteracting');

      // if (controller.position.pixels == controller.position.minScrollExtent &&
      //     !userInteracting) {
      //   setState(() {
      //     print('atEnd');
      //     print(controller.position.maxScrollExtent);
      //     oldMessages.insertAll(0, newMessages.reversed);
      //     newMessages = [];
      //   });
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Press on the plus to add items above and below'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                oldMessages.addAll(List.generate(10, (index) => index));
              });
            },
            icon: const Icon(Icons.pages),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          setState(() {
            ++counter;
            final latestMessageIsVisible = (controller.position.pixels -
                        controller.position.minScrollExtent)
                    .abs() <=
                100;

            final isScrollable = controller.position.maxScrollExtent -
                    controller.position.minScrollExtent <=
                0;

            if (isScrollable && !onlyAddToNewMessage) {
              oldMessages.insert(0, counter);
            } else {
              newMessages.add(counter);

              if (latestMessageIsVisible) {
                SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                  controller.animateTo(controller.position.minScrollExtent,
                      duration: Durations.medium1, curve: Curves.ease);
                });
              }
            }
          });
        },
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          userInteracting = true;
        },
        onPanEnd: (details) {
          userInteracting = false;
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: controller,
          reverse: true,
          center: centerKey,
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Container(
                    alignment: Alignment.center,
                    color: Colors.blue[200 + newMessages[index] % 4 * 100],
                    height: 100 + newMessages[index] % 4 * 20.0,
                    child: Text('Item: ${newMessages[index]}'),
                  );
                },
                childCount: newMessages.length,
              ),
            ),
            SliverList(
              key: centerKey,
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Container(
                    alignment: Alignment.center,
                    color: Colors.blue[200 + oldMessages[index] % 4 * 100],
                    height: 100 + oldMessages[index] % 4 * 20.0,
                    child: Text('Item: ${oldMessages[index]}'),
                  );
                },
                childCount: oldMessages.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
