#built in wat functions, and how many arguments they consume
#https://webassembly.github.io/spec/core/appendix/index-instructions.html

i32ops = Dict(
:(+)=>["i32.add",2],
:(-)=>["i32.sub",2],
:(*)=>["i32.mul",2],
:(div)=>["i32.div_s",2], #julia 4/2 will return float. but div(4,2) wont
:(%)=>["i32.rem_s",2],
:(%)=>["i32.rem_s",2],
:(rem)=>["i32.rem_s",2],
:(&&)=>["i32.and",2],
:(||)=>["i32.or",2],
:(⊻)=>["i32.xor",2],
:(xor)=>["i32.xor",2],
:(<<)=>["i32.shl",2],
:(>>)=>["i32.shr_s",2],
:(==)=>["i32.eq",2],
:(===)=>["i32.eq",2],
:(!=)=>["i32.ne",2],
:(<)=>["i32.lt_s",2],
:(>)=>["i32.gt_s",2],
:(<=)=>["i32.le_s",2],
:(>=)=>["i32.ge_s",2],
:(!)=>["i32.eqz",1],
:(not_int)=>["i32.eqz",1],
:(leading_zeros)=>["i32.clz",1],
:(trailing_zeros)=>["i32.ctz",1],
:(count_ones)=>["i32.popcnt",1],
:(float)=>["f32.convert_i32_s",1],
:(Int)=>["i32.trunc_f32_s",1],
#""=>["i32.load",1]
#""=>["i32.store",2]
#""=>["i32.const",1]
)

f32ops = Dict(
:(+)=>["f32.add",2],
:(-)=>["f32.sub",2],
:(*)=>["f32.mul",2],
:(/)=>["f32.div",2],
:(==)=>["f32.eq",2],
:(!=)=>["f32.ne",2],
:(<)=>["f32.lt",2],
:(>)=>["f32.gt",2],
:(<=)=>["f32.le",2],
:(>=)=>["f32.ge",2],
:(abs)=>["f32.abs",1],
:(ceil)=>["f32.ceil",1],
:(floor)=>["f32.floor",1],
:(trunc)=>["f32.trunc",1],
:(round)=>["f32.nearest",1],
:(sqrt)=>["f32.sqrt",1],
:(min)=>["f32.min",2],
:(max)=>["f32.max",2],
:(copysign)=>["f32.copysign",2],
:(float)=>["f32.convert_i32_s",1],
:(Int)=>["i32.trunc_f32_s",1],
#""=>["f32.neg",1],
#""=>["f32.load",1],
#""=>["f32.store",2],
#""=>["f32.const",1],
)

#( if expr (then stuff) (else stuff) )