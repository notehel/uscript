# 有脚本

### 介绍
平时开发为了方便，写了一个小工具，使用lua脚本，主要方便自己使用，用来好多年了，近期打算完善一下，分享给大家，欢迎大家使用提意见。

### 软件架构
Delphi+Lua

![软件界面](https://gitee.com/ksence_admin/uscript/raw/master/UScript.png)

### 使用说明
* 软件比较小巧，可执行文件2M左右
* 目前支持windows各个版本，后续考虑加入其他系统支持
* 下载地址：https://gitee.com/ksence_admin/uscript/attach_files/1115541/download/UScript.zip
* 有条件的用户可以自己下载编译
* 用户可以根据需要增加扩展脚本

### 脚本编写说明，具体参照script目录

开头部分定义输入参数，参数可以定义多个，按顺序排列
```
--- param URL
--- param POST内容，一行一个
```

提供有几个和UI交互的函数
```
APP_clearOutput(); 清理输出区域
APP_getContent('param1', ''); 获取参数
APP_showContent('', content); 输入内容到显示区域
APP_getContent 获取内容
APP_mkdirs 创建目录
APP_saveFile 保存文件
APP_download 下载文件
APP_md5 计算md5
APP_md5File 计算文件md5
APP_httpPost 模拟httpPost
APP_httpGet 模拟httpGet
APP_regexp 正则
APP_replace 替换
```

欢迎大家交流