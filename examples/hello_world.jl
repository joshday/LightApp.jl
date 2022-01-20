using LightApp


app = App()

app.init_state.y = 20

app.layout = m("div",
    m("h1", "Hello World!"),
    m("p", "This is a dropdown menu:"),
    Dropdown("x", ["one", "two", "three"], false, "My Label:"),
    m("p", "And this is the dropdown's value: ", Render("x")),
    m("p", "And this is y: ", Render("y"))
)



# What this writes out in JS:
js"""
// Each node gets a function component
const C1 = props => html`<div>{props.children}</div>`
const C2 = props => html`<h1>Hello World!</h1>`
const C3 = props => html`<h1>This is a dropdown menu:</h1>`
const C5 = props => html`<p>And this is the dropdown's value: {props.x}</p>`
const C6 = props => html`<p>And this is y: {props.y}</p>`

App(props) => {
    const [state, setState] = useState({"x": "one"})

    // Each LightApp.Component goes here so it can access useState
    C4(props) => {
        html`
        <div>
            <label for="random_id">Choose a car:</label>
            <select name="random_id" id="random_id" onChange={e => this.setState("x": e.target.value)}>
                <option value="one">one</option>
                <option value="two">two</option>
                <option value="three">three</option>
            </select>
        </div>
        `
    }

    return html`
        <C1>
            <C2 />
            <C3 />
            <C4 />
            <C5 x={this.state.x} />
            <C6 y={this.state.y} />
        </C1>
    `
}
"""
