--- param 要替换的内容
--- param 搜索表达式
--- param 替换为

content = APP_getContent('param1', '');
searchStr = APP_getContent('param2', '');
replaceStr = APP_getContent('param3', '');

content = APP_regexp(content, searchStr, replaceStr, 'm');

APP_showContent('', content);

