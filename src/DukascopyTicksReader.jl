module DukascopyTicksReader

    export get, DukascopyTicks, CacheDirectory
    import Base: download

    include("utils.jl")
    include("reader.jl")

    using Formatting

    SKIP_ERROR_DEFAULT = true
    
    abstract type AbstractCache end

    struct NoCache <: AbstractCache
    end

    struct CacheDirectory <: AbstractCache
        dir::AbstractString
        
        CacheDirectory() = new("")
        CacheDirectory(dir) = new(dir)
    end


    abstract type AbstractDataCacheSource end

    struct DataFromNetwork <: AbstractDataCacheSource
    end

    struct DataFromCache <: AbstractDataCacheSource
    end


    abstract type AbstractDataReader end

    struct DukascopyTicks <: AbstractDataReader
        cache::AbstractCache

        function DukascopyTicks()
            new(CacheDirectory(""))
        end        
    end


    function _cache_dir(dr::DukascopyTicks, cache::CacheDirectory, ticker::AbstractString, dt::DateTime)
        if cache.dir == ""
            d = Date(dt)
            #dt_round = DateTime(Dates.year(dt), Dates.month(dt), Dates.day(dt), Dates.hour(dt))
            #joinpath(homedir(), "data", "dukascopy", "ticks",
            #               string(Dates.year(d)), string(d)[1:end-3], string(d), ticker)
            joinpath(homedir(), "data", "dukascopy", "ticks",
                       string(Dates.year(d)), string(d)[1:end-3], string(d), Dates.format(dt, "yyyy-mm-dd_HH0000"))
        else
            cache.dir
        end
    end

    function _url(dr::DukascopyTicks, ticker::AbstractString, dt::DateTime)
        yy = Dates.year(dt)
        mm = Dates.month(dt)
        dd = Dates.day(dt)
        hh = Dates.hour(dt)
        format("http://www.dukascopy.com/datafeed/{1}/{2:04d}/{3:02d}/{4:02d}/{5:02d}h_ticks.bi5", ticker, yy, mm, dd, hh)
    end

    function _destination_filename(dr::DukascopyTicks, ticker::AbstractString, dt::DateTime)
        #hh = Dates.hour(dt)
        #format("{1:02d}h_ticks.bi5", hh)
        ticker * ".bi5"
    end

    function _cache_filename(dr::DukascopyTicks, cache::CacheDirectory, ticker::AbstractString, dt::DateTime)
        joinpath(_cache_dir(dr, cache, ticker, dt), _destination_filename(dr, ticker, dt))
    end

    function get(dr::DukascopyTicks, ticker::AbstractString, dt::DateTime, ::DataFromCache, cache::CacheDirectory, skip_error::Bool)
        filename = _cache_filename(dr, cache, ticker, dt)
        println("get $ticker for $dt from fname=$filename")
    end

    function get(dr::DukascopyTicks, ticker::AbstractString, dt::DateTime, ::DataFromNetwork, cache::CacheDirectory, skip_error::Bool)
        url = _url(dr, ticker, dt)
        filename = _cache_filename(dr, cache, ticker, dt)
        if !ispath(filename)
            mkpath(_cache_dir(dr, cache, ticker, dt))
        end
        println("download $url")
        try
            download(url, filename)
        catch
            if skip_error
                println("skip_error")
            else
                rethrow()
            end
        end
        println("save $ticker for $dt to cache $filename")
    end

    function _is_in_cache(dr::DukascopyTicks, ticker::AbstractString, dt::DateTime, cache::CacheDirectory)
        filename = joinpath(_cache_dir(dr, cache, ticker, dt), _destination_filename(dr, ticker, dt))
        isfile(filename)
    end

    function download(dr::DukascopyTicks, ticker::AbstractString, dt::DateTime; skip_error=SKIP_ERROR_DEFAULT)
        cache = dr.cache
        if _is_in_cache(dr, ticker, dt, cache)
            get(dr, ticker, dt, DataFromCache(), cache, skip_error)
        else
            get(dr, ticker, dt, DataFromNetwork(), cache, skip_error)
        end
    end

    function get(dr::DukascopyTicks, ticker::AbstractString, dt::DateTime; skip_error=SKIP_ERROR_DEFAULT)
        cache = dr.cache
        download(dr, ticker, dt, skip_error)
        filename = _cache_filename(dr, cache, ticker, dt)
        reader = TickReader(dt::DateTime, ticker, filename)
        reader
    end

    function download(dr::AbstractDataReader, ticker, dt_range::StepRange; skip_error=SKIP_ERROR_DEFAULT)
        for dt in dt_range
            download(dr, ticker, dt, skip_error)
        end
    end

    function download(dr::DukascopyTicks, ticker, start, stop; skip_error=SKIP_ERROR_DEFAULT)
        step = Dates.Hour(1)
        download(dr, ticker, start:step:stop-step, skip_error)
    end

    function download(dr::AbstractDataReader, tickers, dt::DateTime; skip_error=SKIP_ERROR_DEFAULT)
        for ticker in tickers
            download(dr, ticker, dt, skip_error)
        end
    end
    
end # module
