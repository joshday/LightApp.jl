module LightApp

using JSON3
using HTTP
using EasyConfig
using StructTypes

using Sockets
using Random

JSON_ENDPOINT = "/api/json"

export App, State

include("nodes.jl")
include("components.jl")

#-----------------------------------------------------------------------------# State
struct State
    x::String
end
Base.show(io::IO, st::State) = print(io, "\${this.state.$(st.x)}")
Base.show(io::IO, ::MIME"text/html", st::State) = show(io, st)

#-----------------------------------------------------------------------------# App
Base.@kwdef mutable struct App
    title::String = "LightApp.jl Application"
    layout::Node = h.h1("No ", h.code("layout"), " has been provided")."text-xl"."text-red-600"
    state::Config = Config()
    components::Config = Config()
end

function Base.setproperty!(app::App, name::Symbol, x)
    setfield!(app, name ,x)
    if name === :layout
        app.components = get_components(app.layout)
    end
end


function get_components(node::Node)
    c = Config()
    for child in filter(x -> x isa Component, getfield(node, :children))
        c[child.id] = child
    end
    return c
end


#-----------------------------------------------------------------------------# get_script
function indexjs(app::App)
    io = IOBuffer()
    show(io, MIME"text/html"(), app.layout)
    layout = String(take!(io))
    """
        import { html, Component, render } from 'https://unpkg.com/htm/preact/index.mjs?module';

        class App extends Component {
            action (component_id, value, keys=null) {
                const state = JSON.parse(JSON.stringify(this.state));  // TODO: only use provided keys
                console.log(`Sending state: \${JSON.stringify(state)}.`)

                state.__COMPONENT_ID__ = component_id;
                state.__COMPONENT_VALUE__ = value;
                fetch("$JSON_ENDPOINT", {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify(state)
                })
                .then(response => response.json())
                .then(data => {
                    console.log(`From Julia: \${JSON.stringify(data)}`)
                    this.setState(s => ({...s, ...data}))
                })
                .then(() => console.log(`State Update: \${JSON.stringify(this.state)}`))
            };

            componentDidMount() {
                console.log(`Initial state: \${JSON.stringify(this.state)}`)
                this.action("__INITIALIZE_STATE__", null)
                // this.setState($(JSON3.write(app.state)))
            };

            render() {
                return html`$(app.layout)`
            }
        }

        document.body.innerHTML = \"\"; // Remove "Loading..." from page.

        render(html`<\${App} />`, document.body);
    """
end


#-----------------------------------------------------------------------------# Node
function Node(o::App)
    h.html(lang="en",
        h.head(
            h.title(o.title),
            h.meta(name="viewport", content="width=device-width, initial-scale=1.0"),
            h.meta(charset="utf-8"),
            h.script(src="/assets/tailwindcss.js"),
            h.script(src="/assets/preact.min.js"),
            h.script(type="module", indexjs(o))
        ),
        h.body("Loading...")  # Gets overwritten by script
    )
end

#-----------------------------------------------------------------------------# process_json
function process_json(app::App, req::HTTP.Request)
    json = JSON3.read(req.body, Config)

    # debugging
    io = IOBuffer()
    JSON3.pretty(io, json)
    printstyled("process_json called with data:\n", color=:light_cyan)
    printstyled(String(take!(io)); color=:light_green)
    println(); println()

    id = json.__COMPONENT_ID__
    val = json.__COMPONENT_VALUE__
    if id == "__INITIALIZE_STATE__"
        @info "Intializing state..."
        return HTTP.Response(200, ["Content-Type"=>"application/json"]; body=JSON3.write(app.state))
    else
        app.components[id].f(json, val)
    end
    delete!(json, :__COMPONENT_ID__)
    delete!(json, :__COMPONENT_VALUE__)
    @info "Returning:" JSON3.write(json)
    return HTTP.Response(200,  ["Content-Type"=>"application/json"]; body=JSON3.write(json))
end

#-----------------------------------------------------------------------------# serve
function serve(app::App, host=Sockets.localhost, port=8080)
    io = IOBuffer()
    println(io, "<!doctype html>")
    show(io, MIME"text/html"(), Node(app))
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


end
