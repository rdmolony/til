What's the difference between `::initialize-db` & `:initialize-db`?  https://github.com/day8/re-frame-template uses `::initialize-db` to define `app-db` ...
```clojure
;; events.cljs
(ns chatgpt.events
  (:require
   [re-frame.core :as re-frame]
   [chatgpt.db :as db]
   ))

(re-frame/reg-event-db
 ::initialize-db
 (fn [_ _]
   db/default-db))
```
```clojure
(ns chatgpt.db)

(def default-db
  {:responses []})
```

`:initialize-db` is not namespace qualified,  `::initialize-db` is!  So if I'm in a namespace `my.app`, using `::initialize-db` will automatically expand to `:my.app/initialize-db` which prevents namespace conflicts when integrating code from different namespaces!

#clojure 
