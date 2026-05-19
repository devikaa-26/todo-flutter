import 'package:flutter/material.dart';

import '../services/ai_service.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() =>
      _AIAssistantScreenState();
}

class _AIAssistantScreenState
    extends State<AIAssistantScreen> {

  final TextEditingController taskController =
      TextEditingController();

  List<String> subtasks = [];

  bool isLoading = false;

  Future<void> generateSubtasks() async {

    if (taskController.text.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {

      final result =
          await AIService.generateSubtasks(
        taskController.text,
      );

      setState(() {
        subtasks = result;
      });

    } catch (e) {

      print(e);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Failed to generate subtasks",
          ),
        ),
      );

    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "AI Smart Planner",
        ),
      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            TextField(

              controller: taskController,

              decoration: InputDecoration(
                hintText: "Enter your task",
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(

              width: double.infinity,
              height: 55,

              child: ElevatedButton(

                onPressed:
                    isLoading
                        ? null
                        : generateSubtasks,

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.deepPurple,
                ),

                child:
                    isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            "Generate AI Subtasks",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(

              child: ListView.builder(

                itemCount: subtasks.length,

                itemBuilder: (context, index) {

                  return Card(

                    child: ListTile(

                      leading: const Icon(
                        Icons.auto_awesome,
                        color: Colors.deepPurple,
                      ),

                      title: Text(
                        subtasks[index],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}