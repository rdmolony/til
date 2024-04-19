`shadow-cljs` wasn't hot-reloading in the browser ...
I had selected `:app` instead of `:node` or `:browser` REPL in `Calva`, selecting `:browser` instead behaves as I'd expect!
**But** now I can't REPL from `VSCode` to the browser ...

I can see from [[ClojureScript loves React Native]] that `rn-rf-shadow` hot reloads so let's abandon https://github.com/day8/re-frame-template in favour of https://github.com/PEZ/rn-rf-shadow

Aha!  I'm using components defined in `js` & `shadow-cljs` only hot reloads components defined in `cljs` via `Reagent`!  If I use `Reagent` the I see hot reloading ... 
Why does this also impacts `onSubmitHandler` since it's defined in `cljs` & triggers `(re-frame/dispatch [:submit e])`?

Hmmm
It looks like I need to customise `shadow-cljs` hot reloading for this use case ...
https://code.thheller.com/blog/shadow-cljs/2019/08/25/hot-reload-in-clojurescript.html
Helpfully, `shadow-cljs` logs what its doing to the console!
When I change a `js` file I see `shadow-cljs: load JS gen/Greeting.js` ...
So somehow `(rdom/unmount-component-at-node root-el)` & `(rdom/render [views/main-panel] root-el)` are not re-rendering the component ...
So ...
```clojure
(defn init []
  (re-frame/dispatch-sync [::events/initialize-db])
  (dev-setup)
  (mount-root))
```
... does update `js` components while ...
```clojure
(defn ^:dev/after-load mount-root []
  (re-frame/clear-subscription-cache!)
  (let [root-el (.getElementById js/document "app")]
    (rdom/unmount-component-at-node root-el)
    (rdom/render [views/main-panel] root-el)))
```
... does not.
I tried merging `init` into `mount-root` but no luck ...

> Depending on your setup you may also need to actually ensure that reagent/react don’t decide to skip the re-render. Sometimes they may think that nothing has changed if you only changed something further down.
> 
> When using `reagent` directly you might need to add an additional prop to signal “change”, so it doesn’t immediately skip since `ui` didn’t change.

I tried adding a dummy `{:x (js/Date.now)}` to `rdom/render` but no luck ...

I suspect that the `js` functions are referenced via imports & not changed!  Only `app.js` is changed!

In `app.js` `Greeting.js` is referenced like `SHADOW_ENV.evalLoad("module$gen$Greeting.js", ...)` & `views.js` like `SHADOW_ENV.evalLoad("chatgpt.views.js", ...)`
I can see that `module$gen$Greeting.js` does change to reflect edits via Developer Tools however `app.js` does not change!
I can see that `views.cljs` does not import code directly to `SHADOW_ENV.evalLoad` as per the `js` files but rather references the code via `goog.provide` ...

[React 18 does not live reload with Shadow-CLJS in non-trivial projects](https://github.com/reagent-project/reagent/issues/579#top)
[Add option to emulate full :recompile-dependents](https://github.com/thheller/shadow-cljs/issues/349#top)

Okay.
`shadow-cljs` creates `app.js` which references other compiled `cljs` files via `goog` namespace BUT stores `gen/js` files there

Why does browser target work & not `:app`?

> I've decided I don't care,  I don't care about editing components interactively,  only the data flow which does hot reload ...



