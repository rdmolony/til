It's in the docs
https://shadow-cljs.github.io/docs/UsersGuide.html#deps-edn

I just have to move `:dependencies` to `:deps` & `:source-paths` to `:paths` from `shadow-cljs.edn` to `deps.edn` & then set `:deps true` so `shadow-cljs` knows to rely on `Clojure CLI` for managing dependencies!

I also have to convert deps to format `ring/ring-core {:mvn/version "1.9.1"}` instead of `[[ring/ring-core "1.9.1"]]`

