// Efeito de rastro do cursor customizado

class CursorTrail {
  constructor() {
    this.trail = [];
    this.maxTrail = 20;
    this.container = document.getElementById('cursor-trail');
    this.isTouch = 'ontouchstart' in window;
    
    this.mouseX = 0;
    this.mouseY = 0;
    this.hasMoved = false;
    
    if (!this.isTouch && this.container) {
      this.init();
    }
  }
  
  init() {
    // Cria as partículas do rastro
    for (let i = 0; i < this.maxTrail; i++) {
      const dot = document.createElement('div');
      dot.className = 'cursor-dot';
      dot.style.opacity = (1 - i / this.maxTrail) * 0.5;
      dot.style.position = 'fixed';
      dot.style.top = '0';
      dot.style.left = '0';
      dot.style.transform = 'translate(-9999px, -9999px)'; // some fora da tela até o primeiro movimento
      dot.style.pointerEvents = 'none';
      this.container.appendChild(dot);
      this.trail.push({ el: dot, x: 0, y: 0 });
    }
    
    // Rastreia a posição do mouse
    document.addEventListener('mousemove', (e) => {
      this.mouseX = e.clientX;
      this.mouseY = e.clientY;
      this.hasMoved = true;
    });
    
    // Loop de animação suave
    requestAnimationFrame(() => this.animate());
  }
  
  animate() {
    if (this.hasMoved) {
      // Cada ponto persegue o ponto anterior, criando o efeito de rastro suave
      let targetX = this.mouseX;
      let targetY = this.mouseY;
      
      for (let i = 0; i < this.trail.length; i++) {
        const dot = this.trail[i];
        dot.x += (targetX - dot.x) * 0.3;
        dot.y += (targetY - dot.y) * 0.3;
        dot.el.style.transform = `translate(${dot.x}px, ${dot.y}px)`;
        
        targetX = dot.x;
        targetY = dot.y;
      }
    }
    
    requestAnimationFrame(() => this.animate());
  }
}

// Inicializa ao carregar a página
document.addEventListener('DOMContentLoaded', () => {
  // Verifica a preferência de movimento reduzido
  const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  
  if (!prefersReducedMotion) {
    new CursorTrail();
  }
});