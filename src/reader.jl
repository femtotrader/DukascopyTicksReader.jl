import Base: start, done, next
using LibArchive

struct TickRawRecordType
  Date::UInt32
  Ask::UInt32
  Bid::UInt32
  AskVolume::Float32
  BidVolume::Float32
end

struct TickRecordType
  Date::DateTime
  Ask::AbstractFloat
  Bid::AbstractFloat
  AskVolume::AbstractFloat
  BidVolume::AbstractFloat
end

function convert(raw_rec::TickRawRecordType, dt_chunk, p_digits)
    TickRecordType(
        Base.Dates.Millisecond(raw_rec.Date) + dt_chunk,
        Float64(raw_rec.Ask) / 10^p_digits,
        Float64(raw_rec.Bid) / 10^p_digits,
        Float64(raw_rec.AskVolume),
        Float64(raw_rec.BidVolume),
    )
end

type TickIter{S<:IO}
    stream::S
    ondone::Function
    dt_chunk::DateTime
    p_digits::UInt    
end
function TickIter{S<:IO}(stream::S, year, month, day, hour, symb; ondone=()->nothing)
    TickIter{S}(stream, ondone, DateTime(year, month, day, hour), price_digits(symb))
end


function start(itr::TickIter)
    seek(itr.stream, 0)
    nothing
end

function next(itr::TickIter, nada)
    fh = itr.stream
    raw_rec = TickRawRecordType(
        ntoh(read(fh, UInt32)),
        ntoh(read(fh, UInt32)),
        ntoh(read(fh, UInt32)),
        ntoh(read(fh, Float32)),
        ntoh(read(fh, Float32))
    )
    rec = convert(raw_rec, itr.dt_chunk, itr.p_digits)
    rec, nothing
end

function done(itr::TickIter, nada)
    if !eof(itr.stream)
        return false
    end
    itr.ondone()
    true
end

type TickReader
    filename::AbstractString
    reader::LibArchive.Reader
    itr::TickIter
    
    function TickReader(dt::DateTime, ticker, filename)
        reader = LibArchive.Reader(filename)
        
        LibArchive.support_format_raw(reader)
        LibArchive.support_filter_all(reader)
        entry = LibArchive.next_header(reader)
        arr = read(reader)
        close(reader)
        stream = IOBuffer(arr)
        itr = TickIter(stream, Dates.year(dt), Dates.month(dt), Dates.day(dt), Dates.hour(dt), ticker)
        new(filename, reader, itr)
    end
end



function to_arrays(reader::TickReader)
    itr = reader.itr
    seek(itr.stream, 0)
    #arr = collect(itr)  # MethodError: no method matching length(...) with Julia 0.6 (and probably 0.5)
    #a_date = Array{DateTime}(map(rec->rec.Date, arr))
    #a_ask = Array{Float64}(map(rec->rec.Ask, arr))
    #a_bid = Array{Float64}(map(rec->rec.Bid, arr))
    #a_ask_vol = Array{Float64}(map(rec->rec.AskVolume, arr))
    #a_bid_vol = Array{Float64}(map(rec->rec.BidVolume, arr))
    a_date = Vector{DateTime}()
    a_ask = Vector{Float64}()
    a_bid = Vector{Float64}()
    a_ask_vol = Vector{Float64}()
    a_bid_vol = Vector{Float64}()
    state = start(itr);
    while !done(itr, state)
        rec, state = next(itr, state)
        push!(a_date, rec.Date)
        push!(a_ask, rec.Ask)
        push!(a_bid, rec.Bid)
        push!(a_ask_vol, rec.AskVolume)
        push!(a_bid_vol, rec.BidVolume)
    end
    a_date, a_ask, a_bid, a_ask_vol, a_bid_vol
end

using DataFrames
function to_dataframe(reader::TickReader)
    a_date, a_ask, a_bid, a_ask_vol, a_bid_vol = to_arrays(reader)
    columns = [:Date, :Ask, :Bid, :AskVolume, :BidVolume]
    df = DataFrame([a_date a_ask a_bid a_ask_vol a_bid_vol])
    names!(df, columns)
    df
end

using TimeSeries: TimeArray
function to_timearray(reader::TickReader)
    a_date, a_ask, a_bid, a_ask_vol, a_bid_vol = to_arrays(reader)
    columns = ["Ask", "Bid", "AskVolume", "BidVolume"]
    dat = [a_ask a_bid a_ask_vol a_bid_vol]
    TimeArray(a_date, dat, columns)
end
