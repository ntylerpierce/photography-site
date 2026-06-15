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

  var imgs = CATEGORIES.map(function (cat, i) {
    var img = document.createElement('img');
    img.className = 'home__preview-img';
    img.src = cat.cover;
    img.alt = cat.label;
    if (i === 0) img.classList.add('active');
    preview.appendChild(img);
    return img;
  });

  var current = 0;

  function cycle() {
    imgs[current].classList.remove('active');
    current = (current + 1) % imgs.length;
    imgs[current].classList.add('active');
  }

  setInterval(cycle, 4000);
})();
