using LightApp
using LightApp: Button, State
using PlotlyLight
using EasyConfig
using Hyperscript

app = LightApp.App()

app.state = Config(x = [1,2,3], y = rand(3))

app.layout = m("div",
    m("h1", "Hello World!"),

    Button("Click me to make new plot data") do (state, btnval)
        res.plot_x = rand(10)
        res.plot_y = rand(10)
        res
    end,

    Plot(Config(x=State("x"), y=State("y")))
)

LightApp.serve(app)
