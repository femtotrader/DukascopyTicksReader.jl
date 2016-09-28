# DukascopyTicksReader

[![Build Status](https://travis-ci.org/femtotrader/DukascopyTicksReader.jl.svg?branch=master)](https://travis-ci.org/femtotrader/DukascopyTicksReader.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/github/femtotrader/DukascopyTicksReader.jl?svg=true&branch=master)](https://ci.appveyor.com/project/femtotrader/dukascopyticksreader-jl/branch/master)

## Installation

```julia
julia> Pkg.clone("https://github.com/femtotrader/DukascopyTicksReader.jl.git")
```

## Usage
```julia
julia> using DukascopyTicksReader: get, DukascopyTicks, to_dataframe, to_timearray

julia> source = DukascopyTicks()
DukascopyTicksReader.DukascopyTicks(DukascopyTicksReader.CacheDirectory(""))

julia> reader = get(DukascopyTicks(), "EURUSD", DateTime(2016, 3, 28, 0, 40))
get EURUSD for 2016-03-28T00:40:00 from fname=~/data/dukascopy/ticks/2016/2016-03/2016-03-28/EURUSD/00h_ticks.bi5
DukascopyTicksReader.TickReader("~/data/dukascopy/ticks/2016/2016-03/2016-03-28/EURUSD/00h_ticks.bi5",LibArchive.Reader{LibArchive.ReadFileName{UTF8String}}(LibArchive.ReadFileName{UTF8String}("~/data/dukascopy/ticks/2016/2016-03/2016-03-28/EURUSD/00h_ticks.bi5",10240),Ptr{Void} @0x00007fbcfbcf7800,true),DukascopyTicksReader.TickIter{Base.AbstractIOBuffer{Array{UInt8,1}}}(IOBuffer(data=UInt8[...], readable=true, writable=false, seekable=true, append=false, size=53000, maxsize=Inf, ptr=1, mark=-1),(anonymous function),2016-03-28T00:00:00,0x0000000000000005))

julia> to_dataframe(reader)
2650×5 DataFrames.DataFrame
│ Row  │ Date                    │ Ask     │ Bid     │ AskVolume │ BidVolume │
├──────┼─────────────────────────┼─────────┼─────────┼───────────┼───────────┤
│ 1    │ 2016-03-28T00:00:00.335 │ 1.13267 │ 1.13264 │ 1.0       │ 1.47      │
│ 2    │ 2016-03-28T00:00:00.765 │ 1.13269 │ 1.13266 │ 1.0       │ 2.25      │
│ 3    │ 2016-03-28T00:00:01.119 │ 1.13268 │ 1.13264 │ 1.0       │ 1.91      │
│ 4    │ 2016-03-28T00:00:02.739 │ 1.13267 │ 1.13262 │ 1.0       │ 2.85      │
│ 5    │ 2016-03-28T00:00:03.283 │ 1.13266 │ 1.13262 │ 1.0       │ 1.35      │
│ 6    │ 2016-03-28T00:00:03.801 │ 1.13265 │ 1.13262 │ 1.0       │ 1.29      │
│ 7    │ 2016-03-28T00:00:04.311 │ 1.13266 │ 1.13262 │ 1.0       │ 1.35      │
│ 8    │ 2016-03-28T00:00:05.256 │ 1.13265 │ 1.13261 │ 1.0       │ 1.35      │
│ 9    │ 2016-03-28T00:00:06.424 │ 1.13265 │ 1.1326  │ 1.0       │ 3.79      │
⋮
│ 2641 │ 2016-03-28T00:59:48.517 │ 1.13107 │ 1.13104 │ 1.0       │ 4.06      │
│ 2642 │ 2016-03-28T00:59:48.821 │ 1.13106 │ 1.13104 │ 1.0       │ 3.5       │
│ 2643 │ 2016-03-28T00:59:50.057 │ 1.13106 │ 1.13103 │ 1.0       │ 6.19      │
│ 2644 │ 2016-03-28T00:59:50.413 │ 1.13106 │ 1.13103 │ 1.0       │ 1.5       │
│ 2645 │ 2016-03-28T00:59:51.434 │ 1.13106 │ 1.13103 │ 1.0       │ 3.19      │
│ 2646 │ 2016-03-28T00:59:51.94  │ 1.13106 │ 1.13103 │ 1.0       │ 2.25      │
│ 2647 │ 2016-03-28T00:59:54.999 │ 1.13106 │ 1.13102 │ 1.0       │ 4.2       │
│ 2648 │ 2016-03-28T00:59:55.438 │ 1.13104 │ 1.13102 │ 1.0       │ 4.39      │
│ 2649 │ 2016-03-28T00:59:56.25  │ 1.13105 │ 1.13102 │ 1.0       │ 1.95      │
│ 2650 │ 2016-03-28T00:59:59.944 │ 1.13104 │ 1.13102 │ 1.0       │ 1.5       │

julia> to_timearray(reader)
2650x4 TimeSeries.TimeArray{Float64,2,DateTime,Array{Float64,2}} 2016-03-28T00:00:00.335 to 2016-03-28T00:59:59.944

                          Ask     Bid     AskVolume  BidVolume
2016-03-28T00:00:00.335 | 1.1327  1.1326  1.0        1.47
2016-03-28T00:00:00.765 | 1.1327  1.1327  1.0        2.25
2016-03-28T00:00:01.119 | 1.1327  1.1326  1.0        1.91
2016-03-28T00:00:02.739 | 1.1327  1.1326  1.0        2.85
⋮
2016-03-28T00:59:54.999 | 1.1311  1.131   1.0        4.2
2016-03-28T00:59:55.438 | 1.131   1.131   1.0        4.39
2016-03-28T00:59:56.25 | 1.1311  1.131   1.0        1.95
2016-03-28T00:59:59.944 | 1.131   1.131   1.0        1.5
``