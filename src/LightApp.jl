module LightApp

using JSON3
using HTTP
using Hyperscript: Hyperscript, m, Node, Pretty

using Sockets
using Random

#-----------------------------------------------------------------------------# App
# - All Nodes get their own JS component
# - StateComponents get JS components that go inside of App (because they need this.setState)


Base.@kwdef struct App
    title::String = "LightApp.jl Application"
    layout::Node = m("h1", HTML("No Layout!"))
end



# function prop_components(node::Node)
#     out = []
#     children = getfield(node, :children)
#     node_children = filter(x -> x isa Node, children)
#     other_children = filter(x -> !(x isa Node), children)
#     for child in node_children
#         append!(out, prop_components(c))
#     end
#     for child in other_children
#         append!(out, prop_components(c))
#     end
#     return out
# end


#-----------------------------------------------------------------------------# get_script
function get_script(app::App)
    io = IOBuffer()
    println(io)
    p(args...) = println(io, "      ", args...)
    p("import { html, Component, render } from 'https://unpkg.com/htm/preact/index.mjs?module';")

    # components = []
    # prop_components!(components, app.layout)

    p("class App extends Component {")
    p("  render() {")
    p("    return html`");


    show(io, MIME"text/html"(), app.layout);

    println(io, "`");
    p("  }")
    p("}")
    p("document.body.innerHTML = \"\";")
    p("render(html`<\${App} />`, document.body);")

    return HTML(String(take!(io)))
end

#-----------------------------------------------------------------------------# Node
function Hyperscript.Node(o::App)
    m("html", lang="en",
        m("head",
            m("title", o.title),
            m("meta", name="viewport", content="width=device-width, initial-scale=1.0"),
            m("meta", charset="utf-8"),
            m("script", src="/assets/tailwindcss.js"),
            m("script", src="/assets/preact.min.js"),
            m("script", type="module", get_script(o))
        ),
        m("body", "Loading...")
    )
end

#-----------------------------------------------------------------------------# serve
function serve(app::App, port=8080)
    io = IOBuffer()
    println(io, "<!doctype html>")
    show(io, MIME"text/html"(), Pretty(Node(app)))
    index_html = String(take!(io))

    ROUTER = HTTP.Router()
    HTTP.@register(ROUTER, "GET", "/", req -> HTTP.Response(200, index_html))
    HTTP.@register(ROUTER, "GET", "/assets/*", load_asset)
    # HTTP.@register(ROUTER, "GET", "/julia_api", req -> process_request(app, req))
    HTTP.serve(ROUTER, ip"127.0.0.1", port)
end

function load_asset(req)
    file = HTTP.URIs.splitpath(req.target)[2]
    HTTP.Response(200, read(joinpath(@__DIR__, "..", "deps", file), String))
end

# include("template.jl")
# include("components.jl")

# #-----------------------------------------------------------------------------# Render
# struct Render
#     statekey::String
# end
# Base.show(io::IO, o::Render) = print(io, "{this.state.$(o.statekey)}")
# Base.show(io::IO, ::MIME"text/html", o::Render) = show(io, o)

# #-----------------------------------------------------------------------------# App
# mutable struct App
#     init_state::JSON3.Object
#     title::String
#     layout
#     reducers

#     function App(; init_state=Dict(), title="LightApp.jl Application", layout=m("h1", "No Layout Provided."))
#         io = IOBuffer()
#         show(io, MIME"text/html"(), layout)
#         new(JSON3.write(init_state), string(title), String(take!(io)))
#     end
# end


# function home(app::App)
#     io = IOBuffer()
#     render(io, TEMPLATE, app)
#     String(take!(io))
# end

# function process_request(app::App, req::HTTP.Request)
#     json = JSON3.read(req.body)
#     action = json.__ACTION__
#     haskey(app.reducers, json.__action__) || return HTTP.Response(400, "App does not have action: $action.")
# end

# #-----------------------------------------------------------------------------# serve




end
