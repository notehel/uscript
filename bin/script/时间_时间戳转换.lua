--- param 时间戳
--- param 日期

unixtime = APP_getContent('param1', '');
datetime = APP_getContent('param2', '');

local _, _, y, m, d, _hour, _min, _sec = string.find(datetime, "(%d+)-(%d+)-(%d+)%s*(%d+):(%d+):(%d+)");
local timestamp = os.time({year=y, month = m, day = d, hour = _hour, min = _min, sec = _sec});

APP_clearOutput();
APP_showContent('', os.date("%Y-%m-%d %H:%M:%S",unixtime));
APP_showContent('', timestamp);