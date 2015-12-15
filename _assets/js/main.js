//=require highlight.pack.js

hljs.initHighlightingOnLoad();

if (/team.html/.test(location.href)) {
  document.body.onclick = function(event) {
    var li;
    var node = event.target;
    while (node.parentNode) {
      console.log(node);
      if (node.tagName.toLowerCase() == 'li' && node.parentNode.className.indexOf('author-list') != -1) {
        li = node;
        break;
      }
      else {
        node = node.parentNode;
      }
    }

    if (li) {
      location.href = li.querySelector('a').href;
    }
  }
}
