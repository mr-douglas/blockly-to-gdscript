const editor = document.querySelector("[data-platformer-editor]");
const observer = new ResizeObserver(([entry]) => {
  editor.style.height = `${Math.ceil(entry.target.getBoundingClientRect().height) + 2}px`;
});

function fitEditor() {
  observer.disconnect();
  const content = editor.contentDocument?.querySelector("main");
  if (content) observer.observe(content);
}

editor.addEventListener("load", fitEditor);
fitEditor();
