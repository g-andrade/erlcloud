%% @author Ransom Richardson <ransom@ransomr.net>
%% @doc
%%
%% HTTP client abstraction for erlcloud. Simplifies changing http clients.
%% API matches lhttpc, except Config is passed instead of options for
%% future cusomizability.
%%
%% @end

-module(erlcloud_httpc).

-export([request/6]).


-define(LHTTPC_POOLID_PADDING, 2).

request(URL, Method, Hdrs, Body, Timeout, _Config) ->
    Pools = application:get_env(erlcloud, lhttpc_pools, 1),
    PoolIndex = crypto:rand_uniform(0, Pools),
    PoolPreffix = application:get_env(erlcloud, lhttpc_pool_preffix, "lhttpc_man_erlcloud"),

    PoolSuffix = case PoolIndex >= (?LHTTPC_POOLID_PADDING * 10) of
        true  -> integer_to_list(PoolIndex);
        false ->
            FormatStr = lists:flatten(["~", integer_to_list(?LHTTPC_POOLID_PADDING), "..0B"]),
            lists:flatten( io_lib:format(FormatStr, [PoolIndex]) )
    end,

    PoolId = list_to_atom(PoolPreffix ++ PoolSuffix),
    LHttpcConfig = [{pool, PoolId}, {pool_ensure, true}],
    lhttpc:request(URL, Method, Hdrs, Body, Timeout, LHttpcConfig).
