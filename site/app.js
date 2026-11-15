const button = document.querySelector("[data-copy]");
const status = document.querySelector(".copy-status");

function legacyCopy(text) {
  const area = document.createElement("textarea");
  area.value = text;
  area.setAttribute("readonly", "");
  area.style.position = "fixed";
  area.style.top = "-1000px";
  document.body.appendChild(area);
  area.select();
  const copied = document.execCommand("copy");
  document.body.removeChild(area);
  if (!copied) throw new Error("copy rejected");
}

async function copyText(text) {
  const clipboard = navigator.clipboard;
  if (clipboard && window.isSecureContext) {
    try {
      await Promise.race([
        clipboard.writeText(text),
        new Promise((resolve, reject) => setTimeout(() => reject(new Error("timeout")), 1500)),
      ]);
      return;
    } catch (error) {
      // Permission denied or a silent stall: fall back to the selection copy.
    }
  }
  legacyCopy(text);
}

if (button && status) {
  button.addEventListener("click", async () => {
    const source = document.getElementById(button.dataset.copy);
    const text = source ? source.textContent.trim() : "";
    button.disabled = true;
    try {
      await copyText(text);
      status.textContent = "Commands copied to the clipboard.";
    } catch (error) {
      status.textContent = "Copy failed. Select the commands above and copy them manually.";
    } finally {
      button.disabled = false;
    }
  });
}
