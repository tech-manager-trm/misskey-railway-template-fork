const { build } = require("esbuild");
const fs = require("fs");

// Ensure dist directory exists
if (!fs.existsSync("dist")) {
  fs.mkdirSync("dist", { recursive: true });
}

build({
  entryPoints: ["./src/index.js"],
  bundle: true,
  outfile: "dist/index.js",
  platform: "node",
  target: "node18",
  minify: true,
}).catch(() => process.exit(1));
