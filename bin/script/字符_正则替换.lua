--- param Ҫ�滻������
--- param �������ʽ
--- param �滻Ϊ

content = APP_getContent('param1', '');
searchStr = APP_getContent('param2', '');
replaceStr = APP_getContent('param3', '');

content = APP_regexp(content, searchStr, replaceStr, 'm');

APP_showContent('', content);

