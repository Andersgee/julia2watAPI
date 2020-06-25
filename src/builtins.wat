(func $iterate (param $n i32) (param $k i32) (param $N i32) (param $i i32) (result i32)
  ;;get next i in the iterator i=n:k:N (return 0 if i becomes greater than N)
  (local.set $i (i32.add (local.get $i) (local.get $k)))
  ;; ifelse(k<N, i, 0)
  ;;(select (local.get $i) (i32.const 0) (i32.le_s (local.get $i) (local.get $N))) ;;assuming n<N
  ;; ifelse(n<k<N, i, 0)
  (select (local.get $i) (i32.const 0) (i32.and (i32.le_s (local.get $i) (local.get $N)) (i32.ge_s (local.get $i) (local.get $n))))
)

(func $getindex (param $v i32) (param $i i32) (result f32)
  ;;v[i]
  (f32.load (i32.add (local.get $v) (i32.mul (i32.sub (local.get $i) (i32.const 1)) (i32.const 4))))
  ;;(f32.load (i32.add (local.get $v) (i32.mul (local.get $i) (i32.const 4)))) ;;one based indexing
)

(func $setindex (param $v i32) (param $x f32) (param $i i32)
  ;;v[i]=x
  (f32.store (i32.add (local.get $v) (i32.mul (i32.sub (local.get $i) (i32.const 1)) (i32.const 4))) (local.get $x))
  ;;(f32.store (i32.add (local.get $v) (i32.mul (local.get $i) (i32.const 4))) (local.get $x)) ;;one based indexing
)

