# julia2watAPI

[julia2wat](https://julia2wat.herokuapp.com) is an online version of [WebAssemblyText.jl](https://github.com/Andersgee/WebAssemblyText.jl)

## endpoints

either use the website or do a post to request to

- https://julia2wat.herokuapp.com/text
- https://julia2wat.herokuapp.com/text_barebone

## Example

```julia
julia> using HTTP
julia> juliatext = """
f(x)=x*7.0
f(3.1)
"""

julia> r = HTTP.request("POST", "https://julia2wat.herokuapp.com/text_barebone", [("Content-Type", "text/plain")], juliatext)
julia> println(String(r.body))

(func $f (export "f") (param $x f32) (result f32)
( return ( f32.mul (local.get $x) (f32.const 7.0) ) ))
```
