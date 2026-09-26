const { createProxyMiddleware } = require("http-proxy-middleware");

module.exports = function(app) {
  app.use(
    "/api",
    createProxyMiddleware({
      target: "http://app3-backend:8080",
      pathRewrite: { "^/api": "" }
    })
  );
};
