using DukascopyTicksReader
using DukascopyTicksReader: get, to_arrays, to_dataframe, to_timearray
using DukascopyTicksReader: _cache_dir, _destination_filename, _url


using Base.Test

@testset "DukascopyTicksReader" begin


    @testset "utils" begin
        source = DukascopyTicks()
        cache = CacheDirectory()
        ticker = "EURUSD"

        dt = DateTime(2016, 3, 28, 0, 40)
        
        @test _cache_dir(source, cache, ticker, dt) == joinpath(homedir(), "data", "dukascopy", "ticks",
                               "2016", "2016-03", "2016-03-28", "2016-03-28_000000")

        @test _url(source, ticker, dt) == "http://www.dukascopy.com/datafeed/EURUSD/2016/03/28/00h_ticks.bi5"
        
        @test _destination_filename(source, ticker, dt) == "EURUSD.bi5"
    end

    @testset "usage: get" begin
        source = DukascopyTicks()
        cache = CacheDirectory()
        ticker = "USDCHF"

        dt = DateTime(2016, 3, 28, 0, 40)
        dt2 = DateTime(2016, 4, 8, 0, 40)

        data = get(source, ticker, dt)
        #println(data)

        #a = to_arrays(data)

        @testset "DataFrame" begin
            df = to_dataframe(data)
            # println(df)
        end

        @testset "TimeArray" begin
            ta = to_timearray(data)
            # println(ta)
        end

        #data = get(source, ticker, dt, dt2)
        #println(data)

        #=
        tickers = ["EURUSD", "USDJPY"]
        data = get(source, tickers, dt, dt2)
        println(data)
        =#
    end

    @testset "usage: bulk download" begin
        skip_error = true
        tickers = ["AUDUSD", "USDCAD"]
        # tickers = ["AUDUSD", "USDCAD", "USDCHF", "EURUSD", "GBPUSD", "NZDUSD"]
        source = DukascopyTicks()
        download(source, tickers, DateTime(2016, 1, 5), DateTime(2016, 1, 8), skip_error=skip_error)
        # download(source, tickers, DateTime(2016, 1, 1), DateTime(Dates.today()), skip_error=skip_error)
        # download(source, tickers, DateTime(2014, 1, 1), DateTime(Dates.today()), skip_error=skip_error)
    end

end