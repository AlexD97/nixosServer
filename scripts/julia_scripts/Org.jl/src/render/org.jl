Base.show(io::IO, ::MIME"text/org", org::OrgDoc) = org(io, org)

function Base.string(component::Union{OrgDoc, Component})
    b = IOBuffer()
    org(b, component)
    String(take!(b))
end

function org(io::IO, o::OrgDoc)
    for component in o.contents
        (component isa Heading && component !== first(o.contents)) && print(io, '\n')
        org(io, component)
        print(io, '\n')
    end
end

function org(io::IO, component::Component, indent::Integer)
    print(io, ' '^indent)
    org(io, component)
end

org(o::Union{OrgDoc, Component}) = org(stdout, o)

function org(::IO, component::C) where { C <: Component}
    @warn "No method for converting $C to a string representation currently exists"
end

# ---------------------
# Sections
# ---------------------

function org(io::IO, heading::Heading, indent::Integer=0)
    print(io, ' '^indent)
    print(io, '*'^heading.level, ' ')
    if !isnothing(heading.keyword)
        print(io, heading.keyword, ' ')
    end
    if !isnothing(heading.priority)
        print(io, "[#", heading.priority, "] ")
    end
    org.(Ref(io), heading.title)
    if length(heading.tags) > 0
        print(io, " :", join(heading.tags, ':'), ":")
    end
    if !isnothing(heading.section)
        print(io, '\n')
        if all(isnothing, (heading.section.planning,
                           heading.section.properties))
            print(io, '\n')
        end
        org(io, heading.section, indent)
    end
end

function org(io::IO, section::Section, indent::Integer=0)
    if !isnothing(section.planning)
        org(io, section.planning, indent)
        print(io, '\n')
    end
    if !isnothing(section.properties)
        org(io, section.properties, indent)
        print(io, '\n')
    end
    if any(!isnothing, (section.planning, section.properties))
        print(io, '\n')
    end
    for component in section.contents
        org(io, component, indent)
        component === last(section.contents) || print(io, "\n\n")
    end
end

function org(io::IO, afkw::AffiliatedKeywordsWrapper, indent::Integer=0)
    @nospecialize afkw
    for afk in afkw.keywords
        org(io, afk, indent)
        print(io, '\n')
    end
    org(io, afkw.element, indent)
end

# ---------------------
# Greater Elements
# ---------------------

function org(io::IO, specialblock::SpecialBlock, indent::Integer=0)
    print(io, ' '^indent, "#+begin_", specialblock.name)
    if !isnothing(specialblock.parameters)
        print(io, ' ', specialblock.parameters)
    end
    print(io, '\n')
    for el in specialblock.contents
        org(io, el, indent)
        print(io, '\n')
    end
    print(io, ' '^indent, "#+end_", specialblock.name)
end

function org(io::IO, centerb::CenterBlock, indent::Integer=0)
    org(io, SpecialBlock("center", centerb.parameters, centerb.contents), indent)
end

function org(io::IO, quoteb::QuoteBlock, indent::Integer=0)
    org(io, SpecialBlock("quote", quoteb.parameters, quoteb.contents), indent)
end

function org(io::IO, drawer::Drawer, indent::Integer=0)
    print(io, ' '^indent, ':', drawer.name, ":\n")
    for node in drawer.contents
        org(io, node, indent)
        print(io, '\n')
    end
    print(io, ' '^indent, ":END:")
end

function org(io::IO, o::OrgDoc, dynblock::DynamicBlock, indent::Integer=0)
    print(io, ' '^indent, "#+begin: ", dynblock.name)
    if !isnothing(dynblock.parameters)
        print(io, ' ', dynblock.parameters)
    end
    for el in dynblock.contents
        org(io, o, el, indent)
    end
    print(io, ' '^indent, "#+end: ")
end

function org(io::IO, fn::FootnoteDefinition, indent::Integer=0)
    print(io, ' '^indent, "[fn:", fn.label, "] ")
    contentbuf = IOContext(IOBuffer(), :color => get(io, :color, false),
                           :displaysize => (displaysize(io)[1],
                                            displaysize(io)[2] - indent - 2))
    parlines = if fn.definition[1] isa Paragraph
        for obj in fn.definition[1]; org(contentbuf, obj) end
        contents = String(take!(contentbuf.io))
        wraplines(contents, displaysize(io)[2] - indent, 6 + ncodeunits(fn.label))
    else
        [""]
    end
    components = @view fn.definition[if fn.definition[1] isa Paragraph 2 else 1 end:end]
    for component in components
        org(contentbuf, component, indent)
        component === last(components) || print(contentbuf, '\n')
    end
    otherlines = split(String(take!(contentbuf.io)), '\n')
    lines = vcat(parlines, if otherlines == [""]; [] else otherlines end)
    for line in lines
        print(io, line)
        line === last(lines) || print(io, '\n', ' '^indent)
    end
end

# InlineTask

function org(io::IO, item::Item, indent::Integer=0, offset::Integer=0)
    print(io, ' '^indent, item.bullet, ' ')
    offset += length(item.bullet) + 1
    if !isnothing(item.counterset)
        print(io, " [@", item.counterset, "]")
        offset += length(item.counterset) + 4
    end
    if !isnothing(item.checkbox)
        print(io, " [", item.checkbox, ']')
        offset += 4
    end
    if !isnothing(item.tag)
        tagbuf = IOContext(IOBuffer(), :color => get(io, :color, false),
                           :displaysize => (displaysize(io)[1],
                                            displaysize(io)[2] - indent - 2))
        for obj in item.tag
            org(tagbuf, obj)
        end
        taglines = wraplines(String(take!(tagbuf.io)),
                             displaysize(io)[2] - indent - 2, offset)
        for line in taglines
            print(io, line)
            line === last(taglines) || print(io, '\n', ' '^(indent+2))
        end
        print(io, " ::")
        offset += length(taglines[end]) + 3
    end
    if length(item.contents) > 0
        print(io, ' ')
        offset += 1
        contentbuf = IOContext(IOBuffer(), :color => get(io, :color, false),
                               :displaysize => (displaysize(io)[1],
                                                displaysize(io)[2] - indent - 2))
        parlines = if item.contents[1] isa Paragraph
            for obj in item.contents[1]; org(contentbuf, obj) end
            contents = String(take!(contentbuf.io))
            wraplines(contents, displaysize(io)[2] - indent - 2, offset)
        else
            [""]
        end
        components = @view item.contents[if item.contents[1] isa Paragraph 2 else 1 end:end]
        for component in components
            org(contentbuf, component, indent)
            component === last(components) || print(contentbuf, '\n')
        end
        otherlines = split(String(take!(contentbuf.io)), '\n')
        lines = vcat(parlines, if otherlines == [""]; [] else otherlines end)
        for line in lines
            print(io, line)
            line === last(lines) || print(io, '\n', ' '^(indent+2))
        end
    end
end

function org(io::IO, list::List, indent::Integer=0)
    @nospecialize list
    for item in list.items
        org(io, item, indent)
        item === last(list.items) || print(io, '\n')
    end
end

function org(io::IO, propdrawer::PropertyDrawer, indent::Integer=0)
    print(io, ' '^indent, ":PROPERTIES:\n")
    for node in propdrawer.contents
        org(io, node, indent)
        print(io, '\n')
    end
    print(io, ' '^indent, ":END:")
end

const table_charset_org =
    Dict('|' => '|',
         '>' => '|',
         '<' => '|',
         '[' => ' ',
         ']' => ' ',
         '-' => '-',
         '+' => '+')

org(io::IO, table::Table, indent::Integer=0) =
    layouttable(io, org, table, table_charset_org, indent)

# ---------------------
# Elements
# ---------------------

org(io::IO, bcall::BabelCall) = print(io, "#+call: ", bcall.name)

function org(io::IO, block::Block, indent::Integer=0)
    name, data = if block isa CommentBlock
        ("comment", nothing)
    elseif block isa VerseBlock
        ("verse", nothing)
    elseif block isa ExampleBlock
        ("example", nothing)
    elseif block isa ExportBlock
        ("example", block.backend)
    elseif block isa SourceBlock
        ("src", if isnothing(block.arguments)
             block.lang
         else
             string(block.lang, " ", block.arguments)
         end)
    end
    print(io, ' '^indent, "#+begin_", name)
    if !isnothing(data)
        print(io, ' ', data)
    end
    print(io, '\n')
    if block isa VerseBlock
        print(io, "Oh noes! A verse block...\n")
    else
        for line in block.contents
            print(io, ' '^indent)
            if startswith(line, '*')
                print(io, ',')
            end
            print(io, line, '\n')
        end
    end
    print(io, ' '^indent, "#+end_", name)
end

function org(io::IO, clock::Clock{TimestampInactive})
    print(io, "clock: ")
    org(io, clock.timestamp)
end

function org(io::IO, clock::Clock{TimestampInactiveRange})
    print(io, "clock: ")
    org(io, clock.timestamp)
    print(io, " => ", clock.duration[1], ':',
          lpad(string(clock.duration[2]), 2, '0'))
end

org(io::IO, diarysexp::DiarySexp) = print(io, "%%", diarysexp.sexp)

function org(io::IO, planning::Planning)
    values = [(type, getproperty(planning, type))
              for type in (:deadline, :scheduled, :closed)] |>
                  vals -> filter(v -> !isnothing(v[2]), vals)
    for val in values
        print(io, uppercase(string(val[1])), ": ")
        org(io, val[2])
        val === last(values) || print(io, ' ')
    end
end

function org(io::IO, comment::Comment, indent::Integer=0)
    for line in comment.contents
        print(io, ' '^indent, "# ", line)
        line === last(comment.contents) || print(io, '\n')
    end
end

function org(io::IO, fw::FixedWidth, indent::Integer=0)
    for line in fw.contents
        print(io, ' '^indent, ": ", line)
        line === last(fw.contents) || print(io, '\n')
    end
end

org(io::IO, ::HorizontalRule) = print(io, "-----")

org(io::IO, keyword::Keyword{SubString{String}}) =
    print(io, "#+", keyword.key, ": ", keyword.value)

function org(io::IO, keyword::Keyword{Vector{Object}})
    print(io, "#+", keyword.key, ": ")
    for obj in keyword.value
        org(io, obj)
    end
end

function org(io::IO, afk::AffiliatedKeyword{SubString{String}})
    print(io, "#+", afk.key)
    if !isnothing(afk.optval)
        print(io, '[', afk.optval, ']')
    end
    print(io, ':')
    if !isnothing(afk.value)
        print(io, ' ', afk.value)
    end
end

function org(io::IO, afk::AffiliatedKeyword{Vector{Object}})
    print(io, "#+", afk.key)
    if !isnothing(afk.optval)
        print(io, '[')
        for obj in afk.optval
            org(io, obj)
        end
        print(io, ']')
    end
    print(io, ':')
    if !isnothing(afk.value)
        print(io, ' ')
        for obj in afk.value
            org(io, obj)
        end
    end
end

function org(io::IO, env::LaTeXEnvironment, indent::Integer=0)
    print(io, ' '^indent, "\\begin{", env.name, '}', env.contents[1], '\n')
    for line in env.contents[2:end]
        print(io, ' '^(2+indent), line, '\n')
    end
    print(io, ' '^indent, "\\end{", env.name, '}')
end

org(io::IO, node::NodeProperty) =
    print(io, ':', node.name, if node.additive "+:" else ":" end, if !isnothing(node.value) node.value else "" end)

function org(io::IO, objs::Vector{Object})
    for obj in objs
        org(io, obj)
    end
end

function Base.string(par::Paragraph)
    b = IOBuffer()
    org(b, par.contents)
    String(take!(b))
end

function org(io::IO, par::Paragraph, indent::Integer=0)
    lines = wraplines(string(par), displaysize(io)[2] - indent)
    for line in lines
        print(io, ' '^indent, line)
        line === last(lines) || print(io, '\n')
    end
end

# Table Row

# ---------------------
# Objects
# ---------------------

org(io::IO, entity::Entity) = print(io, '\\', entity.name)

function org(io::IO, latex::LaTeXFragment)
    if isnothing(latex.delimiters)
        print(io, latex.contents)
    else
        print(io, latex.delimiters[1], latex.contents, latex.delimiters[2])
    end
end

org(io::IO, snippet::ExportSnippet) =
    print(io, "@@", snippet.backend, ':', snippet.snippet, "@@")

function org(io::IO, fn::FootnoteReference)
    print(io, "[fn:")
    if !isnothing(fn.label)
        print(io, fn.label)
    end
    if !isnothing(fn.definition)
        print(io, ':')
        contentbuf = IOContext(IOBuffer(), :color => get(io, :color, false))
        for obj in fn.definition
            org(contentbuf, obj)
        end
        print(io, String(take!(contentbuf.io)))
    end
    print(io, ']')
end

function org(io::IO, keycite::CitationReference)
    org(io, keycite.prefix)
    print(io, '@', keycite.key)
    org(io, keycite.suffix)
end

function org(io::IO, cite::Citation)
    print(io, "[cite")
    if !isnothing(cite.style[1])
        print(io, '/', cite.style[1])
    end
    if !isnothing(cite.style[2])
        print(io, '/', cite.style[2])
    end
    print(io, ':')
    if !isnothing(cite.globalprefix)
        org(io, cite.globalprefix)
        print(io, ';')
    end
    for keycite in cite.citerefs
        org(io, keycite)
        keycite === last(cite.citerefs) || print(io, ';')
    end
    if !isnothing(cite.globalsuffix)
        print(io, ';')
        org(io, cite.globalsuffix)
    end
    print(io, ']')
end

function org(io::IO, bcall::InlineBabelCall)
    print(io, "call_", bcall.name)
    if !isnothing(bcall.header)
        print(io, '[', bcall.header, ']')
    end
    print(io, '(', bcall.arguments, ')')
end

function org(io::IO, src::InlineSourceBlock)
    print(io, "src_", src.lang)
    if !isnothing(src.options)
        print(io, '[', src.options, ']')
    end
    print(io, '{', src.body, '}')
end

org(io::IO, ::LineBreak) = print(io, "\\\\\n")

function org(io::IO, link::RadioLink)
    for obj in link.radio.contents
        org(io, obj)
    end
end

const org_link_protocol_prefixes =
    Dict(:coderef => p -> "($p)",
         :custom_id => p -> "#$p",
         :heading => p -> "*$p",
         :fuzzy => identity)

const org_link_protocol_prefer_slashprefix =
    ("https", "http", "ftp")

function org(io::IO, path::LinkPath)
    if path.protocol in keys(org_link_protocol_prefixes)
        print(io, org_link_protocol_prefixes[path.protocol](path.path))
    else
        print(io, path.protocol, ':',
              if path.protocol in org_link_protocol_prefer_slashprefix
                  "//" else "" end,
              path.path)
    end
end

org(io::IO, link::PlainLink) = org(io, link.path)

function org(io::IO, link::AngleLink)
    print(io, '<')
    org(io, link.path)
    print(io, '>')
end

function org(io::IO, link::RegularLink)
    print(io, "[[")
    org(io, link.path)
    if isnothing(link.description)
        print(io, "]]")
    else
        print(io, "][")
        for obj in link.description
            org(io, obj)
        end
        print(io, "]]")
    end
end

org(io::IO, mac::Macro) = print(io, "{{{", mac.name, '(', join(mac.arguments, ","), ")}}}")

function org(io::IO, radio::RadioTarget)
    print(io, "<<<")
    org.(Ref(io), radio.contents)
    print(io, ">>>")
end

org(io::IO, target::Target) = print(io, "<<", target.target, ">>")

org(io::IO, statscookie::StatisticsCookiePercent) =
    print(io, '[', statscookie.percentage, "%]")
org(io::IO, statscookie::StatisticsCookieFraction) =
    print(io, '[', if !isnothing(statscookie.complete) string(statscookie.complete) else "" end,
          '/', if !isnothing(statscookie.total) string(statscookie.total) else "" end, ']')

org(io::IO, script::Superscript) = print(io, script.char, '^', script.script)
org(io::IO, script::Subscript) = print(io, script.char, '_', script.script)

org(io::IO, cell::TableCell) = print(io, "| ", cell.contents, " |")

const org_timestamp_repeaterordelay_marks =
    Dict(:cumulative => "+",
         :catchup => "++",
         :restart => ".+",
         :warningall => "-",
         :warningfirst => "--")

org(io::IO, tsrod::TimestampRepeaterOrDelay) =
    print(io, org_timestamp_repeaterordelay_marks[tsrod.type], tsrod.value, tsrod.unit)

org(io::IO, tsd::TimestampDiary) = print(io, "<%%", tsd.sexp, '>')

function time_to_string(time::Time)
    h = hour(time)
    m = minute(time)
    h_string = h < 10 ? "0"*string(h) : string(h)
    m_string = m < 10 ? "0"*string(m) : string(m)
    return h_string*":"*m_string
end

function org(io::IO, ts::TimestampInstant)
    bra, ket = if ts isa TimestampActive; ('<', '>') else ('[', ']') end
    print(io, bra)
    print(io, ts.date, ' ', dayabbr(ts.date; locale="german"))
    if !isnothing(ts.time)
        print(io, ' ', time_to_string(ts.time))
    end
    if !isnothing(ts.repeater)
        print(io, ' ')
        org(io, ts.repeater)
    end
    if !isnothing(ts.warning)
        print(io, ' ')
        org(io, ts.warning)
    end
    print(io, ket)
end

function org(io::IO, tsr::TimestampRange)
    if tsr.start.date == tsr.stop.date &&
        tsr.start.repeater == tsr.stop.repeater
        bra, ket = if tsr isa TimestampActiveRange; ('<', '>') else ('[', ']') end
        print(io, bra)
        print(io, tsr.start.date, ' ', dayabbr(tsr.start.date; locale="german"))
        print(io, ' ', time_to_string(tsr.start.time),
              '-', time_to_string(tsr.stop.time))
        if !isnothing(tsr.start.repeater)
            print(io, ' ')
            org(io, tsr.start.repeater)
        end
        if !isnothing(tsr.start.warning)
            print(io, ' ')
            org(io, tsr.start.warning)
        end
        print(io, ket)
    else
        org(io, tsr.start)
        print(io, "--")
        org(io, tsr.stop)
    end
end

org(io::IO, text::TextPlain) = print(io, text.text)

const TextMarkupMarkers =
    Dict(:bold => '*',
         :italic => '/',
         :underline => '_',
         :verbatim => '=',
         :code => '~',
         :strikethrough => '+')

function org(io::IO, markup::TextMarkup)
    print(io, TextMarkupMarkers[markup.formatting])
    if markup.contents isa SubString{String}
        print(io, markup.contents)
    else
        org.(Ref(io), markup.contents)
    end
    print(io, TextMarkupMarkers[markup.formatting])
end
