// CerberusChain - Advanced Interactive Features

class CerberusChain {
  constructor() {
    this.init();
  }

  init() {
    this.setupSmoothScrolling();
    this.setupNavigation();
    this.setupAnimations();
    this.setupNeuralNetwork();
    this.setupCounters();
    this.setupParticles();
    this.setupScrollEffects();
    this.setupPerformanceIndicators();
    this.setupMobileMenu();
  }

  // Smooth scrolling for navigation links
  setupSmoothScrolling() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
      anchor.addEventListener('click', (e) => {
        e.preventDefault();
        const target = document.querySelector(anchor.getAttribute('href'));
        if (target) {
          target.scrollIntoView({
            behavior: 'smooth',
            block: 'start'
          });
        }
      });
    });
  }

  // Navigation effects
  setupNavigation() {
    const navbar = document.querySelector('.navbar');
    let lastScrollY = window.scrollY;

    window.addEventListener('scroll', () => {
      const currentScrollY = window.scrollY;
      
      // Add/remove scrolled class
      if (currentScrollY > 100) {
        navbar.classList.add('scrolled');
      } else {
        navbar.classList.remove('scrolled');
      }

      // Hide/show navbar on scroll
      if (currentScrollY > lastScrollY && currentScrollY > 100) {
        navbar.style.transform = 'translateY(-100%)';
      } else {
        navbar.style.transform = 'translateY(0)';
      }

      lastScrollY = currentScrollY;
    });
  }

  // Intersection Observer for animations
  setupAnimations() {
    const observerOptions = {
      threshold: 0.1,
      rootMargin: '0px 0px -50px 0px'
    };

    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('visible');
        }
      });
    }, observerOptions);

    // Observe elements for animation
    document.querySelectorAll('.animate-on-scroll').forEach(el => {
      observer.observe(el);
    });

    // Add animate-on-scroll class to various elements
    document.querySelectorAll('.feature-card, .roadmap-phase, .community-card').forEach(el => {
      el.classList.add('animate-on-scroll');
    });
  }

  // Neural network canvas animation
  setupNeuralNetwork() {
    const canvas = document.getElementById('neural-network');
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    let animationId;

    const resizeCanvas = () => {
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
    };

    resizeCanvas();
    window.addEventListener('resize', resizeCanvas);

    // Neural network nodes and connections
    const nodes = [];
    const connections = [];
    const nodeCount = 50;

    // Create nodes
    for (let i = 0; i < nodeCount; i++) {
      nodes.push({
        x: Math.random() * canvas.width,
        y: Math.random() * canvas.height,
        vx: (Math.random() - 0.5) * 0.5,
        vy: (Math.random() - 0.5) * 0.5,
        radius: Math.random() * 3 + 1
      });
    }

    // Animation loop
    const animate = () => {
      ctx.clearRect(0, 0, canvas.width, canvas.height);

      // Update and draw nodes
      nodes.forEach((node, i) => {
        // Update position
        node.x += node.vx;
        node.y += node.vy;

        // Bounce off edges
        if (node.x < 0 || node.x > canvas.width) node.vx *= -1;
        if (node.y < 0 || node.y > canvas.height) node.vy *= -1;

        // Draw node
        ctx.beginPath();
        ctx.arc(node.x, node.y, node.radius, 0, Math.PI * 2);
        ctx.fillStyle = 'rgba(0, 245, 255, 0.6)';
        ctx.fill();

        // Draw connections to nearby nodes
        nodes.slice(i + 1).forEach(otherNode => {
          const dx = node.x - otherNode.x;
          const dy = node.y - otherNode.y;
          const distance = Math.sqrt(dx * dx + dy * dy);

          if (distance < 150) {
            ctx.beginPath();
            ctx.moveTo(node.x, node.y);
            ctx.lineTo(otherNode.x, otherNode.y);
            ctx.strokeStyle = `rgba(0, 245, 255, ${0.3 * (1 - distance / 150)})`;
            ctx.lineWidth = 1;
            ctx.stroke();
          }
        });
      });

      animationId = requestAnimationFrame(animate);
    };

    animate();

    // Cleanup on page unload
    window.addEventListener('beforeunload', () => {
      cancelAnimationFrame(animationId);
    });
  }

  // Animated counters
  setupCounters() {
    const counters = document.querySelectorAll('.stat-number');
    
    const animateCounter = (counter) => {
      const target = parseInt(counter.getAttribute('data-target'));
      const duration = 2000;
      const start = performance.now();

      const updateCounter = (currentTime) => {
        const elapsed = currentTime - start;
        const progress = Math.min(elapsed / duration, 1);
        
        // Easing function
        const easeOutQuart = 1 - Math.pow(1 - progress, 4);
        const current = Math.floor(easeOutQuart * target);
        
        counter.textContent = current.toLocaleString();

        if (progress < 1) {
          requestAnimationFrame(updateCounter);
        }
      };

      requestAnimationFrame(updateCounter);
    };

    const counterObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          animateCounter(entry.target);
          counterObserver.unobserve(entry.target);
        }
      });
    });

    counters.forEach(counter => {
      counterObserver.observe(counter);
    });
  }

  // Floating particles system
  setupParticles() {
    const createParticle = () => {
      const particle = document.createElement('div');
      particle.className = 'floating-particle';
      particle.style.cssText = `
        position: fixed;
        width: 4px;
        height: 4px;
        background: #00f5ff;
        border-radius: 50%;
        pointer-events: none;
        z-index: -1;
        box-shadow: 0 0 10px #00f5ff;
        left: ${Math.random() * 100}vw;
        top: 100vh;
        animation: particle-rise ${5 + Math.random() * 5}s linear forwards;
      `;

      document.body.appendChild(particle);

      // Remove particle after animation
      setTimeout(() => {
        particle.remove();
      }, 10000);
    };

    // Create particles periodically
    setInterval(createParticle, 2000);

    // Add CSS for particle animation
    const style = document.createElement('style');
    style.textContent = `
      @keyframes particle-rise {
        to {
          transform: translateY(-100vh) rotate(360deg);
          opacity: 0;
        }
      }
    `;
    document.head.appendChild(style);
  }

  // Scroll-based effects
  setupScrollEffects() {
    let ticking = false;

    const updateScrollEffects = () => {
      const scrolled = window.pageYOffset;
      const rate = scrolled * -0.5;

      // Parallax effect for hero background
      const hero = document.querySelector('.hero');
      if (hero) {
        hero.style.transform = `translateY(${rate}px)`;
      }

      // Update energy rings rotation
      const rings = document.querySelectorAll('.ring');
      rings.forEach((ring, index) => {
        const rotation = scrolled * (0.1 + index * 0.05);
        ring.style.transform = `rotate(${rotation}deg)`;
      });

      ticking = false;
    };

    const requestScrollUpdate = () => {
      if (!ticking) {
        requestAnimationFrame(updateScrollEffects);
        ticking = true;
      }
    };

    window.addEventListener('scroll', requestScrollUpdate);
  }

  // Performance indicators animation
  setupPerformanceIndicators() {
    const indicators = document.querySelectorAll('.indicator-fill');
    
    const animateIndicator = (indicator) => {
      const percentage = indicator.getAttribute('data-percentage');
      indicator.style.width = '0%';
      
      setTimeout(() => {
        indicator.style.transition = 'width 2s ease-out';
        indicator.style.width = percentage + '%';
      }, 500);
    };

    const indicatorObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          animateIndicator(entry.target);
          indicatorObserver.unobserve(entry.target);
        }
      });
    });

    indicators.forEach(indicator => {
      indicatorObserver.observe(indicator);
    });
  }

  // Mobile menu functionality
  setupMobileMenu() {
    const toggle = document.querySelector('.mobile-menu-toggle');
    const navMenu = document.querySelector('.nav-menu');
    
    if (toggle && navMenu) {
      toggle.addEventListener('click', () => {
        toggle.classList.toggle('active');
        navMenu.classList.toggle('active');
      });
    }
  }
}

// Matrix rain effect
class MatrixRain {
  constructor() {
    this.canvas = document.createElement('canvas');
    this.ctx = this.canvas.getContext('2d');
    this.canvas.id = 'matrix-rain';
    this.canvas.style.cssText = `
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      pointer-events: none;
      z-index: -1;
      opacity: 0.1;
    `;
    
    document.body.appendChild(this.canvas);
    this.init();
  }

  init() {
    this.resize();
    window.addEventListener('resize', () => this.resize());
    
    this.columns = Math.floor(this.canvas.width / 20);
    this.drops = new Array(this.columns).fill(1);
    
    this.animate();
  }

  resize() {
    this.canvas.width = window.innerWidth;
    this.canvas.height = window.innerHeight;
  }

  animate() {
    this.ctx.fillStyle = 'rgba(10, 10, 15, 0.05)';
    this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
    
    this.ctx.fillStyle = '#00f5ff';
    this.ctx.font = '15px monospace';
    
    for (let i = 0; i < this.drops.length; i++) {
      const text = String.fromCharCode(Math.random() * 128);
      this.ctx.fillText(text, i * 20, this.drops[i] * 20);
      
      if (this.drops[i] * 20 > this.canvas.height && Math.random() > 0.975) {
        this.drops[i] = 0;
      }
      this.drops[i]++;
    }
    
    requestAnimationFrame(() => this.animate());
  }
}

// Cyber glitch effect
class GlitchEffect {
  constructor(element) {
    this.element = element;
    this.originalText = element.textContent;
    this.chars = '!<>-_\\/[]{}—=+*^?#________';
    this.isGlitching = false;
  }

  glitch(duration = 1000) {
    if (this.isGlitching) return;
    
    this.isGlitching = true;
    const iterations = duration / 50;
    let currentIteration = 0;

    const glitchInterval = setInterval(() => {
      this.element.textContent = this.originalText
        .split('')
        .map((char, index) => {
          if (index < currentIteration) {
            return this.originalText[index];
          }
          return this.chars[Math.floor(Math.random() * this.chars.length)];
        })
        .join('');

      if (currentIteration >= this.originalText.length) {
        clearInterval(glitchInterval);
        this.element.textContent = this.originalText;
        this.isGlitching = false;
      }

      currentIteration += 1 / 3;
    }, 50);
  }
}

// Initialize everything when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  // Initialize main application
  new CerberusChain();
  
  // Initialize matrix rain effect
  new MatrixRain();
  
  // Add glitch effect to titles
  document.querySelectorAll('.hero-title, .section-title').forEach(title => {
    const glitch = new GlitchEffect(title);
    
    title.addEventListener('mouseenter', () => {
      glitch.glitch(800);
    });
  });

  // Add scanning line effect
  const scanLine = document.createElement('div');
  scanLine.className = 'scan-line';
  document.body.appendChild(scanLine);

  // Cyber cursor effect
  const cursor = document.createElement('div');
  cursor.style.cssText = `
    position: fixed;
    width: 20px;
    height: 20px;
    border: 2px solid #00f5ff;
    border-radius: 50%;
    pointer-events: none;
    z-index: 9999;
    mix-blend-mode: difference;
    transition: transform 0.1s ease;
  `;
  document.body.appendChild(cursor);

  document.addEventListener('mousemove', (e) => {
    cursor.style.left = e.clientX - 10 + 'px';
    cursor.style.top = e.clientY - 10 + 'px';
  });

  // Scale cursor on hover over interactive elements
  document.querySelectorAll('a, button, .btn').forEach(el => {
    el.addEventListener('mouseenter', () => {
      cursor.style.transform = 'scale(1.5)';
    });
    
    el.addEventListener('mouseleave', () => {
      cursor.style.transform = 'scale(1)';
    });
  });

  // Add loading screen
  const loadingScreen = document.createElement('div');
  loadingScreen.style.cssText = `
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: #0a0a0f;
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 10000;
    transition: opacity 0.5s ease;
  `;
  
  loadingScreen.innerHTML = `
    <div class="cyber-spinner"></div>
  `;
  
  document.body.appendChild(loadingScreen);

  // Remove loading screen after page load
  window.addEventListener('load', () => {
    setTimeout(() => {
      loadingScreen.style.opacity = '0';
      setTimeout(() => {
        loadingScreen.remove();
      }, 500);
    }, 1000);
  });

  // Add performance monitoring
  if ('performance' in window) {
    window.addEventListener('load', () => {
      const loadTime = performance.timing.loadEventEnd - performance.timing.navigationStart;
      console.log(`🚀 CerberusChain loaded in ${loadTime}ms`);
    });
  }
});

// Service Worker for offline functionality
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js')
      .then(registration => {
        console.log('SW registered: ', registration);
      })
      .catch(registrationError => {
        console.log('SW registration failed: ', registrationError);
      });
  });
}

// Export for potential module usage
window.CerberusChain = CerberusChain;