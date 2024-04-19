How do I use a `React` component from `Re-Frame`?

https://github.com/reagent-project/reagent/blob/master/doc/InteropWithReact.md

Let's try & solve this at the REPL via `Calva` ...

How do I import from one module to another in the REPL?
```clojure
(def Chat (js/require "../components/Chat"))
```
This doesn't work ...

- [x] Does `ClojureScript` "understand" `jsx`?
No!

[[Using React Components with ClojureScript]]
https://groups.google.com/g/clojurescript/c/7rpKNXgu6PI?pli=1
https://stackoverflow.com/questions/35489797/using-react-components-in-reagent

- [x] How do I import from one module to another in the REPL?
I have to compile `React` to `js` via a build tool ...
[[Importing React components from NPM by Tom Weller]]
There must be an easier way ...

The `Reagent` repo has some examples,  let's try them locally
So the `material-ui` example imports components from `js`, not from `jsx`!
So let's convert `jsx` to `js` & import from there ...
I can use `webpack` to bundle `jsx` to `index.js` & then add my components to `node_modules`
Is this indirection necessary?  Can I just import `js` directly?

[Importing a JavaScript Module into ClojureScript](https://gist.github.com/jmlsf/d691e53e1fea4019a393412f781e2561)
What about placing my transpiled `js` alongside my compiled `ClojureScript`?
[Dependencies | ClojureScript.org](https://clojurescript.org/reference/dependencies)
[JS Dependencies In Practice | thhheller](https://code.thheller.com/blog/shadow-cljs/2017/11/10/js-dependencies-in-practice.html)

Damn this is hard ...

It's all in the `shadow-cljs` docs!  I was so close the first time.  I can import `js` via relative paths ...
https://shadow-cljs.github.io/docs/UsersGuide.html#classpath-js

Finally got it to work!

My `jsx` looks like ...
```jsx
import React from 'react';

export default function Chat({ }) {
  return (
    <div className="rounded-xl shadow-lg text-center bg-gray-100">
      <div className="py-4">
        <p>Dia Duit, cad faoi ar mhaith labhairt?</p>
      </div>
      <div>
        <input className="rounded-xl shadow-lg p-2 mt-2 mb-4 "></input>
      </div>
    </div>
  )
}
```
... which is transpiled to `js` via `babel` & then importable from the `js` file via ...
```clojure
(:require ["../components/Chat" :default Chat])
```

I can refer to components via `c` namespace like `c/Chat` by similarly using `index.jsx` ...
```jsx
export { default as Chat } from './Chat';
```
... and refer to it as ...
```clojure
["../components/index.js" :as c]
```
