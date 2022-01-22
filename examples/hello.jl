using LightApp: App, State, Button, h, serve

app = App()

app.state.x = 1

app.layout = h.div(
    h.h1("Hello World!"),

    h.p("My app has state: ", State("x")),

    Button(children="Increment X", state="x") do state, val
        state.x += 1
    end
)

serve(app)
