import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';
import 'package:highlight/languages/yaml.dart';
import 'package:highlight/languages/json.dart';
import 'package:highlight/languages/xml.dart';
import 'package:highlight/languages/properties.dart';
import 'package:highlight/languages/ini.dart'; // for TOML rough support
import '../models/nacos_models.dart';
import '../providers/app_provider.dart';
import '../l10n/app_localizations.dart'; 

// 文件类型对应的颜色映射
Map<String, Color> fileTypeColors = {
  'yaml': Colors.blue,
  'json': Colors.purple,
  'xml': Colors.orange,
  'properties': Colors.green,
  'text': Colors.grey,
  'html': Colors.red,
  'toml': Colors.pink,
};

// 获取文件类型对应的颜色
Color getFileTypeColor(String type) {
  return fileTypeColors[type] ?? Colors.grey; // 默认灰色
}

// 文件类型颜色标签组件
Widget FileTypeTag(String type) {
  Color bgColor = getFileTypeColor(type);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: bgColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: bgColor),
    ),
    child: Text(
      type.toUpperCase(),
      style: TextStyle(
        color: bgColor,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

// --- 配置列表页 ---
class ConfigListPage extends StatefulWidget {
  const ConfigListPage({super.key});
  @override
  State<ConfigListPage> createState() => _ConfigListPageState();
}

class _ConfigListPageState extends State<ConfigListPage> {
  List<NacosConfig> configs = [];
  bool loading = false;

  // 用于记录上一次的命名空间ID，用于自动刷新判断
  String? _lastNamespaceId;

  String? searchDataId;
  String? searchGroup;
  List<String> searchTags = [];
  String? searchApp;
  List<String> searchType = [];
  String? searchContent;

  // 缓存AppProvider引用，避免在dispose或异步回调中访问context
  late AppProvider _appProvider;

  // 标记是否已初始化完成
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    // 缓存provider引用
    _appProvider = context.read<AppProvider>();

    // 1. 初始加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _lastNamespaceId = _appProvider.currentNamespaceId; // 记录初始ID
      _loadConfigs();
    });

    // 2. 添加监听器：当 Provider 通知变化时，检查 Namespace 是否改变
    _appProvider.addListener(_onProviderUpdate);

    // 标记初始化完成
    _isInitialized = true;
  }

  @override
  void dispose() {
    // 安全地移除监听，使用缓存的provider引用
    _appProvider.removeListener(_onProviderUpdate);
    super.dispose();
  }

  // 监听回调：实现切换命名空间自动刷新
  void _onProviderUpdate() {
    // 首先检查widget是否已挂载以及是否初始化完成
    if (!mounted || !_isInitialized) return;

    try {
      final newNamespaceId = _appProvider.currentNamespaceId;

      // 只有当命名空间真的变了，才重新请求网络
      if (newNamespaceId != _lastNamespaceId) {
        _lastNamespaceId = newNamespaceId;

        // 再次检查是否已挂载，确保在执行setState前上下文仍然有效
        if (mounted) {
          setState(() {
            configs = [];
          });

          // 在执行异步操作前再次检查挂载状态
          if (mounted) {
            _loadConfigs();
          }
        }
      }
    } catch (e) {
      // 捕获任何可能的异常，防止监听器崩溃
      print('Error in _onProviderUpdate: $e');
    }
  }

  Future<void> _loadConfigs() async {
    if (!mounted) return;

    setState(() => loading = true);

    try {
      // 使用缓存的provider引用获取命名空间ID和API实例
      final namespaceId = _appProvider.currentNamespaceId;
      final api = _appProvider.api;

      // 调用API获取配置列表
      List<NacosConfig> newConfigs = await api.getConfigs(
        namespaceId,
        1,
        100,
        dataId: searchDataId?.trim() ?? '',
        group: searchGroup?.trim() ?? '',
        tags: searchTags.join(','),
        appName: searchApp?.trim() ?? '',
        type: searchType.join(','),
        content: searchContent?.trim() ?? '',
      );

      // 打印接口返回结果
      print('=== /nacos/v1/cs/configs API Response ===');
      print('NamespaceId: $namespaceId');
      print('Total Configs: ${newConfigs.length}');
      for (var config in newConfigs) {
        print('Config: ${config.dataId} (${config.group}) - Type: ${config.type}');
        print('  AppName: ${config.appName}');
        print('  Tags: ${config.tags}');
        // 不打印完整content，避免日志过长
        print('  Content Length: ${config.content?.length ?? 0}');
      }
      print('==========================================');

      if (mounted) {
        setState(() {
          configs = newConfigs;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          configs = [];
          loading = false;
        });
        Fluttertoast.showToast(msg: "${AppLocalizations.of(context)!.failedToLoadConfiguration}: $e");
      }
    }
  }

  // 可复用的标签输入组件
  Widget _tagInput(
    BuildContext context,
    List<String> initialTags,
    Function(List<String>) onTagsChanged,
    String labelText,
    {bool isEditable = true}
  ) {
    final List<String> tags = List.from(initialTags);
    final TextEditingController controller = TextEditingController();

    void updateTags() {
      onTagsChanged(tags);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: tags.map((tag) {
            return Chip(
              label: Text(tag),
              onDeleted: isEditable ? () {
                tags.remove(tag);
                updateTags();
              } : null,
              backgroundColor: Colors.blue.withOpacity(0.1),
              labelStyle: TextStyle(color: Colors.blue[800]),
              deleteIconColor: Colors.blue[800],
            );
          }).toList(),
        ),
        if (isEditable)
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "${AppLocalizations.of(context)!.inputTags}",
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  if (controller.text.trim().isNotEmpty && !tags.contains(controller.text.trim())) {
                    tags.add(controller.text.trim());
                    controller.clear();
                    updateTags();
                  }
                },
              ),
            ),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty && !tags.contains(value.trim())) {
                tags.add(value.trim());
                controller.clear();
                updateTags();
              }
            },
          ),
      ],
    );
  }

  // 文件类型多选下拉组件
  Widget _fileTypeDropdown(
    BuildContext context,
    List<String> initialTypes,
    Function(List<String>) onTypesChanged
  ) {
    final List<String> selectedTypes = List.from(initialTypes);
    final List<String> availableTypes = fileTypeColors.keys.toList();
    final GlobalKey<FormFieldState> dropdownKey = GlobalKey<FormFieldState>();

    void updateTypes(String type) {
      if (selectedTypes.contains(type)) {
        selectedTypes.remove(type);
      } else {
        selectedTypes.add(type);
      }
      onTypesChanged(selectedTypes);
      // 选择后关闭下拉列表
      if (dropdownKey.currentState != null) {
        dropdownKey.currentState!.reset();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("${AppLocalizations.of(context)!.fileType}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: selectedTypes.map((type) {
            return Chip(
              label: Text(type.toUpperCase()),
              onDeleted: () {
                selectedTypes.remove(type);
                onTypesChanged(selectedTypes);
              },
              backgroundColor: getFileTypeColor(type).withOpacity(0.1),
              labelStyle: TextStyle(color: getFileTypeColor(type)),
              deleteIconColor: getFileTypeColor(type),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              key: dropdownKey,
              isExpanded: true,
              hint: Text("${AppLocalizations.of(context)!.selectFileType}"),
              items: availableTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Row(
                    children: [
                      Checkbox(
                        value: selectedTypes.contains(type),
                        onChanged: (value) => updateTypes(type),
                      ),
                      FileTypeTag(type),
                      const SizedBox(width: 8),
                      Text(type),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) { if (value != null) updateTypes(value); },
              validator: (value) => null,
            ),
          ),
        ),
      ],
    );
  }

  void _openSearch() {
    final dCtrl = TextEditingController(text: searchDataId);
    final gCtrl = TextEditingController(text: searchGroup);
    final aCtrl = TextEditingController(text: searchApp);
    final contentCtrl = TextEditingController(text: searchContent);
    
    List<String> tempTags = List.from(searchTags);
    List<String> tempTypes = List.from(searchType);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${AppLocalizations.of(context)!.advancedQuery}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: dCtrl,
                    decoration: const InputDecoration(
                      labelText: "Data ID",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: gCtrl,
                    decoration: InputDecoration(
                      labelText: "${AppLocalizations.of(context)!.group}",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _tagInput(
                    context,
                    tempTags,
                    (tags) {
                      tempTags = tags;
                      setState(() {});
                    },
                    "${AppLocalizations.of(context)!.tags}",
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: aCtrl,
                    decoration: InputDecoration(
                      labelText: "${AppLocalizations.of(context)!.appName}",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _fileTypeDropdown(
                    context,
                    tempTypes,
                    (types) {
                      tempTypes = types;
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: contentCtrl,
                    decoration: InputDecoration(
                      labelText: "${AppLocalizations.of(context)!.fileContent}",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
                    ),
                    maxLines: 3,
                    textAlignVertical: TextAlignVertical.top,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        searchDataId = dCtrl.text;
                        searchGroup = gCtrl.text;
                        searchTags = tempTags;
                        searchApp = aCtrl.text;
                        searchType = tempTypes;
                        searchContent = contentCtrl.text;
                      });
                      _loadConfigs();
                      Navigator.pop(ctx);
                    },
                    child: Text("${AppLocalizations.of(context)!.search}"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 克隆逻辑
  void _handleClone(NacosConfig item) async {
    if (!mounted) return;
    // 缓存当前命名空间ID和item引用，防止异步操作期间状态变化
    final currentNamespaceId = _appProvider.currentNamespaceId;
    final localItem = item;

    // 注意：这里需要 try-catch 避免网络错误导致 crash
    try {
      String content = await _appProvider.api.getConfigContent(
        localItem.dataId,
        localItem.group,
        currentNamespaceId,
      );

      if (!mounted) return;
      // 选择目标命名空间
      Namespace? targetNs = await showDialog<Namespace>(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: const Text("克隆到哪个命名空间?"),
          children: _appProvider.namespaces
              .map(
                (ns) => SimpleDialogOption(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      ns.namespaceShowName.isEmpty
                          ? "${AppLocalizations.of(context)!.public}"
                          : ns.namespaceShowName,
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx, ns),
                ),
              )
              .toList(),
        ),
      );

      if (targetNs != null && mounted) {
        // 打开创建页面，带入数据，但Tenant设为目标Tenant
        NacosConfig clone = NacosConfig(
          dataId: localItem.dataId,
          group: localItem.group,
          content: content,
          type: localItem.type,
          appName: localItem.appName,
          tags: localItem.tags,
          tenant: targetNs.namespace,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ConfigEditorPage(
              config: clone,
              isCreate: true,
              targetNamespaceName: targetNs.namespaceShowName,
              heroTag: 'config_clone_button',
            ),
          ),
        ).then((v) {
          if (v == true && mounted) _loadConfigs();
        });
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(msg: "${AppLocalizations.of(context)!.failedToLoadConfiguration}: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'config_add_button',
        child: const Icon(Icons.add),
        onPressed: () =>
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ConfigEditorPage(isCreate: true),
              ),
            ).then((v) {
              if (v == true && mounted) _loadConfigs();
            }),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    searchDataId?.isNotEmpty == true
                        ? "${AppLocalizations.of(context)!.filtering}: $searchDataId"
                        : "${AppLocalizations.of(context)!.allConfigurations}",
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _openSearch,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadConfigs,
                ),
              ],
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : configs.isEmpty
                ? Center(child: Text("${AppLocalizations.of(context)!.noConfigurationsOrLoadingFailed}"))
                : ListView.builder(
                    itemCount: configs.length,
                    itemBuilder: (ctx, i) {
                      final item = configs[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ListTile(
                          title: Text(
                            item.dataId,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Row(
                            crossAxisAlignment: CrossAxisAlignment.end, // 改为底部对齐
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // 左侧部分：移除padding，使用最简单结构
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("${AppLocalizations.of(context)!.group}:${item.group}", style: TextStyle(fontSize: 12)),
                                    Text("${AppLocalizations.of(context)!.appName}:${item.appName ?? '-'}", style: TextStyle(fontSize: 12, color: Colors.grey)) 
                                  ],
                                ),
                              ),
                              // 右侧部分：减少底部padding，使整体布局更协调
                              Container(
                                padding: const EdgeInsets.only(left: 8.0, bottom: 20.0), // 调整底部内边距为20.0
                                alignment: Alignment.center,
                                child: FileTypeTag(item.type),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (op) async {
                              final state = context.read<AppProvider>();
                              // 缓存当前上下文的ID，防止await期间切换
                              final currentNamespaceId =
                                  state.currentNamespaceId;

                              if (op == 'edit') {
                                try {
                                  String content = await state.api
                                      .getConfigContent(
                                        item.dataId,
                                        item.group,
                                        currentNamespaceId,
                                      );
                                  item.content = content;
                                  if (mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ConfigEditorPage(
                                          isCreate: false,
                                          config: item,
                                          heroTag: 'config_edit_button',
                                        ),
                                      ),
                                    ).then((v) {
                                      if (v == true && mounted) _loadConfigs();
                                    });
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    Fluttertoast.showToast(msg: "${AppLocalizations.of(context)!.failedToLoadConfiguration}: $e");
                                  }
                                }
                              } else if (op == 'delete') {
                                bool confirm = await showDialog(
                                  context: context,
                                  builder: (c) => AlertDialog(
                                    title: Text("${AppLocalizations.of(context)!.confirmDeletion}?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(c, true),
                                        child: Text("${AppLocalizations.of(context)!.delete}"),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  try {
                                    bool ok = await state.api.deleteConfig(
                                      item.dataId,
                                      item.group,
                                      currentNamespaceId,
                                    );
                                    if (ok && mounted) {
                                      _loadConfigs();
                                      Fluttertoast.showToast(msg: "${AppLocalizations.of(context)!.deleteSuccess}");
                                    } else if (mounted) {
                                      Fluttertoast.showToast(msg: "${AppLocalizations.of(context)!.deleteFailed}");
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      Fluttertoast.showToast(
                                        msg: "${AppLocalizations.of(context)!.deleteDataIdFailed}: $e",
                                      );
                                    }
                                  }
                                }
                              } else if (op == 'clone') {
                                _handleClone(item);
                              } else if (op == 'export') {
                                try {
                                  String content = await state.api
                                      .getConfigContent(
                                        item.dataId,
                                        item.group,
                                        currentNamespaceId,
                                      );
                                  Clipboard.setData(
                                    ClipboardData(text: content),
                                  );
                                  if (mounted) {
                                    Fluttertoast.showToast(msg: "${AppLocalizations.of(context)!.copied}");
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    Fluttertoast.showToast(msg: "${AppLocalizations.of(context)!.exportingConfigurationFailed}: $e");
                                  }
                                }
                              }
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(value: 'edit', child: Text("${AppLocalizations.of(context)!.edit}")),
                              PopupMenuItem(value: 'clone', child: Text("${AppLocalizations.of(context)!.clone}")),
                              PopupMenuItem(
                                value: 'export',
                                child: Text("${AppLocalizations.of(context)!.export}"),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  "${AppLocalizations.of(context)!.delete}",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// --- 配置编辑器 (保持不变，逻辑是完整的) ---
class ConfigEditorPage extends StatefulWidget {
  final bool isCreate;
  final NacosConfig? config;
  final String? targetNamespaceName; // 仅用于克隆时显示的提示
  final String? heroTag; // 用于避免Hero标签冲突

  const ConfigEditorPage({
    super.key,
    required this.isCreate,
    this.config,
    this.targetNamespaceName,
    this.heroTag = 'config_editor_button',
  });

  @override
  State<ConfigEditorPage> createState() => _ConfigEditorPageState();
}

class _ConfigEditorPageState extends State<ConfigEditorPage> {
  late TextEditingController _dataIdCtrl;
  late TextEditingController _groupCtrl;
  late TextEditingController _appCtrl;
  late TextEditingController _tagsCtrl;
  late CodeController _codeController;
  String _type = "yaml";

  // 缓存AppProvider引用，避免在异步操作中访问context
  late AppProvider _appProvider;

  // 缓存命名空间ID
  late String _namespaceId;

  // 标记是否已初始化完成
  bool _isInitialized = false;

  final List<String> types = [
    "text",
    "yaml",
    "properties",
    "json",
    "xml",
    "html",
    "toml",
  ];

  @override
  void initState() {
    super.initState();
    try {
      // 缓存provider引用
      _appProvider = context.read<AppProvider>();

      // 确定命名空间ID
      _namespaceId = widget.isCreate && widget.config?.tenant != null
          ? widget
                .config!
                .tenant // 克隆的目标ID
          : _appProvider.currentNamespaceId;

      final c = widget.config;
      _dataIdCtrl = TextEditingController(text: c?.dataId);
      _groupCtrl = TextEditingController(text: c?.group ?? "DEFAULT_GROUP");
      _appCtrl = TextEditingController(text: c?.appName);
      _tagsCtrl = TextEditingController(text: c?.tags);
      _type = c?.type ?? "yaml";

      _codeController = CodeController(
        text: c?.content ?? "",
        language: _getLang(_type),
      );

      // 标记初始化完成
      _isInitialized = true;
    } catch (e) {
      print('Error in ConfigEditorPage initState: $e');
    }
  }

  @override
  void dispose() {
    // 清理所有控制器资源
    _dataIdCtrl.dispose();
    _groupCtrl.dispose();
    _appCtrl.dispose();
    _tagsCtrl.dispose();
    _codeController.dispose();
    super.dispose();
  }

  dynamic _getLang(String type) {
    switch (type) {
      case 'json':
        return json;
      case 'xml':
        return xml;
      case 'properties':
        return properties;
      case 'toml':
        return ini;
      case 'yaml':
        return yaml;
      default:
        return null; // text
    }
  }

  void _changeType(String? t) {
    setState(() {
      _type = t!;
      _codeController.language = _getLang(_type);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCreate ? "${AppLocalizations.of(context)!.addConfig}" : "${AppLocalizations.of(context)!.editConfig}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.paste),
            tooltip: "${AppLocalizations.of(context)!.import}",
            onPressed: () async {
              final data = await Clipboard.getData(Clipboard.kTextPlain);
              if (data?.text != null && mounted) {
                _codeController.text = data!.text!;
                Fluttertoast.showToast(msg: "${AppLocalizations.of(context)!.pasted}");
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              if (_dataIdCtrl.text.isEmpty || _groupCtrl.text.isEmpty) {
                if (mounted) {
                  Fluttertoast.showToast(msg: "${AppLocalizations.of(context)!.addConfigPrompt}");
                }
                return;
              }

              // 检查初始化状态，确保安全访问
              if (!_isInitialized) {
                Fluttertoast.showToast(msg: "${AppLocalizations.of(context)!.initPageFailed}");
                return;
              }

              // 使用缓存的api引用
              final api = _appProvider.api;

              NacosConfig newConfig = NacosConfig(
                dataId: _dataIdCtrl.text,
                group: _groupCtrl.text,
                content: _codeController.text,
                type: _type,
                appName: _appCtrl.text,
                tags: _tagsCtrl.text,
                tenant: _namespaceId,
              );

              try {
                bool ok = await api.publishConfig(newConfig);
                if (ok && mounted) {
                  Fluttertoast.showToast(msg: "${AppLocalizations.of(context)!.pushSuccess}");
                  Navigator.pop(context, true);
                } else if (mounted) {
                  Fluttertoast.showToast(msg: "${AppLocalizations.of(context)!.pushFailed}");
                }
              } catch (e) {
                if (mounted) {
                  Fluttertoast.showToast(msg: "${AppLocalizations.of(context)!.pushConfigFailed}: $e");
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.targetNamespaceName != null)
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.orange[100],
                width: double.infinity,
                child: Text("${AppLocalizations.of(context)!.cloneConfigPrompt} [${widget.targetNamespaceName}]"),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dataIdCtrl,
                    decoration: const InputDecoration(
                      labelText: "Data ID",
                      border: OutlineInputBorder(),
                    ),
                    enabled: widget.isCreate,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _groupCtrl,
                    decoration: const InputDecoration(
                      labelText: "Group",
                      border: OutlineInputBorder(),
                    ),
                    enabled: widget.isCreate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _appCtrl,
                    decoration: InputDecoration(
                      labelText: "${AppLocalizations.of(context)!.appName}",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _tagsCtrl,
                    decoration: InputDecoration(
                      labelText: "${AppLocalizations.of(context)!.tags}",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: InputDecoration(
                labelText: "${AppLocalizations.of(context)!.fileType}",
                border: OutlineInputBorder(),
              ),
              items: types
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: _changeType,
            ),
            const SizedBox(height: 15),
            Text("${AppLocalizations.of(context)!.fileContent}:", style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              height: 400,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              child: CodeTheme(
                data: CodeThemeData(styles: atomOneLightTheme),
                child: SingleChildScrollView(
                  child: CodeField(
                    controller: _codeController,
                    textStyle: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
