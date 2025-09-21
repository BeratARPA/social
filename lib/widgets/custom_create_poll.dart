import 'package:flutter/material.dart';

class CustomCreatePoll extends StatefulWidget {
  final Function(Map<String, dynamic> pollData)? onCreated;

  const CustomCreatePoll({super.key, this.onCreated});

  @override
  State<CustomCreatePoll> createState() => _CustomCreatePollState();
}

class _CustomCreatePollState extends State<CustomCreatePoll> {
  final TextEditingController questionController = TextEditingController();
  final List<TextEditingController> optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Anket Oluştur"),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: questionController,
              decoration: InputDecoration(labelText: 'Anket Sorusu'),
            ),
            const SizedBox(height: 8),
            Text("Seçenekler"),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: optionControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: TextField(
                      controller: optionControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Seçenek ${index + 1}',
                        suffixIcon:
                            index >= 2
                                ? IconButton(
                                  icon: Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      optionControllers.removeAt(index);
                                    });
                                  },
                                )
                                : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            if (optionControllers.length < 5)
              TextButton.icon(
                icon: Icon(Icons.add),
                label: Text('Seçenek Ekle'),
                onPressed: () {
                  setState(() {
                    optionControllers.add(TextEditingController());
                  });
                },
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Kapat"),
        ),
        TextButton(
          onPressed: () {
            if (questionController.text.trim().isEmpty ||
                optionControllers.any(
                  (controller) => controller.text.trim().isEmpty,
                ) ||
                optionControllers.length < 2) {
              return;
            }
            Navigator.pop(context);
            if (widget.onCreated != null) {
              widget.onCreated!({
                'question': questionController.text.trim(),
                'options':
                    optionControllers
                        .map((controller) => controller.text.trim())
                        .toList(),
                'votes': List.filled(optionControllers.length, 0),
              });
            }
          },
          child: Text("Oluştur"),
        ),
      ],
    );
  }
}
