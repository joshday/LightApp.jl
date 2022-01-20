module LightApp

using JSON3
using HTTP
using Hyperscript: Hyperscript, m, Node, Pretty
using EasyConfig

using Sockets
using Random

JSON_ENDPOINT = "/api/json"


#-----------------------------------------------------------------------------# App
Base.@kwdef mutable struct App
    title::String = "LightApp.jl Application"
    layout::Node = m("h1", HTML("No Layout!"))
    state::Config = Config()
end


#-----------------------------------------------------------------------------# get_script
function get_script(app::App)
    io = IOBuffer()
    println(io)
    p(args...) = println(io, "      ", args...)
    println(io, """
    import { html, Component, render } from 'https://unpkg.com/htm/preact/index.mjs?module';

    class App extends Component{
        async function roundTrip(component_id, value) {
            const state = JSON.parse(JSON.stringify(this.state));
            state.__COMPONENT_ID__ = component_id
            state.__COMPONENT_VALUE__ = value
            const response = await fetch($JSON_ENDPOINT), {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify(state)
            }
            this.setState(response.json())
        }
    """)



    p("""
        render() {
            return html`<p>Hi!</p>`
        }
    }
    """)
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
        m("body", "Loading...")  # Gets overwritten by script
    )
end

#-----------------------------------------------------------------------------# process_json
function process_json(app, req)
    json = JSON3.read(req.body, Config)
    id = json.__COMPONENT_ID__
    val = josn.__COMPONENT_VALUE__
    merge!(json, app.components[id](json, val))
    return HTTP.Response(200, JSON3.write(json))
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
    HTTP.@register(ROUTER, "GET", JSON_ENDPOINT, req -> process_json(app, req))
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
