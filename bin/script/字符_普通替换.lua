--- param ÄÚÈİ
--- param ²éÕÒ
--- param Ìæ»»Îª

content = APP_getContent('param1', '');
searchStr = APP_getContent('param2', '');
replaceStr = APP_getContent('param3', '');

content = APP_replace(content, searchStr, replaceStr);

APP_showContent('', content);

