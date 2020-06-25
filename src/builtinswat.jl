builtinswat = Dict(
"iterate"=>"""(func \$iterate (param \$n i32) (param \$k i32) (param \$N i32) (param \$i i32) (result i32)
(local.set \$i (i32.add (local.get \$i) (local.get \$k)))
(select (local.get \$i) (i32.const 0) (i32.and (i32.le_s (local.get \$i) (local.get \$N)) (i32.ge_s (local.get \$i) (local.get \$n))))
)\n""",
"getindex" => """(func \$getindex (param \$v i32) (param \$i i32) (result f32)
(f32.load (i32.add (local.get \$v) (i32.mul (i32.sub (local.get \$i) (i32.const 1)) (i32.const 4))))
)\n""",
"setindex!" => """(func \$setindex (param \$v i32) (param \$x f32) (param \$i i32)
(f32.store (i32.add (local.get \$v) (i32.mul (i32.sub (local.get \$i) (i32.const 1)) (i32.const 4))) (local.get \$x))
)\n""",
)