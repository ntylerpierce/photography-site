(function () {
  var params = new URLSearchParams(window.location.search);
  var categoryId = params.get('category') || CATEGORIES[0].id;
  var category = CATEGORIES.find(function (c) { return c.id === categoryId; }) || CATEGORIES[0];

  var navLogo = document.getElementById('nav-logo');
  var navCategoriesEl = document.getElementById('nav-categories');
  var galleryTitle = document.getElementById('gallery-title');
  var grid = document.getElementById('photo-grid');

  document.title = category.label + ' — Portfolio';
  galleryTitle.textContent = category.label;

  // Build nav category links
  CATEGORIES.forEach(function (cat) {
    var li = document.createElement('li');
    var a = document.createElement('a');
    a.href = 'gallery.html?category=' + cat.id;
    a.textContent = cat.label;
    if (cat.id === categoryId) a.classList.add('active');
    li.appendChild(a);
    navCategoriesEl.appendChild(li);
  });

  // Nav logo dims on scroll, returns on hover
  window.addEventListener('scroll', function () {
    if (window.scrollY > 40) {
      navLogo.classList.add('nav__logo--dim');
    } else {
      navLogo.classList.remove('nav__logo--dim');
    }
  }, { passive: true });

  navLogo.addEventListener('mouseenter', function () {
    navLogo.classList.remove('nav__logo--dim');
  });
  navLogo.addEventListener('mouseleave', function () {
    if (window.scrollY > 40) navLogo.classList.add('nav__logo--dim');
  });

  // Build photo grid
  category.photos.forEach(function (photo, i) {
    var div = document.createElement('div');
    div.className = 'grid__item';
    var img = document.createElement('img');
    img.src = photo.src;
    img.alt = photo.title;
    img.loading = 'lazy';
    div.appendChild(img);
    div.addEventListener('click', function () { openLightbox(i); });
    grid.appendChild(div);
  });

  // Lightbox
  var lightbox = document.getElementById('lightbox');
  var lbImg = document.getElementById('lb-img');
  var lbTitle = document.getElementById('lb-title');
  var lbDate = document.getElementById('lb-date');
  var lbClose = document.getElementById('lb-close');
  var lbPrev = document.getElementById('lb-prev');
  var lbNext = document.getElementById('lb-next');

  var currentIndex = 0;
  var fadeTimer = null;

  function openLightbox(index) {
    currentIndex = index;
    showPhoto(index, true);
    lightbox.classList.add('open');
    document.body.style.overflow = 'hidden';
  }

  function closeLightbox() {
    lightbox.classList.remove('open');
    document.body.style.overflow = '';
    lbImg.classList.remove('visible');
  }

  function showPhoto(index, immediate) {
    var photo = category.photos[index];
    lbImg.classList.remove('visible');

    clearTimeout(fadeTimer);
    var delay = immediate ? 0 : 150;

    fadeTimer = setTimeout(function () {
      lbImg.src = photo.src;
      lbImg.alt = photo.title;
      lbTitle.textContent = photo.title;
      lbDate.textContent = photo.date;

      if (lbImg.complete) {
        lbImg.classList.add('visible');
      } else {
        lbImg.onload = function () { lbImg.classList.add('visible'); };
      }
    }, delay);
  }

  function prevPhoto() {
    currentIndex = (currentIndex - 1 + category.photos.length) % category.photos.length;
    showPhoto(currentIndex, false);
  }

  function nextPhoto() {
    currentIndex = (currentIndex + 1) % category.photos.length;
    showPhoto(currentIndex, false);
  }

  lbClose.addEventListener('click', closeLightbox);
  lbPrev.addEventListener('click', prevPhoto);
  lbNext.addEventListener('click', nextPhoto);

  // Close on backdrop click
  lightbox.addEventListener('click', function (e) {
    if (e.target === lightbox) closeLightbox();
  });

  // Keyboard nav
  document.addEventListener('keydown', function (e) {
    if (!lightbox.classList.contains('open')) return;
    if (e.key === 'ArrowLeft') prevPhoto();
    else if (e.key === 'ArrowRight') nextPhoto();
    else if (e.key === 'Escape') closeLightbox();
  });

  // Touch swipe
  var touchStartX = 0;
  var touchStartY = 0;

  lightbox.addEventListener('touchstart', function (e) {
    touchStartX = e.changedTouches[0].clientX;
    touchStartY = e.changedTouches[0].clientY;
  }, { passive: true });

  lightbox.addEventListener('touchend', function (e) {
    var dx = e.changedTouches[0].clientX - touchStartX;
    var dy = e.changedTouches[0].clientY - touchStartY;

    if (Math.abs(dx) < 10 && Math.abs(dy) < 10) {
      // Tap on backdrop closes
      if (e.target === lightbox) closeLightbox();
    } else if (Math.abs(dx) > Math.abs(dy) && Math.abs(dx) > 40) {
      if (dx < 0) nextPhoto();
      else prevPhoto();
    }
  }, { passive: true });
})();
