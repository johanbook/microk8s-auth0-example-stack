const express = require("express");
const logger = require("morgan");
const { auth } = require("express-openid-connect");
const { createProxyMiddleware } = require("http-proxy-middleware");

const config = {
  authRequired: true,
  auth0Logout: true,
  enableTelemetry: false,
  secret: process.env.AUTH0_SECRET,
  baseURL: "http://example.com",
  clientID: process.env.AUTH0_CLIENT_ID,
  issuerBaseURL: process.env.AUTH0_TENANT_URL,
};

const PORT = process.env.PORT || 80;

const app = express();
app.use(logger("tiny"));

// Should token be set in requesting server instead?
app.use(
  "/groups",
  createProxyMiddleware({
    changeOrigin: true,
    onProxyReq: (req) =>
      req.setHeader(
        "authorization",
        `Bearer ${process.env.AUTH0_GROUPS_API_TOKEN}`
      ),
    pathRewrite: {
      "^/groups": "",
    },
    target: process.env.AUTH0_GROUPS_API_URL,
  })
);

app.use(auth(config));
app.get("/", async (req, res) => {
  const userId = req.oidc.user.sub;
  res.set("x-user-id", userId);
  res.sendStatus(200);
});

app.listen(PORT);
