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

(defn pagebefore [a b &opt n]
    (default n 0)
    (def x (get a n))
    (def y (get b n))
    (cond
        (nil? x) true
        (nil? y) false
        (< x y) true
        (> x y) false
            (pagebefore a b (+ n 1))))


(test (pagebefore @[1] @[2]) true)
(test (pagebefore @[2] @[1]) false)
(test (pagebefore @[6 24 2] @[6 24 5]) true)
(test (pagebefore @[55 2 9 102] @[55 2 8 102]) false)
(test (pagebefore @[12 20] @[12 20 5]) true)

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