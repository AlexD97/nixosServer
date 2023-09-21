include("../../Org.jl/src/Org.jl")
using .Org
using Dates

const PATH_TO_JOURNAL = "/sharedfolders/Syncthing/Dokumente/Notizen/journals/"
const PATH_TO_CALENDAR_FILE = "/sharedfolders/Syncthing/Dokumente/Notizen/calendar.org"

function org_doc_from_file(path::AbstractString)
    io = open(path, "r")
    org_string = read(io, String)
    close(io)
    org_parsed = Org.parse(OrgDoc, org_string)
    return org_parsed
end

function divide_headings(parsed_document::Org.OrgDoc)
    contents = parsed_document.contents
    divided = Vector{Vector{Union{Org.Heading, Org.Section}}}()
    if length(contents) == 0
        return divided
    end
    if contents[1] isa Org.Section
        push!(divided, [contents[1]])
        contents = contents[2:end]
    end

    section_with_heading = Vector{Union{Org.Heading, Org.Section}}()
    for item in contents
        if item isa Org.Heading && item.level == 1
            if length(section_with_heading) > 0
                push!(divided, section_with_heading)
            end
            section_with_heading = Vector{Union{Org.Heading, Org.Section}}([item])
        else
            push!(section_with_heading, item)
        end
    end
    push!(divided, section_with_heading)
    return divided
end

function dates_in_section(section::Vector{Union{Org.Heading, Org.Section}})
    doc = Org.OrgDoc(section)
    dates = Set{Dates.Date}()
    for item in Org.OrgIterator(doc)
        if item isa Org.Timestamp
            if item isa Org.TimestampRange
                push!(dates, item.start.date)
                push!(dates, item.stop.date)
            else
                push!(dates, item.date)
            end
        end
    end
    return dates
end

function map_dates_to_section(doc::Org.OrgDoc)
    sections = divide_headings(doc)
    date_to_section = Dict{Dates.Date, Vector{Vector{Union{Org.Heading, Org.Section}}}}()
    for section in sections
        section_dates = dates_in_section(section)
        for date in section_dates
            if haskey(date_to_section, date)
                push!(date_to_section[date], section)
            else
                date_to_section[date] = [section]
            end
        end
    end
    return date_to_section
end

function cat_org_documents(documents::Vector{Org.OrgDoc})
    return Org.OrgDoc(vcat([doc.contents for doc in documents]...))
end

function write_to_journal!(document::Org.OrgDoc, date::Dates.Date)
    filepath = PATH_TO_JOURNAL*string(date)*".org"
    if !isfile(filepath)
        io = open(filepath, "w")
        print(io, "#+title: ", Dates.format(date, "E, dd.mm.yyyy"; locale="german"), "\n")
        close(io)
    else
        cp(filepath, filepath*"~", force=true)
    end
    org_parsed = org_doc_from_file(filepath)
    new = cat_org_documents([org_parsed, document])
    io = open(filepath, "w")
    Org.org(io, new)
    close(io)
end

function make_german_dates!()
    german_months = ["Januar", "Februar", "März", "April", "Mai", "Juni",
                     "Juli", "August", "September", "Oktober", "November", "Dezember"]
    german_monts_abbrev = ["Jan", "Feb", "Mär", "Apr", "Mai", "Jun", "Jul",
                           "Aug", "Sep", "Okt", "Nov", "Dez"]
    german_days = ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"]
    german_days_abbrev = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
    Dates.LOCALES["german"] = Dates.DateLocale(german_months, german_monts_abbrev, german_days, german_days_abbrev)
end

function main()
    if filesize(PATH_TO_CALENDAR_FILE) == 0
        return
    end
    make_german_dates!()
    calendar = org_doc_from_file(PATH_TO_CALENDAR_FILE)
    dates_to_section = map_dates_to_section(calendar)
    for date in keys(dates_to_section)
        document = cat_org_documents(map(Org.OrgDoc, dates_to_section[date]))
        write_to_journal!(document, date)
    end
    cp(PATH_TO_CALENDAR_FILE, PATH_TO_CALENDAR_FILE*"~", force=true)
    io = open(PATH_TO_CALENDAR_FILE, "w")
    close(io)
end
