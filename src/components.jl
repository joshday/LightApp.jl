abstract type StateComponent end


#-----------------------------------------------------------------------------# Dropdown
Base.@kwdef struct Dropdown <: StateComponent
    statekey::String
    options::Vector{String}
    multiple::Bool = false
    label::String
    default = first(options)
end

function node(o::Dropdown)
    id = randstring(10)
    children = Node[]
    !isempty(o.label) && push!(children, m("label", var"for"=id, o.label))
    options = Node[]
    push!(children, m("select", name=id, id=id, options...))
    m("div", children...)
end

<label for="cars">Choose a car:</label>

<select name="cars" id="cars">
  <option value="volvo">Volvo</option>
  <option value="saab">Saab</option>
  <option value="mercedes">Mercedes</option>
  <option value="audi">Audi</option>
</select>


# function Base.show(io::IO, ::MIME"text/html", o::Dropdown)
#     id = randstring(10)
#     !isempty(o.label) && print(io, "<label for=\"$id\">$(o.label)</label>")
#     print(io, )


# <select name="cars" id="cars">
#   <option value="volvo">Volvo</option>
#   <option value="saab">Saab</option>
#   <option value="mercedes">Mercedes</option>
#   <option value="audi">Audi</option>
# </select>
# end
