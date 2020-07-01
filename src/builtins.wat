(func $getindex (param $v i32) (param $i i32) (result f32)
(f32.load (i32.add (local.get $v) (i32.mul (local.get $i) (i32.const 4))))
)

(func $setindex (param $v i32) (param $x f32) (param $i i32)
(f32.store (i32.add (local.get $v) (i32.mul (local.get $i) (i32.const 4))) (local.get $x))
)

(func $iterate (param $n i32) (param $k i32) (param $N i32) (param $i i32) (result i32)
(local.set $i (i32.add (local.get $i) (local.get $k)))
(select (local.get $i) (i32.const 0) (i32.and (i32.le_s (local.get $i) (local.get $N)) (i32.ge_s (local.get $i) (local.get $n))))
)

;; y = W*x + b where y,x and b are vectors 
(func $matvecmuladd (export "matvecmuladd") (param $y i32) (param $W i32) (param $x i32) (param $b i32)
(local $N i32) (local $M i32) (local $s f32) (local $_9 i32) (local $i i32) (local $_11 i32) (local $j i32) 
( local.set $N (i32.trunc_f32_s (local.get $x) ) ) 
( local.set $M (i32.trunc_f32_s (local.get $y) ) ) 
( local.set $_9 (i32.const 1) ) 
(block (loop ;;loop1 
  ( local.set $i (local.get $_9) ) 
  ( local.set $s (f32.const 0.0) ) 
  ( local.set $_11 (i32.const 1) ) 
  (block (loop ;;loop2 
    ( local.set $j (local.get $_11) ) 
    ( local.set $s ( f32.add (local.get $s) ( f32.mul ( call $getindex (local.get $W) ( i32.add ( i32.mul ( i32.sub (local.get $j) (i32.const 1) ) (local.get $M) ) (local.get $i) ) ) ( call $getindex (local.get $x) (local.get $j) ) ) ) ) 
    ( local.set $_11 (call $iterate (i32.const 1) (i32.const 1) (local.get $N) (local.get $_11) ) ) 
    ( br_if 1 (i32.eqz (local.get $_11) ) ) 
    (br 0))) ;;endloop2 
  ( call $setindex (local.get $y)
    ( f32.add (local.get $s) ( call $getindex (local.get $b) (local.get $i) ) )  ;;set this value
    (local.get $i) ;;at this index
  ) 
  ( local.set $_9 (call $iterate (i32.const 1) (i32.const 1) (local.get $M) (local.get $_9) ) ) 
  ( br_if 1 (i32.eqz (local.get $_9) ) ) 
(br 0))) ;;endloop1 
)

;;y = W*x .+ b where y,x are matrices and b is vector
(func $muladd (export "muladd") (param $y i32) (param $W i32) (param $x i32) (param $b i32) (param $M i32) (param $N i32)
(local $s f32) (local $ncols i32) (local $_10 i32) (local $col i32) (local $_12 i32) (local $i i32) (local $_14 i32) (local $j i32) 
( local.set $ncols ( i32.sub ( i32.div_s (i32.trunc_f32_s (local.get $x) ) (local.get $N) ) (i32.const 1) ) ) 
( local.set $_10 (i32.const 0) ) 
(block (loop ;;loop1
  ( local.set $col (local.get $_10) ) 
  ( local.set $_12 (i32.const 1) ) 
  (block (loop ;;loop2 
    ( local.set $i (local.get $_12) ) 
    ( local.set $s (f32.const 0.0) ) 
    ( local.set $_14 (i32.const 1) ) 
    (block (loop ;;loop3 
      ( local.set $j (local.get $_14) ) 
      ( local.set $s ( f32.add (local.get $s) ( f32.mul ( call $getindex (local.get $W) ( i32.add ( i32.mul ( i32.sub (local.get $j) (i32.const 1) ) (local.get $M) ) (local.get $i) ) ) ( call $getindex (local.get $x) ( i32.add (local.get $j) ( i32.mul (local.get $col) (local.get $N) ) ) ) ) ) ) 
      ( local.set $_14 (call $iterate (i32.const 1) (i32.const 1) (local.get $N) (local.get $_14) ) ) 
      ( br_if 1 ( i32.eqz (local.get $_14) ) ) 
    (br 0))) ;;endloop3 
    ( call $setindex (local.get $y)
      ( f32.add (local.get $s) ( call $getindex (local.get $b) (local.get $i) ) ) ;;set this value
      ( i32.add (local.get $i) ( i32.mul (local.get $col) (local.get $M) ) ) ;;at this index
    ) 
    ( local.set $_12 (call $iterate (i32.const 1) (i32.const 1) (local.get $M) (local.get $_12) ) ) 
    ( br_if 1 (i32.eqz (local.get $_12) ) ) 
    (br 0))) ;;endloop2 
  ( local.set $_10 (call $iterate (i32.const 0) (i32.const 1) (local.get $ncols) (local.get $_10) ) ) 
  ( br_if 1 (i32.eqz (local.get $_10) ) ) 
(br 0))) ;;endloop1 
)

;;y = W*x .+ b where y,x are matrices and b is vector
(func $mul (export "mul") (param $y i32) (param $W i32) (param $x i32) (param $b i32) (param $M i32) (param $N i32)
(local $s f32) (local $ncols i32) (local $_10 i32) (local $col i32) (local $_12 i32) (local $i i32) (local $_14 i32) (local $j i32) 
( local.set $ncols ( i32.sub ( i32.div_s (i32.trunc_f32_s (local.get $x) ) (local.get $N) ) (i32.const 1) ) ) 
( local.set $_10 (i32.const 0) ) 
(block (loop ;;loop1
  ( local.set $col (local.get $_10) ) 
  ( local.set $_12 (i32.const 1) ) 
  (block (loop ;;loop2 
    ( local.set $i (local.get $_12) ) 
    ( local.set $s (f32.const 0.0) ) 
    ( local.set $_14 (i32.const 1) ) 
    (block (loop ;;loop3 
      ( local.set $j (local.get $_14) ) 
      ( local.set $s ( f32.add (local.get $s) ( f32.mul ( call $getindex (local.get $W) ( i32.add ( i32.mul ( i32.sub (local.get $j) (i32.const 1) ) (local.get $M) ) (local.get $i) ) ) ( call $getindex (local.get $x) ( i32.add (local.get $j) ( i32.mul (local.get $col) (local.get $N) ) ) ) ) ) ) 
      ( local.set $_14 (call $iterate (i32.const 1) (i32.const 1) (local.get $N) (local.get $_14) ) ) 
      ( br_if 1 ( i32.eqz (local.get $_14) ) ) 
    (br 0))) ;;endloop3 
    ( call $setindex (local.get $y)
      (local.get $s) ;;set this value
      ( i32.add (local.get $i) ( i32.mul (local.get $col) (local.get $M) ) ) ;;at this index
    ) 
    ( local.set $_12 (call $iterate (i32.const 1) (i32.const 1) (local.get $M) (local.get $_12) ) ) 
    ( br_if 1 (i32.eqz (local.get $_12) ) ) 
    (br 0))) ;;endloop2 
  ( local.set $_10 (call $iterate (i32.const 0) (i32.const 1) (local.get $ncols) (local.get $_10) ) ) 
  ( br_if 1 (i32.eqz (local.get $_10) ) ) 
(br 0))) ;;endloop1 
)