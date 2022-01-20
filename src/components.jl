#-----------------------------------------------------------------------------# State
struct State
    x
end
Base.show(io::IO, ::MIME"text/html", st::State) = print(io, "{this.state.$(st.x)}")

#-----------------------------------------------------------------------------# Component
abstract type Component end

#-----------------------------------------------------------------------------# Button
struct Button <: Component
    server_function
    children
    active::Bool
    id::String
end
Button(f, children; active::Bool=false, id=randstring(10)) = Button(f, children, active ,id)

function js(o::Button)
    """
    function Button({children, active}) {
        const c = active ? "text-white bg-indigo-600 hover:bg-indigo-700" : "text-indigo-700 bg-indigo-100 hover:bg-indigo-200"
        return (
            <button type="button"

                className={`inline-flex items-center m-2 px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm \${c} focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500`}

                onClick={e => rountTrip($(o.id), e.target.value)}
            >
                {children}
            </button>
        )
      }
    """
end
