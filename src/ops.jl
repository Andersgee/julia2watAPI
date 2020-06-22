#built in wat functions, and how many arguments they consume
#https://webassembly.github.io/spec/core/appendix/index-instructions.html

f32ops = Dict(
    :(+) => ["f32.add",2],
    :(-) => ["f32.sub",2],
    :(*) => ["f32.mul",2],
    :(/) => ["f32.div",2],
    :(sqrt) => ["f32.sqrt",1],
    :(min) => ["f32.min",2],
    :(max) => ["f32.max",2],
    :(abs) => ["f32.abs",1],
    :(^) => ["call \$pow",2],
    :(ceil) => ["f32.ceil",1],
    :(floor) => ["f32.floor",1],
    :(trunc)=>["f32.trunc",1],
    :(round)=>["f32.nearest",1],
    :(float)=>["f32.convert_i32_s", 1],
    :(Int)=>["i32.trunc_f32_s",1]
#=
:(neg_float)=>"f32.neg", #negation
:(copysign_float)=>"f32.copysign", #copysign
:(eq_float)=>"f32.eq", #compare ordered and equal
:(ne_float)=>"f32.ne", #compare unordered or unequal
:(lt_float)=>"f32.lt", #compare ordered and less than
:(le_float)=>"f32.le", #compare ordered and less than or equal
=#
)

i32ops = Dict(
    :(+) => ["i32.add",2],
    :(-) => ["i32.sub",2],
    :(*) => ["i32.mul",2],
    :(not_int) => ["i32.eqz",1],
    :(===) => ["i32.eq",2],
    :(==) => ["i32.eq",2],
    :(>) => ["i32.gt_s",2],
    :(<) => ["i32.lt_s",2],
    :(>=) => ["i32.ge_s",2],
    :(<=) => ["i32.le_s",2],
    :(!=) => ["i32.ne",2],
    :(&&)=>["i32.and",2],
    :(||)=>["i32.or",2],
    :(xor)=>["i32.xor",2],
    :(float)=>["f32.convert_i32_s", 1],
    :(Int)=>["i32.trunc_f32_s",1]
)