cond->

Threads expression through multiple (conditional form) and evaluates the form if conditional is true!

It's used in [[Learn Reitit by Jacek Shae]] to do something if a key is present in a map like 
```clojure
(cond->
	(:auth opts) (mock/header :authorization (str "Bearer " (auth/get-test-token)))
    (:body opts) (mock/json-body {:body opts}))
```

Unlike `cond` it doesn't exit on the first true conditional!

