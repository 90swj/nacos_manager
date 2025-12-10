// tags_input.dart (或者直接放在 ConfigEditorPage 文件底部)  
import 'package:flutter/material.dart';  
  
class TagInput extends StatefulWidget {  
  final List<String> tags;  
  final ValueChanged<List<String>> onChanged;  
  final String label;  
  
  const TagInput({  
    super.key,  
    required this.tags,  
    required this.onChanged,  
    this.label = "Tags",  
  });  
  
  @override  
  State<TagInput> createState() => _TagInputState();  
}  
  
class _TagInputState extends State<TagInput> {  
  final TextEditingController _controller = TextEditingController();  
  
  void _addTag() {  
    final val = _controller.text.trim();  
    if (val.isNotEmpty && !widget.tags.contains(val)) {  
      // 创建新列表以触发更新  
      final newTags = List<String>.from(widget.tags)..add(val);  
      widget.onChanged(newTags);  
      _controller.clear();  
    } else {  
      _controller.clear();  
    }  
  }  
  
  void _removeTag(String tag) {  
    final newTags = List<String>.from(widget.tags)..remove(tag);  
    widget.onChanged(newTags);  
  }  
  
  @override  
  void dispose() {  
    _controller.dispose();  
    super.dispose();  
  }  
  
  @override  
  Widget build(BuildContext context) {  
    return Column(  
      crossAxisAlignment: CrossAxisAlignment.start,  
      children: [  
        // 1. 标题 (参考代码样式)  
        Text(widget.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),  
        const SizedBox(height: 8),  
          
        // 2. 标签展示区域 (Wrap + Chip)  
        if (widget.tags.isNotEmpty)  
          Padding(  
            padding: const EdgeInsets.only(bottom: 8.0),  
            child: Wrap(  
              spacing: 8.0,  
              runSpacing: 4.0,  
              children: widget.tags.map((tag) {  
                return Chip(  
                  label: Text(tag),  
                  onDeleted: () => _removeTag(tag),  
                  backgroundColor: Colors.blue.withOpacity(0.1),  
                  labelStyle: TextStyle(color: Colors.blue[800]),  
                  deleteIconColor: Colors.blue[800],  
                );  
              }).toList(),  
            ),  
          ),  
  
        // 3. 输入框 (完全一致的 Decoration)  
        TextField(  
          controller: _controller,  
          decoration: InputDecoration(  
            hintText: "输入标签后按回车",  
            border: const OutlineInputBorder(),  
            contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),  
            suffixIcon: IconButton(  
              icon: const Icon(Icons.add),  
              onPressed: _addTag,  
            ),  
          ),  
          onSubmitted: (_) => _addTag(),  
        ),  
      ],  
    );  
  }  
}  
