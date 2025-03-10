import 'package:flutter/material.dart';
import '../models/qa_pair.dart';

class QAPairForm extends StatefulWidget {
  final QAPair? initialQAPair;
  final Function(QAPair) onSave;
  
  const QAPairForm({
    Key? key,
    this.initialQAPair,
    required this.onSave,
  }) : super(key: key);
  
  @override
  State<QAPairForm> createState() => _QAPairFormState();
}

class _QAPairFormState extends State<QAPairForm> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  final _tagsController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    if (widget.initialQAPair != null) {
      _questionController.text = widget.initialQAPair!.question;
      _answerController.text = widget.initialQAPair!.answer;
      _tagsController.text = widget.initialQAPair!.tags.join(', ');
    }
  }
  
  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
  
  void _saveQAPair() {
    if (_formKey.currentState!.validate()) {
      final tags = _tagsController.text.isEmpty
          ? <String>[]
          : _tagsController.text.split(',').map((tag) => tag.trim()).toList();
      
      final qaPair = widget.initialQAPair != null
          ? widget.initialQAPair!.copyWith(
              question: _questionController.text,
              answer: _answerController.text,
              tags: tags,
              updatedAt: DateTime.now(),
            )
          : QAPair(
              question: _questionController.text,
              answer: _answerController.text,
              tags: tags,
            );
      
      widget.onSave(qaPair);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _questionController,
            decoration: const InputDecoration(
              labelText: 'Question',
              hintText: 'Enter the question',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a question';
              }
              return null;
            },
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _answerController,
            decoration: const InputDecoration(
              labelText: 'Answer',
              hintText: 'Enter the answer (Markdown supported)',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an answer';
              }
              return null;
            },
            maxLines: 10,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _tagsController,
            decoration: const InputDecoration(
              labelText: 'Tags (optional)',
              hintText: 'Enter tags separated by commas',
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _saveQAPair,
                child: Text(widget.initialQAPair != null ? 'Update' : 'Create'),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 