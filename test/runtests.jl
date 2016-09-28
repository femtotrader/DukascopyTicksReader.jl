using DukascopyTicksReader: DukascopyTicks, CacheDirectory,
                            get_cache_dir, get_filename, get_url, get,
                            to_arrays, to_dataframe, to_timearray

using Base.Test

ticker = "EURUSD"
dt = DateTime(2016, 3, 28, 0, 40)
dt2 = DateTime(2016, 4, 8, 0, 40)

cache = CacheDirectory()
source = DukascopyTicks()

@test get_cache_dir(source, cache, ticker, dt) == joinpath(homedir(), "data", "dukascopy", "ticks",
                       "2016", "2016-03", "2016-03-28", "EURUSD")

@test get_filename(source, dt) == "00h_ticks.bi5"

@test get_url(source, ticker, dt) == "http://www.dukascopy.com/datafeed/EURUSD/2016/03/28/00h_ticks.bi5"

ticker = "USDCHF"
data = get(source, ticker, dt)
#println(data)

#println(to_arrays(data))

df = to_dataframe(data)
println(df)


ta = to_timearray(data)
println(ta)

#data = get(source, ticker, dt, dt2)
#println(data)

#=
tickers = ["EURUSD", "USDJPY"]
data = get(source, tickers, dt, dt2)
println(data)
=#
