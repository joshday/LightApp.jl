#-----------------------------------------------------------------------------# Node
# Like Hyperscript.Node, but with less magic
struct Node{tag}
    attrs::Vector{Union{String, Pair{String,String}}}
    children
    classes::Vector{String}
    style::String
end
function Node{T}(children...; kw...) where {T}
    attrs = [v == true ? string(k) : string(k) => string(v) for (k,v) in kw]
    Node{T}(attrs, children, String[], "")
end

Base.getproperty(o::Node{T}, name) where {T} = Base.getproperty(o, Symbol(name))

function Base.getproperty(o::Node{T}, name::Symbol) where {T}
    f = Fields(o)
    Node{T}(f.attrs, f.children, vcat(f.classes, string(name)), f.style)
end

# To switch getproperty back to getfield
struct Fields{T}
    item::T
end
Base.getproperty(f::Fields, prop::Symbol) = getfield(getfield(f, :item), prop)


#-----------------------------------------------------------------------------# show
Base.show(io::IO, node::Node) = show(io, MIME"text/html"(), node)

function Base.show(io::IO, ::MIME"text/html", node::Node{T}, indent=0) where {T}
    starting_indent = get(io, :indent, 0) + indent
    block = ' ' ^ starting_indent

    print(io, block, "<$T")
    f = Fields(node)
    attrs, classes, children = f.attrs, f.classes, f.children
    for attr in attrs
        if attr isa String
            print(io, ' ', attr)
        else
            print(io, ' ', attr[1], '=', attr[2])
        end
    end
    !isempty(classes) && print(io, " class=", "\"$(join(classes, ' '))\"")
    println(io, ">")

    for (i, child) in enumerate(children)
        if child isa Node
            show(IOContext(io, :indent => starting_indent + 4), MIME"text/html"(), child)
        else
            i == 1 && print(io, ' ' ^ (starting_indent + 4))
            hasmethod(show, Tuple{IO, MIME"text/html", typeof(child)}) ?
                show(IOContext(io, :indent => starting_indent + 4), MIME"text/html"(), child) :
                print(io, child)
            i == length(children) && println(io)
        end
    end
    println(io, block, "</$T>")
end

#-----------------------------------------------------------------------------# H
struct H end
Base.getproperty(::H, x::Symbol) = Node{x}
h = H()
