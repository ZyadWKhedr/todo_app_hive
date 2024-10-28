import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import '../widgets/button.dart';
import '../constants.dart';
import '../models/task.dart';
import '../widgets/text_field.dart';
import 'menu.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _titleFormKey = GlobalKey<FormState>();
  final _descriptionFormKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool isEditing = false;

  void showAddTaskBottomSheet({int? index, required Box<Task> box}) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Transform.translate(
            offset:
                Offset(0.0, -0.5 * MediaQuery.of(context).viewInsets.bottom),
            child: BottomSheet(
              enableDrag: false,
              onClosing: () {},
              builder: (context) {
                return SizedBox(
                  height: 600,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        isEditing ? 'Edit Task' : 'Add Task',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 5),
                      const Divider(thickness: 1.5),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            Text(
                              'Title',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 10),
                            AppTextField(
                              contoller: titleController,
                              validatorText: 'Please enter the title',
                              formKey: _titleFormKey,
                              hintText: 'task title',
                            ),
                            const SizedBox(height: 30),
                            Text(
                              'Description',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 10),
                            AppTextField(
                              formKey: _descriptionFormKey,
                              hintText: 'task description',
                              validatorText: '',
                              contoller: descriptionController,
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      AppButton(
                        buttonText: isEditing ? 'Edit' : 'Add',
                        onPressed: () {
                          if (_titleFormKey.currentState!.validate()) {
                            Box<Task> taskBox = Hive.box<Task>('tasksBox');
                            if (isEditing) {
                              taskBox.putAt(
                                index!,
                                Task(
                                  title: titleController.text,
                                  description: descriptionController.text,
                                  isCompleted: box.getAt(index)!.isCompleted,
                                  dateTime: box.getAt(index)!.dateTime,
                                ),
                              );
                            } else {
                              taskBox.add(Task(
                                title: titleController.text,
                                description: descriptionController.text,
                                dateTime: DateTime.now(),
                              ));
                            }
                            Navigator.pop(context);
                          }
                        },
                      ),
                      const Spacer()
                    ],
                  ),
                );
              },
            ),
          );
        });
  }

  void undoChange(Box<Task> box, dynamic obj, int index) {
    box.putAt(index, obj);
  }

  int countDoneTasks(Box<Task> box) {
    int doneTasks = 0;
    for (var item in box.values) {
      if (item.isCompleted) {
        doneTasks++;
      }
    }
    return doneTasks;
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Task>('tasksBox').listenable(),
        builder: (context, Box<Task> box, _) {
          if (box.isEmpty) {
            return FadeIn(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: LottieBuilder.asset(
                        'assets/lottie/Animation - 1729412520632.json',
                      ),
                    ),
                    Text(
                      'Nothing to do...',
                      style: textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            );
          }
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: FadeInUp(
                from: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor:
                              Colors.blue, 
                          radius: 6,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'To do',
                          style: textTheme.headlineSmall,
                        ),
                        const Spacer(),
                        Text(
                          box.values.length == 1
                              ? '${countDoneTasks(box)} of ${box.values.length} task'
                              : '${countDoneTasks(box)} of ${box.values.length} tasks',
                        ),
                        const SizedBox(width: 20),
                        CircularProgressIndicator(
                          value: countDoneTasks(box) / box.values.length,
                          color:
                              Colors.blue, 
                          backgroundColor: Colors.grey,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SizedBox(
                        height: double.infinity,
                        child: ListView.builder(
                          itemCount: box.values.length,
                          itemBuilder: (context, index) {
                            Task? task = box.getAt(index);

                            if (MenuPage.deletePrevousDay) {
                              for (var element in box.values.toList()) {
                                if (element.dateTime.day !=
                                    DateTime.now().day) {
                                  task!.delete();
                                }
                              }
                            }

                            return Dismissible(
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.transparent,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 10),
                                    const Text('Task deleted!'),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () {
                                        undoChange(box, task, index);
                                      },
                                      style: TextButton.styleFrom(
                                        side: const BorderSide(width: 1),
                                      ),
                                      child: const Text(
                                        'Undo',
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              resizeDuration:
                                  const Duration(milliseconds: 2300),
                              key: UniqueKey(),
                              onDismissed: (direction) {
                                task.delete();
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 10,
                                        offset: Offset(0, 7),
                                      ),
                                    ],
                                  ),
                                  child: Card(
                                    color: Theme.of(context).cardColor,
                                    elevation: 0,
                                    child: ListTile(
                                      title: Text(
                                        task!.title,
                                        style: task.isCompleted
                                            ? textTheme.titleMedium!.copyWith(
                                                color: Colors.blue,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                              )
                                            : textTheme.titleMedium,
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            task.description,
                                            style: textTheme.bodyMedium,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Due: ${DateFormat('yyyy-MM-dd').format(task.dateTime)} ${DateFormat('jm').format(task.dateTime)}',
                                            style:
                                                textTheme.bodyMedium!.copyWith(
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                      leading: IconButton(
                                        icon: task.isCompleted
                                            ? const Icon(Icons.check_circle,
                                                color: Colors.blue)
                                            : const Icon(Icons.circle_outlined),
                                        onPressed: () {
                                          task.isCompleted = !task.isCompleted;
                                          task.save();
                                        },
                                      ),
                                      onTap: () {
                                        setState(() {
                                          isEditing = true;
                                          titleController.text = task.title;
                                          descriptionController.text =
                                              task.description;
                                        });
                                        showAddTaskBottomSheet(
                                            box: box, index: index);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20, right: 10),
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              isEditing = false;
              titleController.text = '';
              descriptionController.text = '';
            });
            showAddTaskBottomSheet(box: Hive.box<Task>('tasksBox'));
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
