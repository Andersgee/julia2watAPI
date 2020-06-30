# julia2watAPI
either go to http://julia2wat.herokuapp.com/
or do a post request:

```julia
using HTTP

juliatext = """
f(x)=x*7
f(3.1)
"""

HTTP.request("POST", "https://julia2wat.herokuapp.com/text", [("Content-Type", "text/plain")], juliatext)
```
response body:
```wat
(module

(func $f (export "f") (param $x f32) (result f32)
( f32.mul (local.get $x) (i32.const 7) ) 
)

)

;;evaluated by Julia to: 21.7"""
```
