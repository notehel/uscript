--- param ������ʽ
--- param Ҫ���������
--- param ���ģ�壬��$0$1$2

regs = APP_getContent('param1', '');
content = APP_getContent('param2', '');
listStr = APP_getContent('param3', '');

content = APP_regexpList(regs, content, listStr);

APP_showContent('', content);

