
import 'dart:js_util';
import 'dart:ui' as ui;
import 'dart:html';
import 'package:flutter/scheduler.dart';
import 'package:flutter_2d_amap/src/web/amap_2d_controller.dart';
import 'package:flutter_2d_amap/src/web/amapjs.dart';
import 'package:flutter_2d_amap/src/web/loaderjs.dart';
import 'package:js/js.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_2d_amap/flutter_2d_amap.dart';

class AMap2DViewState extends State<AMap2DView> {

  final htmlId = 'amap-${Uuid().v1()}';
  final plugins = ['AMap.Geolocation', 'AMap.PlaceSearch']; // 'AMap.Scale', 'AMap.ToolBar',

  AMap _aMap;
  DivElement _element;

  void _onPlatformViewCreated() {

    var promise = load(LoaderOptions(
      key: widget.webKey,
      version: '1.4.15',
      plugins: plugins,
    ));

    promiseToFuture(promise).then((value){
      MapOptions _mapOptions = MapOptions(
        zoom: 13,
      );
      _aMap = AMap(_element, _mapOptions);
      /// 加载插件
      _aMap.plugin(plugins, allowInterop(() {
//        _aMap.addControl(Scale());
//        _aMap.addControl(ToolBar());

        final AMap2DWebController controller = AMap2DWebController(_aMap, widget);
        if (widget.onAMap2DViewCreated != null) {
          widget.onAMap2DViewCreated(controller);
        }
      }));

    }, onError: (e) {
      print('初始化错误：$e');
    });
  }

  @override
  void dispose() {
    _aMap.destroy();
    _aMap = null;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    /// 先创建div并注册
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(htmlId, (int viewId) {
      _element = DivElement()
        ..id = htmlId
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = 'none'
        ..style.margin = '0';

      return _element;
    });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      /// 创建地图
      _onPlatformViewCreated();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return HtmlElementView(
      viewType: htmlId,
    );
  }
}