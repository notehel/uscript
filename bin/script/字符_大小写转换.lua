--- param Ҫת��Сд������
--- param Ҫת����д������

function lowOne(s)
    return string.lower(s)
end

function upOne(s)
    return string.upper(s)
end

APP_clearOutput();

content1 = APP_getContent('param1', '');
content2 = APP_getContent('param2', '');

APP_showContent('', lowOne(content1));

APP_showContent('', upOne(content2));