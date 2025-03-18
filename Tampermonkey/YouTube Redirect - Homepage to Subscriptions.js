// ==UserScript==
// @name         YouTube Homepage to Subscriptions Redirect
// @namespace    http://tampermonkey.net/
// @version      1.1
// @description  Redirect YouTube homepage to subscriptions page
// @match        https://www.youtube.com/*
// @run-at       document-start
// @grant        none
// ==/UserScript==

(function() {
    'use strict';

    // Function to redirect to subscriptions page
    function redirectToSubscriptions() {
        let currentUrl = window.location.href;
        // Check if the current URL is the YouTube homepage
        if (currentUrl === 'https://www.youtube.com/' || currentUrl === 'https://www.youtube.com') {
            let newUrl = 'https://www.youtube.com/feed/subscriptions';
            window.location.replace(newUrl);
        }
    }

    // Initial check
    redirectToSubscriptions();

    // Observe URL changes
    const observer = new MutationObserver(() => {
        redirectToSubscriptions();
    });

    observer.observe(document, { subtree: true, childList: true });
})();