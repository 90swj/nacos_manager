import 'package:flutter/material.dart';  
import 'package:code_text_field/code_text_field.dart';  
import 'package:flutter_highlight/themes/atom-one-dark.dart';  
import 'package:highlight/languages/yaml.dart';  
import 'package:highlight/languages/json.dart';  
import 'package:highlight/languages/xml.dart';  
import 'package:highlight/languages/ini.dart'; // Properties 使用 ini 解析  
  
class ConfigEditor extends StatefulWidget {  
  final String initialContent;  
  final String configType; // yaml, properties, json, etc.  
  final bool readOnly;  
  final Function(String)? onChanged;  
  
  const ConfigEditor({  
    super.key,  
    required this.initialContent,  
    this.configType = 'text',  
    this.readOnly = false,  
    this.onChanged,  
  });  
  
  @override  
  _ConfigEditorState createState() => _ConfigEditorState();  
}  
  
class _ConfigEditorState extends State<ConfigEditor> {  
  late CodeController _codeController;  
  
  @override  
  void initState() {  
    super.initState();  
    _codeController = CodeController(  
      text: widget.initialContent,  
      language: _getLanguage(widget.configType),  
    );  
      
    if (widget.onChanged != null) {  
      _codeController.addListener(() {  
        widget.onChanged!(_codeController.text);  
      });  
    }  
  }  
  
  dynamic _getLanguage(String type) {  
    switch (type.toLowerCase()) {  
      case 'yaml': return yaml;  
      case 'json': return json;  
      case 'xml': return xml;  
      case 'properties': return ini;   
      default: return null;  
    }  
  }  
  
  @override  
  void dispose() {  
    _codeController.dispose();  
    super.dispose();  
  }  
  
  @override  
  Widget build(BuildContext context) {  
    return CodeTheme(  
      data: CodeThemeData(styles: atomOneDarkTheme),  
      child: Container(  
        color: Color(0xFF282c34), // 深色背景  
        child: CodeField(  
          controller: _codeController,  
          enabled: !widget.readOnly,  
          textStyle: TextStyle(fontFamily: 'monospace', fontSize: 14),  
          expands: true, // 撑满父容器  
          wrap: true,    // 自动换行  
          lineNumberStyle: LineNumberStyle(  
            width: 50,  
            margin: 5,  
            textStyle: TextStyle(color: Colors.grey),  
          ),  
        ),  
      ),  
    );  
  }  
}  
