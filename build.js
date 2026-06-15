import { build } from 'esbuild';
import console from 'node:console';
import process from 'node:process';

// Run esbuild to bundle and minify TypeScript into one file
try {
    await build({
        entryPoints: ['src/main/ts/index.ts'], // Entry TypeScript file
        bundle: true,                  // Bundle all dependencies
        minify: true,                   // Minify output
        platform: 'node',               // Target Node.js
        target: 'node24',               // Optimize for Node.js 24
        outfile: 'dist/server.min.js',     // Output file
        format: 'esm',                  // Output as ES module
        sourcemap: false,               // Disable source maps for smallest size
        external: ['fs', 'path', 'os', 'crypto', 'dotenv']
    });
    console.log('✅ Build complete: dist/server.min.js');
} catch (err) {
    console.error('❌ Build failed:', err);
    process.exit(1);
}
