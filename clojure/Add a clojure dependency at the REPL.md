[[REPL Driven Development, Clojure's Superpower by Sean Corfield]] does this by loading `deps.edn` into the REPL like ...

```clojure
(ns deps.edn
 (:require [clojure.repl.deps :refer [add-lib]]))
```

I can't find the path to `add-libs` to replicate this ...

How else?

```sh
$ clojure -Sdeps '{:deps {org.clojure/core.async {:mvn/version "1.5.648"}}}'
Clojure 1.11.1
user=> (require '[clojure.core.async :as a])
nil
```
https://clojure.org/guides/deps_and_cli#command_line_deps

Apparently this doesnt require a JVM restart
https://clojureverse.org/t/how-to-use-a-dependency-from-clojure-repl-without-starting-a-lein-project/1596

I'm having a hard time making that work,  it looks like I can just call a function in the REPL ...
https://clojure.org/news/2023/04/14/clojure-1-12-alpha2#_add_libraries_for_interactive_use

Hmmm

I probably just need to install `Clojure CLI Tools`!