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
    `function kek(x)
  return x*7;
end

kek(4.1);`,
    1
  );

  but = document.getElementById("but");
  but.addEventListener("click", julia2wat);
  wat_text = document.getElementById("wat_text");
}

async function fetchwat(text) {
  //return await fetch("https://julia2wat.herokuapp.com/text", {
    return await fetch("/text", {
    method: "POST",
    cache: "reload", // *default, no-cache, reload, force-cache, only-if-cached
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
    console.log("wat: ", wat);
    wat_text.innerHTML = wat;
  });

  console.log("editor.getValue(): ", editor.getValue());

  /*
  let text = editor.getValue();
  console.log("text:", text);
  editor.getValue()
  //HTTP.request("POST", "https://julia2wat.herokuapp.com/text", [("Content-Type", "text/plain")], """f(x)=x*7; f(3.1)""")

  var xhr = new XMLHttpRequest();
  xhr.open("POST", "https://julia2wat.herokuapp.com/text", true);
  xhr.setRequestHeader("Content-Type", "text/plain");
  xhr.send(editor.getValue());

  fetch("https://julia2wat.herokuapp.com/text", {
    method: "POST",
    headers: { "Content-Type": "text/plain" },
    body: editor.getValue(),
  }).then((res) => {
    console.log("Request complete! response:", res);
  });
  */
}

window.onload = setup();
