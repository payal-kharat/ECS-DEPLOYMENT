const { createProxyMiddleware } = require("http-proxy-middleware");

module.exports = function(app) {
  app.use(
    "/api",
    createProxyMiddleware({
      target: "http://app4-backend:8000",
      pathRewrite: { "^/api": "" }
    })
  );
};
