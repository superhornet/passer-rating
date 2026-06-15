// clean.js
import * as fs from "node:fs";
import * as path from "node:path";
import * as console from "node:console";
import * as process from "node:process";

const folders = [
    path.join('.', 'dist'),
    path.join('.', 'docs')
]
try {
    for (const folder of folders) {
        if (fs.existsSync(folder)) {
            fs.rmSync(folder, { recursive: true, force: true });
            console.log(`Deleted folder: ${folder}`);
        } else {
            console.log(`Folder not found: ${folder}`);
        }
    }

} catch (err) {
    console.error(`Error deleting folder: ${err.message}`);
    process.exit(1);
}
