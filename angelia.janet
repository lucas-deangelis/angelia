#!/usr/bin/env janet
(use judge)

(import cmd)
(import spork/zip)

# For now that part isn't used as the sorting seems to not like using anything else than <
(defn extract-numbers [filename]
    (map parse (peg/match 
        '(some (choice (<- :d+) 1))
        filename)))

(test (extract-numbers "001.png") @[1])
(test (extract-numbers "1_continuum_3_turbulence_2.avif")  @[1 3 2])
(test (extract-numbers "(G11) [lorem 52 ipsum] page 12") @[11 52 12])
(test (extract-numbers "zzzzzzzzzzzzzzzzzzzzzzzzz") @[])
(test (extract-numbers "Unicode をチェックするクールなテスト") @[])
(test (map extract-numbers @["14_15" "001.png" "Nothing"]) @[@[14 15] @[1] @[]])

(defn pagebefore [a b &opt n]
    (default n 0)
    # (print "n is: " n)
    (def x (get a n))
    (def y (get b n))
    # (print "x is: " x)
    # (print "y is: " y)
    (cond
        (nil? x) true
        (nil? y) false
        (< x y) true
        (> x y) false
            (pagebefore a b (+ n 1))))


(def ta @[@[1] @[2] @[3] @[4] @[5]])
(each i ta
    (each j ta
        (print "i: " i " j: " j " comp: " (pagebefore i j))))

(test (pagebefore @[1] @[2]) true)
(test (pagebefore @[2] @[1]) false)
(test (pagebefore @[2] @[3]) true)
(test (pagebefore @[3] @[4]) true)
(test (pagebefore @[4] @[5]) true)
(test (pagebefore @[6 24 2] @[6 24 5]) true)
(test (pagebefore @[55 2 9 102] @[55 2 8 102]) false)
(test (pagebefore @[12 20] @[12 20 5]) true)

(defn com [a b]
    (print "called with " a " " b)
    (pagebefore
        (extract-numbers a)
        (extract-numbers b)))

(test (com "1" "2") true)
(test (com "2" "1") false)
(test (com "1" "1") true)
(test (com "1" "1") true)

(pp (extract-numbers "5"))

(test (sort @["5" "3" "4" "1" "2"] (fn [a b] (com a b))) @[1 2 3 4 5])
# (test (sorted @["5" "3"] (fn [a b] (= -1 (compare a b)))) @["3" "5"])

(defn main
    [& args]
    (cmd/def
        file (required ["<file>" :string]))

    (def reader (zip/read-file file))
    (def count (zip/reader-count reader))

    (def filenames (array/new count))
    (for i 0 count
        (def stat (zip/stat reader i))
        (put filenames i (get stat :filename)))

    (sort filenames)
    (zip/extract reader (get filenames 0) (get filenames 0)))

(main)