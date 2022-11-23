--- param ºÙ«–∞Â

APP_clearOutput()

content = APP_getContent('memery', '');

content = APP_regexp(content, '(valign|align|width|class|style)+=".*?"', '', 'm');
content = APP_regexp(content, '</?(p|span)[\\s]*>', '', 'm');

APP_showContent('', content);

