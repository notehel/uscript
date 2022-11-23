--- param 正则表达式
--- param 要处理的内容
--- param 输出模板，如$0$1$2

regs = APP_getContent('param1', '');
content = APP_getContent('param2', '');
listStr = APP_getContent('param3', '');

content = APP_regexpList(regs, content, listStr);

APP_showContent('', content);

