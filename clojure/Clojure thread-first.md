Or `(-> ...)`
`(-> x & forms)` threads the expr through the forms,  inserts `x` as the 2nd item in the first form etc

It enables pulling from a map like ...
```clojure
(def person
  {:employer {:address {:city "Dublin"}}}
  )

(-> person :employer :address :city)
(:city (:address (:employer person)))
```

#clojure