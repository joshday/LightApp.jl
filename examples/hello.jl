using LightApp: App, State, h, serve

app = App()

app.state.x = 1

app.layout = h.div(
    h.h1("Hello World!")."text-xl"."text-center"."text-gray-800"."mt-8",

    h.p("This is my app!")."text-gray-500"."text-center"."my-16",

    h.p("It has state: ", State("x"))."text-gray-500"."text-center"."text-2xl",
)

serve(app)
