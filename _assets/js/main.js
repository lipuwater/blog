(function(){
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

  var sidebar = document.querySelector('.sidebar');

  document.querySelector('.sidebar-toggle').onclick = function(){
    if (sidebar.className.indexOf('active') != -1) {
      sidebar.className = 'sidebar';
    }
    else {
      sidebar.className = 'sidebar active';
    }
  };
})();
