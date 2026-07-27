const { DateTime } = require("luxon");
const markdownIt = require("markdown-it");
const syntaxHighlight = require("@11ty/eleventy-plugin-syntaxhighlight");
const Image = require("@11ty/eleventy-img");

module.exports = function(eleventyConfig) {
  
  // Adiciona highlight de sintaxe
  eleventyConfig.addPlugin(syntaxHighlight);
  
  // Copia assets estáticos
  eleventyConfig.addPassthroughCopy("src/assets");
  eleventyConfig.addPassthroughCopy({"src/robots.txt": "robots.txt"});
  eleventyConfig.addPassthroughCopy({"src/sw.js": "sw.js"});
  eleventyConfig.addPassthroughCopy({"src/favicon.svg": "favicon.svg"});
  
  // Observa mudanças em CSS/JS
  eleventyConfig.addWatchTarget("src/assets/css/");
  eleventyConfig.addWatchTarget("src/assets/js/");
  
  // Filtros de data customizados
  eleventyConfig.addFilter("readableDate", dateObj => {
    return DateTime.fromJSDate(dateObj, {zone: 'utc'}).setLocale('pt-BR').toFormat("dd LLL yyyy");
  });
  
  eleventyConfig.addFilter("htmlDateString", dateObj => {
    return DateTime.fromJSDate(dateObj, {zone: 'utc'}).toFormat('yyyy-LL-dd');
  });
  
  eleventyConfig.addFilter("dateToRfc3339", date => {
    return new Date(date).toISOString();
  });
  
  eleventyConfig.addFilter("getNewestCollectionItemDate", collection => {
    return collection[collection.length - 1].date;
  });
  
  // Filtro de resumo customizado
  eleventyConfig.addFilter("excerpt", (post) => {
    const content = post.replace(/(<([^>]+)>)/gi, "");
    return content.substr(0, 200) + "...";
  });
  
  // Filtro de limite
  eleventyConfig.addFilter("limit", (array, limit) => {
    return array.slice(0, limit);
  });
  
  // Filtro slugify para URLs
  eleventyConfig.addFilter("slugify", (str) => {
    return str
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/(^-|-$)/g, '');
  });
  
  // Shortcode de imagem com otimização
  eleventyConfig.addNunjucksAsyncShortcode("image", async function(src, alt, sizes = "100vw") {
    let metadata = await Image(src, {
      widths: [300, 600, 1200],
      formats: ["webp", "jpeg"],
      outputDir: "./_site/assets/images/optimized/",
      urlPath: "/assets/images/optimized/"
    });
    
    let imageAttributes = {
      alt,
      sizes,
      loading: "lazy",
      decoding: "async",
      class: "glitch-image"
    };
    
    return Image.generateHTML(metadata, imageAttributes);
  });
  
  // Coleções
  eleventyConfig.addCollection("filmes", function(collectionApi) {
    return collectionApi.getFilteredByGlob("src/filmes/*.md").reverse();
  });
  
  eleventyConfig.addCollection("tagList", function(collection) {
    let tagSet = new Set();
    collection.getAll().forEach(item => {
      (item.data.tags || []).forEach(tag => tagSet.add(tag));
    });
    return [...tagSet].sort();
  });
  
  eleventyConfig.addCollection("searchIndex", function(collection) {
    return collection.getAll()
      .filter(item => item.data.title)
      .map(item => ({
        title: item.data.title,
        excerpt: item.data.excerpt || "",
        url: item.url,
        tags: item.data.tags || [],
        date: item.date
      }));
  });
  
  // Configuração do Markdown
  let markdownLibrary = markdownIt({
    html: true,
    breaks: true,
    linkify: true
  });
  eleventyConfig.setLibrary("md", markdownLibrary);
  
  return {
    dir: {
      input: "src",
      output: "_site",
      includes: "_includes",
      data: "_data"
    },
    templateFormats: ["md", "njk", "html"],
    markdownTemplateEngine: "njk",
    htmlTemplateEngine: "njk"
  };
};