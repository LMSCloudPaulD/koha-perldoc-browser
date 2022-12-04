const currentBranch = "master";

/** Insert a heading for our browser */
const heading = document.querySelector("body > h1");
heading.innerHTML = `${currentBranch}`;
heading.className = "meta-koha-heading";

/** Build a search bar as an entry point for
 *  full text search */
const searchBar = document.createElement("input");
searchBar.classList.add("meta-koha-search");
searchBar.placeholder = "Search...";
searchBar.id = "query";
searchBar.name = "query";

heading.insertAdjacentElement("afterend", searchBar);

const subHeadings = document.querySelectorAll("dt > a");
const subHeadingMap = {};
for (let i = 0; i < subHeadings.length; i++) {
  subHeadingMap[subHeadings[i].name] = subHeadings[i];
}

const scrollIntoNavEntry = (e) => {
  subHeadingMap[e.target.textContent].scrollIntoView();
};

const subHeadingNavigation = document.createElement("div");
subHeadingNavigation.classList.add("meta-koha-nav");
Array.from(Object.keys(subHeadingMap)).forEach((subHeading) => {
  const entry = document.createElement("a");
  entry.classList.add("meta-koha-nav-entry");
  entry.textContent = subHeading;
  entry.addEventListener("click", scrollIntoNavEntry);
  subHeadingNavigation.appendChild(entry);
});

searchBar.insertAdjacentElement("afterend", subHeadingNavigation);

const backToTop = () => {
  heading.scrollIntoView();
};

const backToTopButton = document.createElement("button");
backToTopButton.classList.add("meta-koha-nav-back-to-top");
backToTopButton.textContent = "Back to Top ⬆";
backToTopButton.addEventListener("click", backToTop);
document.body.appendChild(backToTopButton);

/** Remove useless textNodes from dds */
const dds = document.querySelectorAll("dd");
dds.forEach((dd) => {
  Array.from(dd.childNodes).forEach((node) => {
    if (node.nodeType === 3) dd.removeChild(node);
  });
});

/** Query all entries with an anchor tag and
 *  make a map out of it. */
const entries = document.querySelectorAll("a");

class Link {
  constructor(element, text) {
    this.element = element;
    this.text = text;
    this.visible = true;
  }

  highlight(query) {
    // Use the replace method to add <span> tags around the search query
    const highlighted = this.text.replace(query, "<span>" + query + "</span>");

    // Set the innerHTML of the element to the highlighted text
    this.element.innerHTML = highlighted;
  }

  toggle() {
    this.visible = !this.visible;
    this.visible
      ? this.element.classList.add("d-none")
      : this.element.classList.remove("d-none");
  }

  show() {
    this.visible = true;
    this.element.classList.remove("d-none");
  }

  hide() {
    this.visible = false;
    this.element.classList.add("d-none");
  }
}

const links = {};

entries.forEach((entry) => {
  const link = new Link(entry, entry.innerText);
  links[link.text] = link;
});

const superindexSearch = (e) => {
  const query = searchBar.value;

  Object.keys(links).forEach((link) => links[link].highlight(query));

  if (query === "") {
    Object.keys(links).forEach((link) => links[link].show());
  }

  const results = Object.keys(links).filter((key) => key.includes(query));

  const hiddenLinks = Object.keys(links).filter(
    (key) => !results.includes(key)
  );
  hiddenLinks.forEach((link) => links[link].hide());
  results.forEach((result) => links[result].show());
};

const debounce = (cb, delay = 250) => {
  let timeout;

  return (...args) => {
    clearTimeout(timeout);
    timeout = setTimeout(() => {
      cb(...args);
    }, delay);
  };
};

const throttle = (cb, delay = 250) => {
  let shouldWait = false;

  return (...args) => {
    if (shouldWait) return;

    cb(...args);
    shouldWait = true;
    setTimeout(() => {
      shouldWait = false;
    }, delay);
  };
};

searchBar.addEventListener("keyup", superindexSearch);
