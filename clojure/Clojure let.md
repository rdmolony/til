`let` uses pairs in a vector for each binding you'd like to make where the value is equal to the last expression to be evaluated.  It also enables destructuring to bind symbols to part of a collection

In `(let [[g h] [1 2 3]])` the `3` is discarded!
In `(let [[x y :as my-point] ...)`all inputs are stored in var `my-point`

```clojure
(let [x 1]
  x)
(comment =1)

(let [a 1 b 2]
  (+ a b))
(comment =3)

(let [c (+ 1 2)
	  [d e] [5 6]]
	  (-> (+ d e) (- c)))
(comment =8)

(let [[g h] [1 2 3]]
  (/ g h))
(comment =1/2 ... 3 is discarded!)

(let [[x y :as my-point] [5 3]]
  (println my-point))
(comment =1/2 ... 3 is discarded!)
```


#clojure