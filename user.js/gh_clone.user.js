// ==UserScript==
// @name        gh_clone
// @description clone a github repo and open in zed
// @match       *://github.com/*
// @inject-into content
// @grant       GM.xmlHttpRequest
// ==/UserScript==

const $ = (sel) => document.querySelector(sel);

// Send current page URL to localhost daemon
function openInZed(button) {
  let lastProcessedLength = 0;

  GM.xmlHttpRequest({
    method: "POST",
    url: "http://localhost:8080/open-repo",
    headers: {
      "Content-Type": "application/json",
    },
    data: JSON.stringify({ href: window.location.href }),
    onreadystatechange: function (response) {
      if (response.readyState === 3 || response.readyState === 4) {
        const newData = response.responseText.slice(lastProcessedLength);
        lastProcessedLength = response.responseText.length;

        const lines = newData.split("\n").filter((line) => line.trim());
        for (const line of lines) {
          try {
            const statusUpdate = JSON.parse(line);
            if (statusUpdate.text) {
              button.textContent = statusUpdate.text;
            }
          } catch (e) {
            // Ignore malformed JSON lines
          }
        }

        if (response.readyState === 4) {
          // Connection closed, keep last text for 3 seconds
          setTimeout(() => {
            button.textContent = "Open locally";
          }, 3000);
        }
      }
    },
    onerror: function (error) {
      console.error("Failed to send repo open request:", error);
      button.textContent = "Error";
      setTimeout(() => {
        button.textContent = "Open locally";
      }, 3000);
    },
  });
}

// Create the button
function createButton() {
  const button = document.createElement("button");
  button.textContent = "Open locally";
  button.id = "zed-opener-button";
  button.style.cssText = `
        margin-right: 8px;
        padding: 5px 12px;
        background-color: #238c83;
        color: white;
        border: 1px solid #238c83;
        border-radius: 6px;
        font-size: 14px;
        font-weight: 500;
        cursor: pointer;
        transition: background-color 0.2s;
    `;

  /*
  button.addEventListener("mouseenter", () => {
    button.style.backgroundColor = "#a3a328";
  });

  button.addEventListener("mouseleave", () => {
    button.style.backgroundColor = "#8c8c23";
  });
  */

  button.addEventListener("click", () => {
    button.textContent = "Opening...";
    openInZed(button);
  });

  return button;
}

// Inject button
function injectButton() {
  const $barEnd = $(".AppHeader-globalBar-end");
  if ($barEnd && !$("#zed-opener-button")) {
    const button = createButton();
    $barEnd.insertBefore(button, $barEnd.firstChild);
    return true;
  }
  return false;
}

// Initialize
function init() {
  if (injectButton()) return;

  const observer = new MutationObserver((mutations, obs) => {
    if (injectButton()) {
      obs.disconnect();
    }
  });

  observer.observe(document.body, {
    childList: true,
    subtree: true,
  });

  setTimeout(() => observer.disconnect(), 10000);
}

// Handle navigation changes
let currentUrl = window.location.href;
new MutationObserver(() => {
  if (window.location.href !== currentUrl) {
    currentUrl = window.location.href;
    const existingButton = $("#zed-opener-button");
    if (existingButton) {
      existingButton.remove();
    }
    setTimeout(init, 500);
  }
}).observe(document.body, { childList: true, subtree: true });

// Initial load
if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", init);
} else {
  init();
}
