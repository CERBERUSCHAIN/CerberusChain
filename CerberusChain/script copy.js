/* ---------------------------------------------------------------
   Cerberus Chain – tiny helpers
-----------------------------------------------------------------*/

// Smooth scrolling
document.querySelectorAll('a[href^="#"]').forEach(a=>{
  a.addEventListener('click',e=>{
    const id=a.getAttribute('href');
    const target=document.querySelector(id);
    if(target){
      e.preventDefault();
      target.scrollIntoView({behavior:'smooth'});
    }
  });
});

// Carousel index → CSS var hookup
document.querySelectorAll('.slider').forEach(slider=>{
  const items=[...slider.children];
  const qty=items.length;
  slider.style.setProperty('--quantity',qty);
  items.forEach((el,i)=> el.style.setProperty('--index',i));
});