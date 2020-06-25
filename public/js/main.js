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

  editor.setValue(
    `kek(x,y) = y*sqrt(x*2.0)

function hoj(y,x)
  for i=2:5
    y[i]=kek(x,4.1)*y[i-1]
  end
  return nothing
end

hoj(zeros(5,1), 5.1)`,1);

  but = document.getElementById("but");
  but.addEventListener("click", julia2wat);
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
