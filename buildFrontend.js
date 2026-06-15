// build.js
import { build } from "esbuild";

import console from "node:console";
import process from "node:process";

// Run esbuild
await build({
    entryPoints: ["src/browser/ts/index.ts"], // Entry file
    bundle: true,                   // Bundle all dependencies
    minify: true,                   // Minify output
    outfile: "dist/public/js/s.min.js",    // Output file
    platform: "node",               // Target Node.js
    target: "node24",               // Node.js 24 syntax
    sourcemap: false,               // No source map for minified build
    format: "esm",                  // Output as ES module
    plugins: []
}).then(() => {
    console.log("✅ Build complete: dist/public/js/s.min.js");
}).catch((err) => {
    console.error("❌ Build failed:", err);
    process.exit(1);
});
