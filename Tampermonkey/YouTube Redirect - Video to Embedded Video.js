// ==UserScript==
// @name         YouTube Video to Embed Redirect
// @namespace    http://tampermonkey.net/
// @version      1.4
// @description  Redirect YouTube video pages to embed pages
// @match        https://www.youtube.com/*
// @run-at       document-start
// @grant        none
// ==/UserScript==

(function() {
    'use strict';

    // Function to redirect to embed URL
    function redirectToEmbed() {
        let currentUrl = window.location.href;
        let newUrl = currentUrl;

        if (newUrl.includes('/watch?v=')) {
            newUrl = newUrl.replace('/watch?v=', '/embed/');
        }

        // Remove any substring starting with '&'
        if (newUrl.includes('&')) {
            newUrl = newUrl.replace(/&[^&]*$/, '');
        }

        if (newUrl !== currentUrl) {
            window.location.replace(newUrl);
        }
    }

    // Initial check
    redirectToEmbed();

    // Observe URL changes
    const observer = new MutationObserver(() => {
        redirectToEmbed();
    });

    observer.observe(document, { subtree: true, childList: true });
})();