const example1 = `# a simple foo bar example
bar(a,b) = a*sqrt(b*2.0)

function foo(y,x)
  k = 5.1
  return y*y + bar(x*k, 3.1)
end

`

const example2 = `# you can write matrix algebra yourself
#for example y = W*x + b could look like this
function muladd(y,W,x,b)
  N = length(x)
  M = length(y)
  s = 0.0
  for i=1:M
    s = 0.0
    for j=1:N
      s += W[(j-1)*M+i]*x[j]
    end
    y[i] = s+b[i]
  end
  return nothing
end

`

const howto = `#press Ctrl+Enter to convert to webassembly text format
#muladd(rand(3,1), rand(3,4), rand(4,1), rand(3,1))
foo(1.0, 2.0)`

function setup() {
  window.editor = ace.edit("editor");

  var JuliaMode = ace.require("ace/mode/julia").Mode;
  editor.session.setMode(new JuliaMode());
  editor.setTheme("ace/theme/monokai");
  //go here for other themes and modes:
  //https://github.com/ajaxorg/ace-builds/tree/master/src

  editor.session.setOptions({
    tabSize: 2,
    useSoftTabs: true,
  });
  editor.setFontSize("18pt");

  editor.setValue(example1 + example2 + howto,1);

  //document.getElementById("but").addEventListener("click", julia2wat);
  wat_text = document.getElementById("wat_text");
}

async function fetchwat(text) {
    return await fetch("/text", {
    method: "POST",
    cache: "reload",
    credentials: "omit",
    headers: {
      "Content-Type": "text/plain",
      charset: "utf-8",
    },
    body: text,
  }).then(res=>res.text());
}

function julia2wat() {
  fetchwat(editor.getValue()).then((wat) => {
    wat_text.innerHTML = wat
    Prism.highlightElement(wat_text);
    //Prism.highlightAll();
  });
}

window.addEventListener("keydown", (e) => {
  if (e.ctrlKey && e.keyCode === 13) {
    julia2wat();
  }
})

window.onload = setup();
