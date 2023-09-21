include("../../Org.jl/src/Org.jl")
using .Org
using Dates

const PATH_TO_NOTES = "/sharedfolders/Syncthing/Dokumente/Notizen/journals/"

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

function contains_todo(section_list::Vector{Union{Org.Heading, Org.Section}})
    for item in section_list
        if item isa Org.Heading && item.keyword == "TODO"
            return true
        end
    end
    return false 
end

function divide_document(document::Org.OrgDoc)
    divided_document = divide_headings(document)
    old = OrgDoc(collect(Iterators.flatten(filter(sec->!contains_todo(sec), divided_document))))
    new = OrgDoc(collect(Iterators.flatten(filter(contains_todo, divided_document))))

    return old, new
end

function only_date_in_document(document::Org.OrgDoc, date::Dates.Date)
    contents = document.contents
    if length(contents) == 0 || length(contents) > 1 || contents[1] isa Org.Heading
        return false
    end
    section = contents[1]
    if length(section.contents) == 1 && section.contents[1] isa Org.Keyword
        keyword = section.contents[1]
        if keyword.key == "title"
            if is_date(string(keyword.value), date)
                return true
            end
        end
    end
    return false
end

function is_date(text::String, date::Dates.Date)
    date_as_strings = [Dates.format(date, "E, d.m.Y"), Dates.format(date, "E, dd.mm.yyyy", locale="german")]
    return text in date_as_strings
end

function extract_and_delete_carryover(d::Dates.Date)
    filepath = PATH_TO_NOTES*string(d)*".org"
    if !isfile(filepath)
        return Org.OrgDoc()
    end
    org_parsed = org_doc_from_file(filepath)

    old, new = divide_document(org_parsed)
    cp(filepath, filepath*"~", force=true)
    if length(old.contents) == 0 || only_date_in_document(old, d)
        rm(filepath)
    else
        io = open(filepath, "w")
        org(io, old)
        close(io)
    end
    return new
end

function cat_org_documents(documents::Vector{Org.OrgDoc})
    return Org.OrgDoc(vcat([doc.contents for doc in documents]...))
end

function org_doc_from_file(path::AbstractString)
    io = open(path, "r")
    org_string = read(io, String)
    close(io)
    org_parsed = Org.parse(OrgDoc, org_string)
    return org_parsed
end

function carryover()
    make_german_dates!()
    today = Dates.today()
    go_back = 14
    documents = [extract_and_delete_carryover(today-Dates.Day(i)) for i in 1:go_back]
    new = cat_org_documents(documents)
    filepath = PATH_TO_NOTES*string(today)*".org"
    if !isfile(filepath)
        io = open(filepath, "w")
        print(io, "#+title: ", Dates.format(today, "E, dd.mm.yyyy"; locale="german"), "\n")
        close(io)
    else
        cp(filepath, filepath*"~", force=true)
    end
    org_parsed = org_doc_from_file(filepath)
    new = cat_org_documents([org_parsed, new])
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
