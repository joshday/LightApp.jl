TEMPLATE = mt"""
<!DOCTYPE html>
<html lang="en">
<head>
    <title>{{title}}</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta charset="utf-8" />

    <script type="module">
        import { render, html } from 'https://cdn.skypack.dev/preact';
        import { useState } from 'https://cdn.skypack.dev/preact/hooks';

        function App (props) {
            return html`{{{layout}}}`;
        }
        document.body.innerHTML = ""
        render(html`<${App} />`, document.body);
    </script>
</head>
<body>
    Loading...
</body>
</html>
"""
