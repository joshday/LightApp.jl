module LightApp

using JSON3
using HTTP
using Hyperscript: Hyperscript, m, Node, Pretty
using EasyConfig
using StructTypes

using Sockets
using Random

JSON_ENDPOINT = "/api/json"

export App, State

#-----------------------------------------------------------------------------# State
struct State
    x
end
Base.show(io::IO, st::State) = print(io, "\${this.state.$(st.x)}")
Base.show(io::IO, ::MIME"text/html", st::State) = show(io, st)
StructTypes.StructType(::Type{State}) = StructTypes.StringType()


#-----------------------------------------------------------------------------# App
Base.@kwdef mutable struct App
    title::String = "LightApp.jl Application"
    layout::Node = m("h1", HTML("No Layout!"))
    state::Config = Config()
end

#-----------------------------------------------------------------------------# componentize
function componentize(node::Node)
    repr("text/html", node)
end


#-----------------------------------------------------------------------------# get_script
function indexjs(app::App)
    """
    import { html, Component, render } from 'https://unpkg.com/htm/preact/index.mjs?module';

    class App extends Component {
        state = $(JSON3.write(app.state))

        async action (component_id, value) {
            const state = JSON.parse(JSON.stringify(this.state)) // deep copy
            state.__COMPONENT_ID__ = component_id;
            state.__COMPONENT_VALUE__ = value;
            const res = await fetch("$JSON_ENDPOINT", {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify(state)
            });
            this.setState(res.json(), () => console.log(`State Update: \${JSON.stringify(this.state)}`))
        };

        componentDidMount() {
            console.log(`Initial state: \${JSON.stringify(this.state)}`)
            this.action("__DONT_TOUCH__", "")
        };

        render() {
            return html`$(componentize(app.layout))`
        }
    }

    document.body.innerHTML = \"\"; // Remove "Loading..." from page.

    render(html`<\${App} />`, document.body);
    """
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
            m(Hyperscript.NOESCAPE_HTMLSVG_CONTEXT, "script", type="module", indexjs(o))
        ),
        m("body", "Loading...")  # Gets overwritten by script
    )
end

#-----------------------------------------------------------------------------# process_json
function process_json(app::App, req::HTTP.Request)
    json = JSON3.read(req.body, Config)
    @info json
    id = json.__COMPONENT_ID__
    val = json.__COMPONENT_VALUE__
    if id != "__DONT_TOUCH__"
        merge!(json, app.components[id](json, val))
    end
    return HTTP.Response(200, JSON3.write(json))
end

#-----------------------------------------------------------------------------# serve
function serve(app::App, host=Sockets.localhost, port=8080)
    io = IOBuffer()
    println(io, "<!doctype html>")
    show(io, MIME"text/html"(), Pretty(Node(app)))
    index_html = String(take!(io))

    ROUTER = HTTP.Router()
    HTTP.@register(ROUTER, "GET", "/", req -> HTTP.Response(200, index_html))
    HTTP.@register(ROUTER, "GET", "/assets/*", load_asset)
    HTTP.@register(ROUTER, "POST", JSON_ENDPOINT, req -> process_json(app, req))

    @info "Running server on $host:$port..."
    HTTP.serve(ROUTER, host, port)
end

function load_asset(req)
    file = HTTP.URIs.splitpath(req.target)[2]
    HTTP.Response(200, read(joinpath(@__DIR__, "..", "deps", file), String))
end

include("components.jl")

end
