const path = require("path");
const merge = require("webpack-merge");
const common = require("./webpack.config.common.js");

module.exports = merge(common, {
  mode: "development",
  devtool: "inline-source-map",
  module: {
    rules: [
      {
        test: /\.css$/,
        use: ["style-loader", "css-loader"]
      }
    ]
  },
  devServer: {
    contentBase: path.join(__dirname, "public"),
    port: 8081,
    historyApiFallback: true,
    host: "0.0.0.0",
    proxy: [
      {
        context: "/graphql",
        target: "http://localhost:8080/",
        ws: true
      }
    ]
  }
});
