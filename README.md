# LightApp

Experimental package for writing SPWA in Julia.


## The Gist of LightApp


1.  The app is based on a single Preact state that has two parts:
    - Client-only state (data)
    - Server-managed state.
2. The server api has a single endpoint: JSON in, JSON out
    - Client sends request (server-managed state + action)
    - Server sends JSON response (state to be updated)
    - This turns into `this.setState(json_response)`


## Technologies we Heavily Lean Into

- [Preact.js](https://preactjs.com) (lightweight alternative to React.js).
- [Tailwind.css](https://tailwindcss.com) (Lets you forget about styles, just add classes like `text-center`).
- [Hyperscript.jl](https://github.com/JuliaWeb/Hyperscript.jl).  Lets you easily write components with many classes (as happens with Tailwind)

```julia
using Hyperscript

template = m("div")."text-gray-100"."hover:bg-gray-700"."hover:text-white"."px-3"."py-2"."rounded-md"."text-xl"."font-medium"

template("Text with lots of styling!")
# <div class="text-gray-100 hover:bg-gray-700 hover:text-white px-3 py-2 rounded-md text-xl font-medium">Text with lots of styling&#33;</div>
```
