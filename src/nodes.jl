#-----------------------------------------------------------------------------# Node
# Like Hyperscript.Node, but with less magic
struct Node{tag}
    attrs::Vector{Union{String, Pair{String,String}}}
    children
    classes::Vector{String}
    style::String
    Node(; tag, attrs, children, classes, style) = new{tag}(attrs, children, classes, style)
end
function Node{T}(children...; kw...) where {T}
    attrs = [v == true ? string(k) : string(k) => string(v) for (k,v) in kw]
    Node(; tag=T, attrs, children, classes=String[], style="")
end

Base.getproperty(o::Node{T}, name) where {T} = Base.getproperty(o, Symbol(name))

function Base.getproperty(o::Node{T}, name::Symbol) where {T}
    f = Fields(o)
    classes = vcat(f.classes, split(string(name)))
    Node(; tag=T, attrs=f.attrs, children=f.children, classes, style=f.style)
end

# To switch getproperty back to getfield
struct Fields{T}
    item::T
end
Base.getproperty(f::Fields, prop::Symbol) = getfield(getfield(f, :item), prop)

#-----------------------------------------------------------------------------# htm
function htm(node::Node)
end

#-----------------------------------------------------------------------------# show
Base.show(io::IO, node::Node) = show(io, MIME"text/html"(), node)

function Base.show(io::IO, ::MIME"text/html", node::Node{T}) where {T}
    compact = get(io, :compact, false)
    color = get(io, :tagcolor, 1)
    printstyled(io, "<$T"; color)
    f = Fields(node)
    attrs, classes, children = f.attrs, f.classes, f.children
    for attr in attrs
        if attr isa String
            printstyled(io, ' ', attr; color)
        else
            printstyled(io, ' ', attr[1], '=', '"', attr[2], '"'; color)
        end
    end
    !isempty(classes) && printstyled(io, " class=", "\"$(join(classes, ' '))\""; color)
    printstyled(io, ">"; color)
    compact || println(io)

    for (i, child) in enumerate(children)
        ctx = IOContext(io, :tagcolor => color + i, :compact => true)
        print(io, "  ")
        if child isa Node
            show(ctx, MIME"text/html"(), child)
        else
            try
                show(ctx, MIME"text/html"(), child)
            catch
                print(ctx, child)
            end
            i == length(children) && print(io)
        end
    end
    printstyled(io, "</$T>\n"; color)
end

#-----------------------------------------------------------------------------# H
struct H end
Base.getproperty(::H, x::Symbol) = Node{x}
h = H()
