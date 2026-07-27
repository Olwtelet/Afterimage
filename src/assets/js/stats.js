// Widget de estatísticas usando um contador compartilhado real (CountAPI)

class StatsWidget {
  constructor() {
    this.container = document.getElementById('stats-widget');
    this.sidebarContainer = document.getElementById('stats-widget-sidebar');
    this.hitCounter = document.getElementById('hit-counter');
    this.visitorNum = document.getElementById('visitor-num');
    
    this.apiBase = 'https://countapi.mileshilliard.com/api/v1';
    // Chave única — evita conflito com contadores de outros sites usando o mesmo serviço público
    this.key = 'filmeshdonlinegratis-com-pageviews';
    
    this.pageViews = null;
    
    this.renderLoading();
    this.fetchAndIncrement();
  }
  
  renderLoading() {
    const html = `
      <div class="terminal-stats">
        <div class="stat-line">
          <span class="stat-label">VISUALIZAÇÕES:</span>
          <span class="stat-value digital-counter">CARREGANDO...</span>
        </div>
      </div>
    `;
    
    if (this.container) this.container.innerHTML = html;
    if (this.sidebarContainer) this.sidebarContainer.innerHTML = html;
  }
  
  async fetchAndIncrement() {
    try {
      const response = await fetch(`${this.apiBase}/hit/${this.key}`);
      
      if (!response.ok) throw new Error('Falha na requisição do contador');
      
      const data = await response.json();
      this.pageViews = data.value;
    } catch (error) {
      console.warn('Contador indisponível no momento:', error);
      this.pageViews = null;
    }
    
    this.render();
    this.updateHitCounter();
  }
  
  render() {
    const displayValue = this.pageViews !== null 
      ? this.formatNumber(this.pageViews) 
      : '------';
    
    const html = `
      <div class="terminal-stats">
        <div class="stat-line">
          <span class="stat-label">VISUALIZAÇÕES:</span>
          <span class="stat-value digital-counter">${displayValue}</span>
        </div>
      </div>
    `;
    
    if (this.container) this.container.innerHTML = html;
    if (this.sidebarContainer) this.sidebarContainer.innerHTML = html;
  }
  
  updateHitCounter() {
    if (this.pageViews === null) return;
    
    if (this.hitCounter) {
      const digits = this.formatNumber(this.pageViews).split('');
      const digitElements = this.hitCounter.querySelectorAll('.counter-digit');
      digitElements.forEach((el, i) => {
        if (digits[i]) el.textContent = digits[i];
      });
    }
    
    if (this.visitorNum) {
      this.visitorNum.textContent = this.formatNumber(this.pageViews);
    }
  }
  
  formatNumber(num) {
    return num.toString().padStart(6, '0');
  }
}

document.addEventListener('DOMContentLoaded', () => {
  new StatsWidget();
});