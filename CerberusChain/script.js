// File: script.js

// Smooth-scroll for internal nav links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
  anchor.addEventListener('click', e => {
    e.preventDefault();
    document.querySelector(anchor.getAttribute('href'))
            .scrollIntoView({ behavior: 'smooth' });
  });
});
