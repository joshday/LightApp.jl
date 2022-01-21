using LightApp
using Hyperscript: Hyperscript

m(args...; kw...) = Hyperscript.m(Hyperscript.NOESCAPE_HTMLSVG_CONTEXT, args...; kw...)

app = App()

app.state.x = 1

app.layout = m("div",
    m("h1", "Hello World!"),
    m("p", "This is a my app!"),
    m("p", "It has state: ", State("x"))
)

# This writes out as :
# const C1 = props => <div>{props.children}</div>
# const C2 = () => <p>{This is my app!}</p>
# const C3 = () => <p>It has state: {this.state.x}</p>
#
# render() {
#   return html`
#     <${C1}>
#     <//>
#   `
# }


LightApp.serve(app)
