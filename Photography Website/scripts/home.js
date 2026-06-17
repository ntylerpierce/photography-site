(function () {
  const list = document.getElementById('category-list');
  const preview = document.getElementById('home-preview');

  CATEGORIES.forEach(function (cat) {
    var a = document.createElement('a');
    a.href = 'gallery.html?category=' + cat.id;
    a.className = 'category-item';
    a.innerHTML =
      '<div class="category-item__name">' + cat.label + '</div>' +
      '<div class="category-item__count">' + cat.photos.length + ' photos</div>';
    list.appendChild(a);
  });

  var allSrcs = [];
  CATEGORIES.forEach(function (cat) {
    cat.photos.forEach(function (photo) { allSrcs.push(photo.src); });
  });

  function shuffle(arr) {
    for (var i = arr.length - 1; i > 0; i--) {
      var j = Math.floor(Math.random() * (i + 1));
      var tmp = arr[i]; arr[i] = arr[j]; arr[j] = tmp;
    }
  }

  var imgs = allSrcs.map(function (src) {
    var img = document.createElement('img');
    img.className = 'home__preview-img';
    img.src = src;
    preview.appendChild(img);
    return img;
  });

  var order = allSrcs.map(function (_, i) { return i; });
  shuffle(order);
  var orderIndex = 0;

  imgs[order[0]].classList.add('active');

  function cycle() {
    imgs[order[orderIndex]].classList.remove('active');
    orderIndex++;
    if (orderIndex >= order.length) {
      shuffle(order);
      orderIndex = 0;
    }
    imgs[order[orderIndex]].classList.add('active');
  }

  setInterval(cycle, 4000);
})();
