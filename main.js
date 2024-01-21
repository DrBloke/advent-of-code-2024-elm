import "./style.css";
import { Elm } from "./src/Main.elm";

if (process.env.NODE_ENV === "development") {
    const ElmDebugTransform = await import("elm-debug-transformer")

    ElmDebugTransform.register({
        simple_mode: true
    })
}

const root = document.querySelector("#app div");
const app = Elm.Main.init({ flags: location.href, node: root });

// Inform app of browser navigation (the BACK and FORWARD buttons)
window.addEventListener('popstate', function () {
    app.ports.onUrlChange.send(location.href);
});

// Change the URL upon request, inform app of the change.
// app.ports.pushUrl.subscribe(function (url) {
//     history.pushState({}, '', url);
//     app.ports.onUrlChange.send(location.href);
// });



