#-----------------------------------------------------------------------------# Handler
# How we set things like: onClick={e => handle(e.target.value)}
struct Handler
    key::String
    function_string::String
end
function Base.show(io::IO, ::MIME"text/html", h::Handler)

end




#-----------------------------------------------------------------------------# Component
struct Component
    f::Function  # (state, value) → new_state
    node::Hyperscript.Node
    id::String  # use same `id` in html as well as in Julia
end

function button(f, args...; kw...)
    id = randstring(20)
    Component(f, m("button", type="button", args...; id, kw...), id)
end


#-----------------------------------------------------------------------------# Button
struct Button <: Component
    server_function  # (state,val) -> mutated state
    children
    active::Bool
    id::String
end
Button(f, children; active::Bool=false, id=randstring(10)) = Button(f, children, active ,id)

function js(o::Button)
    """
    function Button({children, active}) {
        const c = active ? "text-white bg-indigo-600 hover:bg-indigo-700" : "text-indigo-700 bg-indigo-100 hover:bg-indigo-200"
        return html`
            <button type="button"

                class={`inline-flex items-center m-2 px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm \${c} focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500`}

                onClick={e => rountTrip($(o.id), e.target.value)}
            >
                {children}
            </button>
        `
      }
    """
end
