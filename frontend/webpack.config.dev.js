const path = require("path");
const merge = require("webpack-merge");
const common = require("./webpack.config.common.js");

module.exports = merge(common, {
  mode: "development",
  devtool: "inline-source-map",
  devServer: {
    https: true,
    contentBase: path.join(__dirname, "public"),
    port: 8081,
    historyApiFallback: true,
    proxy: {
      "/graphql": {
        target: "https://localhost:8080/",
        secure: false,
        changeOrigin: true
      }
    }
  }
});
