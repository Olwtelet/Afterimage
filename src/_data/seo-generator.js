const seo = require("./seo");

module.exports = function (data = {}) {
  const title = data.title
    ? `${data.title} | ${seo.siteName}`
    : seo.title;

  const description =
    data.description ||
    seo.description;

  const image =
    data.image || seo.image;

  const url =
    `${seo.siteUrl}${data.page?.url || "/"}`;

  const keywords = [
    ...(seo.keywords || []),
    ...(data.genres || []),
    ...(data.tags || []),
    data.title,
    data.year,
    data.director
  ].filter(Boolean);

  return {
    title,
    description,
    image,
    url,
    keywords: [...new Set(keywords)]
  };
};