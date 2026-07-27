const fs = require('fs');
const path = require('path');
const Terser = require('terser');
const CleanCSS = require('clean-css');

// Minifica os arquivos JS
async function minifyJS() {
  const jsDir = path.join(__dirname, '../_site/assets/js');
  const files = fs.readdirSync(jsDir).filter(f => f.endsWith('.js'));
  
  for (const file of files) {
    const filePath = path.join(jsDir, file);
    const code = fs.readFileSync(filePath, 'utf8');
    
    const result = await Terser.minify(code, {
      compress: true,
      mangle: true,
      format: {
        comments: false
      }
    });
    
    if (result.error) {
      console.error(`Erro ao minificar ${file}:`, result.error);
      continue;
    }
    
    fs.writeFileSync(filePath, result.code);
    console.log(`Minificado: ${file}`);
  }
}

// Minifica os arquivos CSS
function minifyCSS() {
  const cssDir = path.join(__dirname, '../_site/assets/css');
  const files = fs.readdirSync(cssDir).filter(f => f.endsWith('.css'));
  
  const cleanCSS = new CleanCSS({
    level: 2,
    returnPromise: true
  });
  
  for (const file of files) {
    const filePath = path.join(cssDir, file);
    const code = fs.readFileSync(filePath, 'utf8');
    
    cleanCSS.minify(code).then(result => {
      if (result.errors.length) {
        console.error(`Erro ao minificar ${file}:`, result.errors);
        return;
      }
      
      fs.writeFileSync(filePath, result.styles);
      console.log(`Minificado: ${file}`);
    });
  }
}

// Roda a minificação
console.log('Minificando assets...');
minifyJS();
minifyCSS();
console.log('Minificação concluída!');