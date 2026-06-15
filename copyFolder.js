import { cpSync } from "node:fs";

cpSync('src/main/views', 'dist/js/views', { recursive: true });
cpSync('assets/graphics', 'dist/public/i', { recursive: true });
//cpSync('assets/js', 'dist/public/js', { recursive: true });
cpSync('assets/fonts', 'dist/public/fonts', { recursive: true });
cpSync('assets/scss', 'src/scss', { recursive: true });
