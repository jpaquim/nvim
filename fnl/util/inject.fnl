(local M {})

(fn M.args [___fn___ wrapper]
  (fn [...]
    (when (= (wrapper ...) false) (lua "return "))
    (___fn___ ...)))

(fn M.get_upvalue [func name]
  (var i 1)
  (while true (local (n v) (debug.getupvalue func i))
    (when (not n) (lua :break))
    (when (= n name) (lua "return v"))
    (set i (+ i 1))))

M

