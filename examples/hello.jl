using LightApp
using Hyperscript: Hyperscript

m(args...; kw...) = Hyperscript.m(Hyperscript.NOESCAPE_HTMLSVG_CONTEXT, args...; kw...)

app = App()

app.state.x = 1

app.layout = m("div",
    m("h1", "Hello World!"),
    m("p", "This is my app!"),
    m("p", "It has state: ", State("x")),
)

LightApp.serve(app)
