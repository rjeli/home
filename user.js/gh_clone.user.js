// ==UserScript==
// @name        gh_clone
// @description clone a github repo and open in zed
// @match       *://github.com/*
// @inject-into content
// @grant       GM.xmlHttpRequest
// ==/UserScript==

const loc = new URL(document.location.href);
console.log(`Loaded gh_clone [${loc}]`);

const $ = (sel) => document.querySelector(sel);

// Extract repo owner and name from GitHub URL
function getRepoInfo() {
    const pathParts = window.location.pathname.split('/').filter(part => part.length > 0);
    
    if (pathParts.length >= 2) {
        return {
            owner: pathParts[0],
            name: pathParts[1],
            url: `https://github.com/${pathParts[0]}/${pathParts[1]}`
        };
    }
    
    return null;
}

// Send request to localhost daemon
function openInZed(repoInfo, button) {
    GM.xmlHttpRequest({
        method: 'POST',
        url: 'http://localhost:8080/open-repo',
        headers: {
            'Content-Type': 'application/json'
        },
        data: JSON.stringify(repoInfo),
        onload: function(response) {
            console.log('Repo open request sent:', response.status);
            if (response.status === 200) {
                button.textContent = 'Opened!';
                setTimeout(() => {
                    button.textContent = 'Open in Zed';
                }, 2000);
            }
        },
        onerror: function(error) {
            console.error('Failed to send repo open request:', error);
            button.textContent = 'Error';
            setTimeout(() => {
                button.textContent = 'Open in Zed';
            }, 2000);
        }
    });
}

// Create and inject the button
function createButton() {
    const button = document.createElement('button');
    button.textContent = 'Open in Zed';
    button.id = 'zed-opener-button';
    button.style.cssText = `
        margin-right: 8px;
        padding: 5px 12px;
        background-color: #238636;
        color: white;
        border: 1px solid #238636;
        border-radius: 6px;
        font-size: 14px;
        font-weight: 500;
        cursor: pointer;
        transition: background-color 0.2s;
    `;

    button.addEventListener('mouseenter', () => {
        button.style.backgroundColor = '#2ea043';
    });

    button.addEventListener('mouseleave', () => {
        button.style.backgroundColor = '#238636';
    });

    button.addEventListener('click', () => {
        const repoInfo = getRepoInfo();
        if (repoInfo) {
            button.textContent = 'Opening...';
            openInZed(repoInfo, button);
        }
    });

    return button;
}

// Inject button
function injectButton() {
    const repoInfo = getRepoInfo();
    if (!repoInfo) return false;

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
    // Try to inject immediately
    if (injectButton()) return;

    // If immediate injection fails, wait for page to load
    const observer = new MutationObserver((mutations, obs) => {
        if (injectButton()) {
            obs.disconnect();
        }
    });

    observer.observe(document.body, {
        childList: true,
        subtree: true
    });

    // Stop observing after 10 seconds
    setTimeout(() => observer.disconnect(), 10000);
}

// Handle navigation changes (SPA)
let currentUrl = window.location.href;
new MutationObserver(() => {
    if (window.location.href !== currentUrl) {
        currentUrl = window.location.href;
        // Remove existing button
        const existingButton = $("#zed-opener-button");
        if (existingButton) {
            existingButton.remove();
        }
        // Reinitialize
        setTimeout(init, 500);
    }
}).observe(document.body, { childList: true, subtree: true });

// Initial load
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
} else {
    init();
}