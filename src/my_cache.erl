-module(my_cache).
-export([create/1, insert/4, lookup/2, delete_obsolete/1]).


create(TableName) -> 
    ets:new(TableName, [public, named_table]), ok.

insert(TableName, Key, Value, TTL) -> 
    EndDateSeconds = get_time_now_as_seconds() + TTL,
    ets:insert(TableName, {Key, Value, EndDateSeconds}), ok.

lookup(TableName, Key) -> 
    KVList = ets:lookup(TableName, Key),
    NowSeconds = get_time_now_as_seconds(),
    case KVList of
        [{Key, Value, EndDateSeconds}] when NowSeconds =< EndDateSeconds -> 
            {ok, Value};
        _ -> undefined
    end.

delete_obsolete(TableName) ->
    FirstKey = ets:first(TableName),
    NowSeconds = get_time_now_as_seconds(),
    <<"done">> = delete_obsolete(TableName, FirstKey, NowSeconds), 
    ok.

delete_obsolete(_TableName, '$end_of_table', _NowSeconds) ->      
    <<"done">>;

delete_obsolete(TableName, Key, NowSeconds) -> 
    NextKey = ets:next(TableName, Key),
    KVList = ets:lookup(TableName, Key),      
    case KVList of
        [{Key, _Value, EndDateSeconds}] when NowSeconds >= EndDateSeconds -> 
            ets:delete(TableName, Key);
        _ -> true
    end, 
    delete_obsolete(TableName, NextKey, NowSeconds).
    
get_time_now_as_seconds() -> 
    calendar:datetime_to_gregorian_seconds(calendar:local_time()).




%% Написати бібліотеку для кешування:
%% 1. Створення кеш таблиці (аргументи: ім'я таблиці).
%% 2. Додати запис в кеш (аргументи: ім'я таблиці, ключ, значення, час життя запису).
%% 3. Прочитати значеня по ключу (функція повинна повертати тільки актуальні(нові), але НЕ застарілі дані).
%% 4. Очистити з пам'яті всі застарілі записи.
