(def x @[1 2 3 4 5])
(def y @[1 2 3 4 5])

(sorted x)
(sorted y)

(sorted x (fn [a b] (if (< a b) true)))

# (sorted x compare)
# (sorted y compare)