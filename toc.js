// Populate the sidebar
//
// This is a script, and not included directly in the page, to control the total size of the book.
// The TOC contains an entry for each page, so if each page includes a copy of the TOC,
// the total size of the page becomes O(n**2).
class MDBookSidebarScrollbox extends HTMLElement {
    constructor() {
        super();
    }
    connectedCallback() {
        this.innerHTML = '<ol class="chapter"><li class="chapter-item expanded "><a href="install.html"><strong aria-hidden="true">1.</strong> Install</a></li><li class="chapter-item expanded "><a href="cli.html"><strong aria-hidden="true">2.</strong> CLI</a></li><li class="chapter-item expanded "><a href="wiki.html"><strong aria-hidden="true">3.</strong> Wiki</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="cheatsheet/summary.html"><strong aria-hidden="true">3.1.</strong> Cheatsheet</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="cheatsheet/primitives.html"><strong aria-hidden="true">3.1.1.</strong> primitives</a></li><li class="chapter-item expanded "><a href="cheatsheet/sounds.html"><strong aria-hidden="true">3.1.2.</strong> sounds</a></li><li class="chapter-item expanded "><a href="cheatsheet/icons.html"><strong aria-hidden="true">3.1.3.</strong> custom icons</a></li></ol></li><li class="chapter-item expanded "><a href="patterns/summary.html"><strong aria-hidden="true">3.2.</strong> Patterns</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="patterns/systems.html"><strong aria-hidden="true">3.2.1.</strong> Systems</a></li><li class="chapter-item expanded "><a href="patterns/callbacks.html"><strong aria-hidden="true">3.2.2.</strong> Callbacks</a></li><li class="chapter-item expanded "><a href="patterns/events.html"><strong aria-hidden="true">3.2.3.</strong> Events</a></li><li class="chapter-item expanded "><a href="patterns/blackboards.html"><strong aria-hidden="true">3.2.4.</strong> Blackboards</a></li><li class="chapter-item expanded "><a href="patterns/listeners.html"><strong aria-hidden="true">3.2.5.</strong> Listeners</a></li><li class="chapter-item expanded "><a href="patterns/tasks.html"><strong aria-hidden="true">3.2.6.</strong> Tasks</a></li><li class="chapter-item expanded "><a href="patterns/effectors.html"><strong aria-hidden="true">3.2.7.</strong> Effectors</a></li><li class="chapter-item expanded "><a href="patterns/scriptables.html"><strong aria-hidden="true">3.2.8.</strong> Scriptables</a></li></ol></li><li class="chapter-item expanded "><a href="troubleshooting.html"><strong aria-hidden="true">3.3.</strong> Troubleshooting</a></li></ol></li><li class="chapter-item expanded "><a href="mod.html"><strong aria-hidden="true">4.</strong> Mod mechanics</a></li><li class="chapter-item expanded "><a href="travelog/summary.html"><strong aria-hidden="true">5.</strong> Travelog</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="travelog/2023-01-21.html"><strong aria-hidden="true">5.1.</strong> 2023-01-21</a></li><li class="chapter-item expanded "><a href="travelog/2023-01-22.html"><strong aria-hidden="true">5.2.</strong> 2023-01-22</a></li><li class="chapter-item expanded "><a href="travelog/2023-01-24.html"><strong aria-hidden="true">5.3.</strong> 2023-01-24</a></li><li class="chapter-item expanded "><a href="travelog/2023-01-25.html"><strong aria-hidden="true">5.4.</strong> 2023-01-25</a></li><li class="chapter-item expanded "><a href="travelog/2023-01-27.html"><strong aria-hidden="true">5.5.</strong> 2023-01-27</a></li><li class="chapter-item expanded "><a href="travelog/2023-01-29.html"><strong aria-hidden="true">5.6.</strong> 2023-01-29</a></li><li class="chapter-item expanded "><a href="travelog/2023-01-30.html"><strong aria-hidden="true">5.7.</strong> 2023-01-30</a></li><li class="chapter-item expanded "><a href="travelog/2023-01-31.html"><strong aria-hidden="true">5.8.</strong> 2023-01-31</a></li><li class="chapter-item expanded "><a href="travelog/2023-02-03.html"><strong aria-hidden="true">5.9.</strong> 2023-02-03</a></li><li class="chapter-item expanded "><a href="travelog/2023-02-04.html"><strong aria-hidden="true">5.10.</strong> 2023-02-04</a></li><li class="chapter-item expanded "><a href="travelog/2023-02-06.html"><strong aria-hidden="true">5.11.</strong> 2023-02-06</a></li><li class="chapter-item expanded "><a href="travelog/2023-02-07.html"><strong aria-hidden="true">5.12.</strong> 2023-02-07</a></li><li class="chapter-item expanded "><a href="travelog/2023-02-10.html"><strong aria-hidden="true">5.13.</strong> 2023-02-10</a></li><li class="chapter-item expanded "><a href="travelog/2023-03-17.html"><strong aria-hidden="true">5.14.</strong> 2023-03-17</a></li><li class="chapter-item expanded "><a href="travelog/2023-03-31.html"><strong aria-hidden="true">5.15.</strong> 2023-03-31</a></li><li class="chapter-item expanded "><a href="travelog/2023-04-07.html"><strong aria-hidden="true">5.16.</strong> 2023-04-07</a></li></ol></li></ol>';
        // Set the current, active page, and reveal it if it's hidden
        let current_page = document.location.href.toString().split("#")[0];
        if (current_page.endsWith("/")) {
            current_page += "index.html";
        }
        var links = Array.prototype.slice.call(this.querySelectorAll("a"));
        var l = links.length;
        for (var i = 0; i < l; ++i) {
            var link = links[i];
            var href = link.getAttribute("href");
            if (href && !href.startsWith("#") && !/^(?:[a-z+]+:)?\/\//.test(href)) {
                link.href = path_to_root + href;
            }
            // The "index" page is supposed to alias the first chapter in the book.
            if (link.href === current_page || (i === 0 && path_to_root === "" && current_page.endsWith("/index.html"))) {
                link.classList.add("active");
                var parent = link.parentElement;
                if (parent && parent.classList.contains("chapter-item")) {
                    parent.classList.add("expanded");
                }
                while (parent) {
                    if (parent.tagName === "LI" && parent.previousElementSibling) {
                        if (parent.previousElementSibling.classList.contains("chapter-item")) {
                            parent.previousElementSibling.classList.add("expanded");
                        }
                    }
                    parent = parent.parentElement;
                }
            }
        }
        // Track and set sidebar scroll position
        this.addEventListener('click', function(e) {
            if (e.target.tagName === 'A') {
                sessionStorage.setItem('sidebar-scroll', this.scrollTop);
            }
        }, { passive: true });
        var sidebarScrollTop = sessionStorage.getItem('sidebar-scroll');
        sessionStorage.removeItem('sidebar-scroll');
        if (sidebarScrollTop) {
            // preserve sidebar scroll position when navigating via links within sidebar
            this.scrollTop = sidebarScrollTop;
        } else {
            // scroll sidebar to current active section when navigating via "next/previous chapter" buttons
            var activeSection = document.querySelector('#sidebar .active');
            if (activeSection) {
                activeSection.scrollIntoView({ block: 'center' });
            }
        }
        // Toggle buttons
        var sidebarAnchorToggles = document.querySelectorAll('#sidebar a.toggle');
        function toggleSection(ev) {
            ev.currentTarget.parentElement.classList.toggle('expanded');
        }
        Array.from(sidebarAnchorToggles).forEach(function (el) {
            el.addEventListener('click', toggleSection);
        });
    }
}
window.customElements.define("mdbook-sidebar-scrollbox", MDBookSidebarScrollbox);
