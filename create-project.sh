#!/bin/bash
set -e
cd ..
PROJECT_NAME="passer-rating"

# Create folders
mkdir -p $PROJECT_NAME/src/browser/ts
mkdir -p $PROJECT_NAME/src/main/ts/libs
mkdir -p $PROJECT_NAME/src/main/ts/controllers
mkdir -p $PROJECT_NAME/src/main/ts/models
mkdir -p $PROJECT_NAME/src/main/ts/routes
mkdir -p $PROJECT_NAME/src/main/ts/types
mkdir -p $PROJECT_NAME/src/main/views
mkdir -p $PROJECT_NAME/src/scss

# -------------------------
# .env
# -------------------------
cat > $PROJECT_NAME/.env <<'EOF'
# Set to production when deploying to production
NODE_ENV=development
NODE_OPTIONS=--enable-source-maps
# Node.js server configuration
SERVER_PORT=3000
API_PORT=8080
EOF

# -------------------------
# .editorconfig
# -------------------------
cat > $PROJECT_NAME/.editorconfig <<'EOF'
# EditorConfig is awesome: https://EditorConfig.org

# top-most EditorConfig file
root = true

[*]
indent_style = space
indent_size = 4
end_of_line = crlf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.pug]
indent_size = 2

[*.sql]
indent_size = 2

[*.json]
indent_size = 2
EOF

# -------------------------
# package.json
# -------------------------
cat > $PROJECT_NAME/package.json <<'EOF'
{
  "name": "passer-rating",
  "version": "1.0.0",
  "description": "Demo application for NFL/NCAA Passer Rating",
  "main": "dist/js/index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "doc": "typedoc --tsconfig tsconfig.server.json --plugin typedoc-plugin-rename-defaults --entryPoints src/main/ts/index.ts",
    "clean": "node clean.js",
    "copy-folder": "node copyFolder.js",
    "lint": "eslint . --ext .ts",
    "tsc:server": "node ./node_modules/typescript/bin/tsc -p tsconfig.server.json",
    "tsc:client": "node ./node_modules/typescript/bin/tsc -p tsconfig.frontend.json",
    "build": "node build.js",
    "build:sass": "sass src/scss/:dist/public/css/ --no-source-map",
    "packageFE": "node buildFrontend.js",
    "dev:start": "npm-run-all clean lint tsc:server tsc:client copy-folder build:sass start",
    "dev": "nodemon --watch src -e ts,scss,pug --exec npm run dev:start",
    "devC": "concurrently \"npm run package\" \"npm run build\"",
    "package": "npm-run-all clean copy-html packageFE build:sass",
    "start": "node ."
  },
  "repository": {
    "type": "git",
    "url": "git+https://github.com/superhornet/passer-rating.git"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "type": "module",
  "bugs": {
    "url": "https://github.com/superhornet/passer-rating/issues"
  },
  "homepage": "https://github.com/superhornet/passer-rating#readme",
  "overrides": {
    "@cucumber/cucumber": "^11.2.0",
    "fast-xml-parser": "latest",
    "mockery": "latest",
    "tmp": "^0.2.3",
    "uuid": "^14"
  },
  "dependencies": {
    "express": "^5.2.1",
    "swagger-ui-express": "^5.0.1",
    "pug": "^3.0.4"
  },
  "devDependencies": {
    "@eslint/eslintrc": "^3.3.5",
    "@eslint/js": "^10.0.1",
    "@types/express": "^5.0.6",
    "@types/node": "^25.6.0",
    "@typescript-eslint/eslint-plugin": "^8.59.2",
    "@typescript-eslint/parser": "^8.59.2",
    "@types/swagger-ui-express": "^4.1.8",
    "concurrently": "^9.2.1",
    "esbuild": "^0.28.0",
    "eslint": "^10.3.0",
    "nodemon": "^3.1.14",
    "npm-run-all": "^4.1.5",
    "sass": "^1.99.0",
    "ts-node": "^10.9.2",
    "typedoc": "^0.28.19",
    "typedoc-plugin-rename-defaults": "^0.7.3",
    "typescript": "^6.0.3",
    "typescript-eslint": "^8.59.2"
  }
}

EOF

# -------------------------
# tsconfig.json
# -------------------------
cat > $PROJECT_NAME/tsconfig.json <<'EOF'
{
    // Visit https://aka.ms/tsconfig to read more about this file
    "compilerOptions": {
        // File Layout
        // Environment Settings
        // See also https://aka.ms/tsconfig/module
        //"types": [],
        "types": [
            "node"
        ],
        // For nodejs:
        // and npm install -D @types/node
        // Other Outputs
        // Stricter Typechecking Options
        "noEmit": false,
        "allowImportingTsExtensions": true,
        "resolveJsonModule": true,
        "noUncheckedIndexedAccess": true,
        "exactOptionalPropertyTypes": true,
        // Style Options
        "noImplicitReturns": true,
        "noImplicitOverride": true,
        "noUnusedLocals": true,
        "noUnusedParameters": false,
        "noFallthroughCasesInSwitch": true,
        // "noPropertyAccessFromIndexSignature": true,
        // Recommended Options
        "strict": true,
        "rewriteRelativeImportExtensions": true,
        "verbatimModuleSyntax": true,
        "isolatedModules": true,
        "noUncheckedSideEffectImports": true,
        "moduleDetection": "force",
        "skipLibCheck": true,
    },
}
EOF

# -------------------------
# tsconfig.server.json
# -------------------------
cat > $PROJECT_NAME/tsconfig.server.json <<'EOF'
{
    "extends": "./tsconfig.json",
    "typedocOptions": {
        "out": "docs"
    },
    "compilerOptions": {
        "rootDir": "./src/main/ts",
        "outDir": "./dist/js",
        "moduleResolution": "nodenext",
        "module": "nodenext",
        "target": "esnext",
        "lib": [
            "ESNext",
            "DOM",
        ],
        "sourceMap": true,
        "declaration": true,
        "declarationMap": true,
        "types": [
            "node",
        ]
    },
    "include": [
        "src/main/ts/**/*",
    ]
}
EOF

# -------------------------
# tsconfig.frontend.json
# -------------------------
cat > $PROJECT_NAME/tsconfig.frontend.json <<'EOF'
{
    "extends": "./tsconfig.json",
    "compilerOptions": {
        "rootDir": "src/browser/ts",
        "outDir": "./dist/public/js",
        "module": "esnext",
        "target": "esnext",
        "lib": [
            "dom",
            "ESNext"
        ],
        "types": [
            "@types/node"
        ],
        "sourceMap": false,
        "declaration": false,
        "declarationMap": false,
        "allowSyntheticDefaultImports": true,
    },
    "include": [
        "src/browser/**/*.ts"
    ],
    "exclude": [
        "tests/feature"
    ]
}
EOF

# -------------------------
# clean.js
# -------------------------
cat > $PROJECT_NAME/clean.js <<'EOF'
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
EOF

# -------------------------
# copyFolder.js
# -------------------------
cat > $PROJECT_NAME/copyFolder.js <<'EOF'
import { cpSync } from "node:fs";

cpSync('src/main/views', 'dist/js/views', { recursive: true });
cpSync('assets/graphics', 'dist/public/i', { recursive: true });
//cpSync('assets/js', 'dist/public/js', { recursive: true });
cpSync('assets/fonts', 'dist/public/fonts', { recursive: true });
cpSync('assets/scss', 'src/scss', { recursive: true });
EOF

# -------------------------
# buildFrontend.js
# -------------------------
cat > $PROJECT_NAME/buildFrontend.js <<'EOF'
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
EOF

# -------------------------
# build.js
# -------------------------
cat > $PROJECT_NAME/build.js <<'EOF'
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
EOF

# -------------------------
# src/main/ts/libs/JSONResponse.ts
# -------------------------
cat > $PROJECT_NAME/src/main/ts/libs/JSONResponse.ts <<'EOF'
import type { Request, Response } from "express";
class JSONResponse {

  public static goodToGo(req: Request, res: Response, message: string, data: JSON | null) {
    res.status(200).json({
      code: 200,
      data,
      message: message || "OK"
    });
  }
  public static creationSuccess(req: Request, res: Response, message: string, data: JSON | null) {
    res.status(201).json({
      code: 201,
      data,
      message: message || "created"
    });
}
public static updateSuccess(req: Request, res: Response, message: string, data: JSON | null) {
    res.status(202).json({
        code: 202,
        data,
        message: message || "accepted"
    });
}
public static noContent(req: Request, res: Response, message: string, data: JSON | null) {
    res.status(204).json({
        code: 204,
        data,
        message: message || "no content"
    });
}
public static badRequest(req: Request, res: Response, message: string | null, data: JSON | null) {
    res.status(400).json({
        code: 400,
        data,
        message: message || "bad request",
    });
}
public static unauthorized(req: Request, res: Response, message: string, data: JSON | null) {
    res.status(403).json({
        code: 403,
        data,
        message: message || "forbidden",
        req: req.body
    });
}
public static notFound(req: Request, res: Response, message: string, data: JSON | null){
    res.status(404).json({
        code: 404,
        data,
        message: message || "not found",
        req: req.originalUrl
    })
}
public static serverError(req: Request, res: Response, message: string, data: JSON | null) {
    res.status(500).json({
        code: 500,
        data,
        message: message || "internal server error",
        req: req.originalUrl,
    });
}
public static notImplemented(req: Request, res: Response, message: string, data: JSON | null) {
    res.status(501).json({
        code: 501,
        data,
        message: message || "not implemented",
        req: req.originalUrl,
    });
  }
}

export default JSONResponse;
EOF


# -------------------------
# src/main/ts/libs/sqliteDB.ts
# -------------------------
cat > $PROJECT_NAME/src/main/ts/libs/sqliteDB.ts <<'EOF'
import { DatabaseSync } from 'node:sqlite';
import { Pool } from "./sqlite-pool.ts";
import { mkdirSync } from 'node:fs';

// Ensure data directory exists
mkdirSync('data', { recursive: true });
export class Database {
    pool: Pool
    constructor() {
        // Create a connection pool
        const pool = new Pool({
            filename: 'passer-rating.db',
            maxConnections: 5
        });
        this.pool = pool;
    }
    /**
     * Runs a callback inside a transaction.
     * Automatically commits if successful, rolls back on error.
     */
    public async withTransaction<T>(
        fn: (db: DatabaseSync) => Promise<T>
    ): Promise<T> {
        const db = await this.pool.getConnection();
        try {
            db.exec('BEGIN TRANSACTION');
            const result = await fn(db);
            db.exec('COMMIT');
            return result;
        } catch (err) {
            db.exec('ROLLBACK');
            console.error('Transaction failed:', err);
            throw err;
        } finally {
            db.close(); // Return connection to pool
        }
    }

    public async initDb() {
        await this.withTransaction(async (db) => {
            db.exec(`
      CREATE TABLE IF NOT EXISTS ratings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        qb_name_f TEXT NOT NULL,
        qb_name_l TEXT NOT NULL,
        attempts INTEGER NOT NULL DEFAULT 0,
        completions INTEGER NOT NULL DEFAULT 0,
        yards INTEGER NOT NULL DEFAULT 0,
        touchdowns INTEGER NOT NULL DEFAULT 0,
        interceptions INTEGER NOT NULL DEFAULT 0,
        team TEXT NOT NULL
      )
    `);
        });
    }
}
EOF

# -------------------------
# src/main/ts/libs/sqlite-pool.ts
# -------------------------
cat > $PROJECT_NAME/src/main/ts/libs/sqlite-pool.ts <<'EOF'
import { DatabaseSync as Database, DatabaseSync } from 'node:sqlite';
import { join } from 'node:path';

interface PoolOptions {
    filename: string;
    maxConnections?: number;
}

export class Pool {
    private readonly filename: string;
    private readonly maxConnections: number;
    private available: Database[] = [];
    private readonly inUse: Set<Database> = new Set();
    private readonly waiting: ((db: Database) => void)[] = [];
    private isClosing = false;

    constructor(options: PoolOptions) {
        this.filename = join('data', options.filename);
        this.maxConnections = options.maxConnections ?? 5;
    }

    /**
     * Get a connection from the pool.
     * Waits if all connections are busy.
     */
    async getConnection(): Promise<Database> {
        if (this.isClosing) {
            throw new Error('Pool is closing, cannot get new connections.');
        }

        // If available connection exists, reuse it
        if (this.available.length > 0) {
            const db = this.available.pop();
            if(db){
            this.inUse.add(db);
            return this.wrapConnection(db);
            }
        }

        // If we can create a new connection
        if (this.inUse.size < this.maxConnections) {
            const db = new DatabaseSync(
                this.filename
            );
            this.inUse.add(db);
            return this.wrapConnection(db);
        }

        // Otherwise, wait for a connection to be released
        return new Promise<Database>((resolve) => {
            this.waiting.push((db) => {
                this.inUse.add(db);
                resolve(this.wrapConnection(db));
            });
        });
    }

    /**
     * Wraps a Database so that calling close() returns it to the pool.
     */
    private wrapConnection(db: Database): Database {
        const originalClose = db.close.bind(db);

        // Override close to release back to pool
        (db).close = async () => {
            if (this.isClosing) {
                // Actually close if pool is shutting yards
                originalClose();
                this.inUse.delete(db);
                return;
            }

            // Return to available list
            this.inUse.delete(db);
            if (this.waiting.length > 0) {
                const waiter = this.waiting.shift();
                if (waiter) {
                    waiter(db);
                }
            } else {
                this.available.push(db);
            }
        };

        return db;
    }

    /**
     * Close all connections and stop the pool.
     */
    async close(): Promise<void> {
        this.isClosing = true;

        // Close all available connections
        for (const db of this.available) {
            db.close();
        }
        this.available = [];

        // Close all in-use connections (wait for them to be released first)
        for (const db of this.inUse) {
            db.close();
        }
        this.inUse.clear();
    }
}
EOF

# -------------------------
# src/main/ts/libs/HTMLStatusError.ts
# -------------------------
cat > $PROJECT_NAME/src/main/ts/libs/HTMLStatusError.ts <<'EOF'
import type { Request, Response } from "express";
import JSONResponse from "./JSONResponse.ts";
/**
 * Custom Error so that
 * a status code can be passed with Error
 */
export class HTMLStatusError extends Error {
    private _statusCode!: number;
    public get statusCode() {
        return this._statusCode;
    }
    public set statusCode(value) {
        this._statusCode = value;
    }
    constructor(message: string, statusCode: number) {
        super(message);
        this.statusCode = statusCode;
    }
}
export function processError(req: Request, res: Response, error: HTMLStatusError) {
    if (error instanceof HTMLStatusError) {
        switch (error.statusCode.toString()) {
            case "400":
                JSONResponse.badRequest(req, res, error.message, null);
                break;
            case "403":
                JSONResponse.unauthorized(req, res, error.message, null);
                break;
            case "404":
                JSONResponse.notFound(req, res, error.message, null);
                break;
            case "501":
                JSONResponse.notImplemented(req, res, error.message, null);
                break;
            default:
                break;
        }
    }else{
        JSONResponse.serverError(req, res, (error as Error).message, null);
    }
}
EOF

# -------------------------
# src/main/ts/libs/Validator.ts
# -------------------------
cat > $PROJECT_NAME/src/main/ts/libs/Validator.ts <<'EOF'
import type { ValidatorOptionsTypes } from "../types/ValidatorOptionsTypes.ts";

export class Validator {
    private _version: string = "";
    private _options!: ValidatorOptionsTypes;
    constructor(options?: ValidatorOptionsTypes) {
        this.version = options?.version || "1.0";
        this.options = options || {
        version: "1.0",
        stringValidation: {
            minLength: 2,
            maxLength: 255,
            locale: "en-us",
        },
        emailValidation: {
            domainMinLength: 2,
            domainMaxLength: 10,
        },
        numberValidation: {
            integerMin: -2147483648,
            integerMax: 2147483648,
            floatMin: -2147483648,
            floatMax: 2147483648,
        }
    };
    }
    public get options(): ValidatorOptionsTypes {
        return this._options;
    }
    public set options(value: ValidatorOptionsTypes) {
        this._options = value;
    }
    public get version(): string {
        return this._version;
    }
    public set version(value: string) {
        this._version = value;
    }
    /**
     * stripHtml
     *
     * @param str
     * @returns string
     */
    public stripHtml(str: string): string {
        if (typeof str !== "string") {
            throw new TypeError("Input must be a string.");
        }
        return str
            .replaceAll('&', "{ampersand}")
            .replaceAll('>', `{greater_than}`)
            .replaceAll('<', "{less_than}")
            .replaceAll('"', "{inch_mark}")
            .replaceAll('\'', "{foot_mark}")
            .replaceAll('/', "{solidus}")
            .replaceAll(';', "{semicolon}");
    }
    /**
     * stringValidate
     *
     * @param str
     * @returns boolean
     */
    public stringValidate(str: string): boolean {
        if (typeof str !== "string") {
            throw new TypeError("Input must be a string.");
        }
        let isValid = true;
        //console.log(this.options);
        const stringOptions = this.options.stringValidation;
        if (typeof str !== "string") { isValid = false; }

        if (stringOptions && str.length < stringOptions.minLength) { isValid = false; }
        if (stringOptions && str.length > stringOptions.maxLength) { isValid = false; }

        return isValid;
    }
    /**
     * emailValidate
     *
     * @param str
     * @returns boolean
     */
    public emailValidate(str: string): boolean {
        if (typeof str !== "string" || str.length === 0) {
            throw new TypeError("Input must be of type string");
        }
        const emailRegex: RegExp = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        if (!emailRegex.test(str)) {
            throw new TypeError("Input is not in the format of a valid email");
        }
        const [userid, host] = str.split("@");
        if (!userid && !host) {
            return false;
        }
        return true;
    }
    /**
     * numberValidate
     *
     * @param num
     * @returns boolean
     */
    public numberValidate(num: number): boolean {
        let isValid = false;
        const numberOptions = this.options.numberValidation;
        if(typeof num === 'number' && Number.isInteger(num)){
            if(numberOptions?.integerMin !== undefined && numberOptions.integerMax !== undefined) {
                if(
                    num > numberOptions.integerMin &&
                    num < numberOptions.integerMax
                ){
                    isValid = true;
                }
            }
        }
        if(typeof num === 'number' && Number.isFinite(num) && !Number.isInteger(num)){
            if(numberOptions?.floatMin !== undefined && numberOptions.floatMax !== undefined){
                if(
                    num > numberOptions.floatMin &&
                    num < numberOptions.floatMax
                ){
                    isValid = true;
                }
            }
        }
        return isValid
    }
}
EOF

# -------------------------
# src/main/ts/types/ValidatorOptionsTypes.ts
# -------------------------
cat > $PROJECT_NAME/src/main/ts/types/ValidatorOptionsTypes.ts <<'EOF'
export interface ValidatorOptionsTypes {
    version: string;
    stringValidation?: {
        minLength: number,
        maxLength: number,
        locale?: string,
    };
    emailValidation?: {
        domainMinLength: number,
        domainMaxLength: number,
    };
    numberValidation?: {
        integerMin: number,
        integerMax: number,
        floatMin: number,
        floatMax: number
    };
}
EOF

# -------------------------
# src/main/views/index.pug
# -------------------------
cat > $PROJECT_NAME/src/main/views/index.pug <<'EOF'
doctype html
html(lang="en")
  head
    title #{title}
    meta(charset='UTF-8')
    meta( name='viewport', content='width=device-width, initial-scale=1.0' )
    link( href='css/webfonts.css', rel='stylesheet', type='text/css')
    link( href='css/style.css', rel='stylesheet', type='text/css' )
    link( href='css/grid_flow.css', rel='stylesheet', type='text/css')
    script(type='javascript', src='js/AntiPollution.js')
    script(type='javascript', src='js/ScrollBarHandler.js')
    script(type='javascript', src='js/hideaddressbar.js')
  body(lang='en')
    #root
      header#container-header
        h1 #{title}
        h2 Passer Rating
      #container-nav
        nav
          ul
            li
              a(href="/") Home
            li
              a(href="/about") About
      #container-content
        #blanket
        #confirm
          h1 Delete
          div
            h4#deletion Delete this?
            button#confirmYes.yes Yes
            button#confirmNo.no No
        #popup
          form#playerForm
            h1 Player
              span#formClose.control.close r
            div
              label(for="qb_name_f") First Name
              input#qb_name_f(title="First Name", type="text", tabindex="1")
            div
              label(for="qb_name_l") Last Name:
              input#qb_name_l(title="Last Name", type="text" tabindex="2")
            div
              label(for="team") Team:
              input#team(title="Team", type="text", tabindex="3")
            div
              label(for="attempts") Attempts:
              input#attempts(title="Attempts", type="number", tabindex="4")
            div
              label(for="completions") Completions:
              input#completions(title="Completions", type="number", tabindex="5")
            div
              label(for="yards") Yards:
              input#yards(title="Yards", type="number", tabindex="6")
            div
              label(for="touchdowns") Touchdowns:
              input#touchdowns(title="Touchdowns", type="number", tabindex="7")
            div
              label(for="interceptions") Interceptions:
              input#interceptions(title="Interceptions", type="number", tabindex="8")
            div
              input#ratingID(title="ratingID", type="hidden")
            div
              label(for="playerFormAct")
              button#playerFormAct(title="" type="button" tabindex="9") Add
        section#notification
        section
          table#ratings.container_full
            colgroup
              col.grid-24_desktop
              col.grid-24_desktop
              col.grid-12_desktop
            thead
              tr
                th Name
                th Team
                th Rating
            tbody#data
            tfoot
              tr
                td
                  span Items per page
                  select#pageSize(title="Items per page")
                    option 5
                    option 20
                td
                  button#addRating.control.plus Add
                td
                  span#btnRev.control.direction.back
                  span#paging 1
                  span#btnFwd.control.direction.forward.disabled

        section
          div
            span.logo &vellip;
      footer#container-footer
        p Powered by Molybdenum and 💜
        p &copy; #{new Date().getUTCFullYear()} Caleb King.
    script(type='module', src='js/index.js')
EOF

# -------------------------
# src/browser/ts/index.ts
# -------------------------
cat > $PROJECT_NAME/src/browser/ts/index.ts <<'EOF'
import { ScrollbarHandler } from "./ScrollBarHandler.ts";
import { AntiPollution } from "./AntiPollution.ts";
interface RatingAPIType {
    id?: number | bigint,
    qb_name_f: string,
    qb_name_l: string,
    attempts: number,
    completions: number,
    yards: number,
    touchdowns: number,
    interceptions: number,
    team: string
}
class PlayerRating {
    private playerFormClose: HTMLElement;
    private playerFormAction: HTMLButtonElement;
    private addRating: HTMLButtonElement;
    private nextPage: HTMLElement;
    private prevPage: HTMLElement;
    private pageSize: HTMLSelectElement;
    constructor() {
        this.playerFormAction = document.getElementById('playerFormAct') as HTMLButtonElement;
        this.addRating = document.getElementById('addRating') as HTMLButtonElement;
        this.playerFormClose = document.getElementById('formClose') as HTMLElement;
        this.nextPage = document.getElementById('btnFwd') as HTMLElement;
        this.prevPage = document.getElementById('btnRev') as HTMLElement;
        this.pageSize = document.getElementById('pageSize') as HTMLSelectElement;
        this.init();
    }
    static hidePopup() {
        const blanket = document.getElementById('blanket') as HTMLElement;
        blanket.style.display = 'none';
        const popup = document.getElementById('popup') as HTMLElement;
        popup.style.display = 'none';
        const confirm = document.getElementById('confirm') as HTMLElement;
        confirm.style.display = 'none';
    }
    static repositionPopup() {
        const confirm = document.getElementById('confirm') as HTMLElement;
        confirm.style.top = Math.max(0, (window.innerHeight - confirm.offsetHeight) / 2) + 'px';
        confirm.style.left = ((window.innerWidth - confirm.offsetWidth) / 2) + 'px';
        const popup = document.getElementById('popup') as HTMLElement;
        popup.style.top = Math.max(0, (window.innerHeight - popup.offsetHeight) / 2) + 'px';
        popup.style.left = ((window.innerWidth - popup.offsetWidth) / 2) + 'px';
    }
    static async deleteIt(item: string) {

        try {
            const response = await fetch(`http://localhost:8080/api/rating/${item}`, {
                method: 'DELETE', // HTTP method
                mode: "cors",
                headers: {
                    'Content-Type': 'application/json', // Sending JSON
                    'Accept': 'application/json'        // Expecting JSON back
                }
            });

            // Check if the response is OK (status in the range 200–299)
            if (!response.ok) {
                throw new Error(`HTTP error! Status: ${response.status}`);
            }
        } catch (error) {
            console.error((error as Error).stack);
            alert("Unable to delete rating");
        } finally {
            const yesBtn = document.getElementById('confirmYes') as HTMLButtonElement;
            yesBtn.onclick = null;
            const noBtn = document.getElementById('confirmNo') as HTMLButtonElement;
            noBtn.onclick = null;

            PlayerRating.hidePopup();
        }
    }
    static okay() {
        const confirmationString = document.getElementById('deletion') as HTMLElement;
        try {
            const foundElement = document.querySelector(`[data-id = "${confirmationString.innerText}"]`);
            const parent = foundElement?.parentNode;
            const grandparent = parent?.parentNode;
            if (grandparent && grandparent.parentNode) {
                grandparent.parentNode.removeChild(grandparent);
            }
        } catch (error) {
            console.error((error as Error).cause);
        } finally {
            PlayerRating.deleteIt(confirmationString.innerText);

        }
    }
    static notOkay() {
        const yesBtn = document.getElementById('confirmYes') as HTMLButtonElement;
        yesBtn.onclick = null;
        const noBtn = document.getElementById('confirmNo') as HTMLButtonElement;
        noBtn.onclick = null;
        PlayerRating.hidePopup();
    }
    static confirm() {
        const element = (this as unknown as HTMLElement).dataset.id;
        const blanket = document.getElementById('blanket') as HTMLElement;
        blanket.style.display = '';
        const confirm = document.getElementById('confirm') as HTMLElement;
        confirm.style.display = '';
        const confirmationString = document.getElementById('deletion') as HTMLElement;
        confirmationString.innerText = `${element}`;
        const yesBtn = document.getElementById('confirmYes') as HTMLButtonElement;
        yesBtn.onclick = PlayerRating.okay;
        const noBtn = document.getElementById('confirmNo') as HTMLButtonElement;
        noBtn.onclick = PlayerRating.notOkay;
    }
    static async populate() {
        const element = (this as unknown as HTMLElement).dataset.id;
        const blanket = document.getElementById('blanket') as HTMLElement;
        blanket.style.display = '';
        const popup = document.getElementById('popup') as HTMLElement;
        popup.style.display = '';
        let data;
        try {
            const form = document.getElementById('playerForm') as HTMLFormElement | null;
            const response = await fetch(`http://localhost:8080/api/rating/${element}`, {
                method: 'GET', // HTTP method
                mode: "cors",
                headers: {
                    'Content-Type': 'application/json', // Sending JSON
                    'Accept': 'application/json'        // Expecting JSON back
                }
            });

            // Check if the response is OK (status in the range 200–299)
            if (!response.ok) {
                throw new Error(`HTTP error! Status: ${response.status}`);
            }
            data = await response.json();
            const tempRating: RatingAPIType = data.data;
            Object.entries(tempRating).forEach(([key, value]) => {
                const field = form?.elements.namedItem(key) as HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement | null;
                if (!field) {
                    return;
                }
                if (field instanceof HTMLInputElement) {
                    if (field.type === 'text') {
                        field.value = String(value);
                    } else if (field.type === 'number') {
                        field.value = String(value);
                    } else if (field.type === 'checkbox') {
                        field.checked = Boolean(value);
                    } else {
                        field.value = String(value);
                    }
                } else if (field instanceof HTMLSelectElement || field instanceof HTMLTextAreaElement) {
                    field.value = String(value);
                }
            })
            const id = form?.elements.namedItem('ratingID') as HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement | null;
            id!.value = String(element);
            const button = document.getElementById('playerFormAct') as HTMLButtonElement;
            button.innerText = "Submit";
        } catch (error) {
            console.error((error as Error).stack);
        }
    }
    static changeRow(){
        const rating: RatingAPIType =
        {
            qb_name_f: (document.getElementById('qb_name_f') as HTMLInputElement).value as string,
            qb_name_l: (document.getElementById('qb_name_l') as HTMLInputElement).value as string,
            team: (document.getElementById('team') as HTMLInputElement).value as string,
            attempts: Number.parseInt((document.getElementById('attempts') as HTMLInputElement).value as string),
            completions: Number.parseInt((document.getElementById('completions') as HTMLInputElement).value as string),
            yards: Number.parseInt((document.getElementById('yards') as HTMLInputElement).value as string),
            touchdowns: Number.parseInt((document.getElementById('touchdowns') as HTMLInputElement).value as string),
            interceptions: Number.parseInt((document.getElementById('interceptions') as HTMLInputElement).value as string)
        };
        const ratingID = (document.getElementById('ratingID') as HTMLInputElement).value as string;
        rating.id = Number(ratingID);
        const foundElement = document.querySelector(`[data-id = "${ratingID}"]`);
        const parent = foundElement?.parentNode;
        const grandparent = parent?.parentNode;
        const name = grandparent?.firstChild as HTMLTableCellElement;
        const team = name?.nextSibling as HTMLTableCellElement;
        const qbr = team?.nextSibling as HTMLTableCellElement;
        const qbrNode = Array.from(qbr.childNodes).find(
            node => node.nodeType === Node.TEXT_NODE && node.textContent?.trim() !== ""
        )
        qbrNode!.textContent = `${PlayerRating.calculateRating(
            rating.attempts,
            rating.completions,
            rating.yards,
            rating.touchdowns,
            rating.interceptions
        )}`
        name.textContent = `${rating.qb_name_f} ${rating.qb_name_l}`;
        team.textContent = rating.team;
        PlayerRating.putData(`http://localhost:8080/api/rating/${ratingID}`, rating);
    }
    static addRow(data: RatingAPIType) {
        const dataTable = document.getElementById('data') as HTMLTableElement;
        const elTr = document.createElement('tr');
        const elName = document.createElement('td');
        const elTeam = document.createElement('td');
        const elQBR = document.createElement('td');

        const elTextName = document.createTextNode(`${data.qb_name_f} ${data.qb_name_l}`);
        elName.appendChild(elTextName);

        const elTextTeam = document.createTextNode(`${data.team}`);
        elTeam.appendChild(elTextTeam);

        const elTextQBR = document.createTextNode(
            PlayerRating.calculateRating(
                data.attempts,
                data.completions,
                data.yards,
                data.touchdowns,
                data.interceptions
            ));

        const elEdit = document.createElement('span');
        //const elEditDataId = document.createAttribute('data-id')
        elEdit.dataset.id = (data.id?.toString() || "0");
        //elEdit.appendChild(elEditDataId);
        elEdit.classList.add('control', 'edit');
        elEdit.onclick = PlayerRating.populate;
        const elEditText = document.createTextNode('e')
        elEdit.appendChild(elEditText);

        const elDelete = document.createElement('span');
        //const elDeleteDataId = document.createAttribute('data-id')
        elDelete.dataset.id = (data.id?.toString() || "0");
        elDelete.classList.add('control', 'delete');
        elDelete.onclick = PlayerRating.confirm;
        //elDelete.appendChild(elDeleteDataId);
        const elDeleteText = document.createTextNode('d')
        elDelete.appendChild(elDeleteText);

        elQBR.appendChild(elTextQBR);
        elQBR.appendChild(elDelete);
        elQBR.appendChild(elEdit);
        elTr.appendChild(elName);
        elTr.appendChild(elTeam);
        elTr.appendChild(elQBR);
        dataTable.appendChild(elTr);
    }
    static calculateRating(attempts: number, completions: number, yards: number, touchdowns: number, interceptions: number): string {
        const compPerAtt = ((completions / attempts) - 0.3) * 5;
        const yardsPerAtt = ((yards / attempts) - 3) * 0.25;
        const tdsPerAtt = (touchdowns / attempts) * 20;
        const intsPerAtt = 2.375 - (interceptions / attempts * 25);
        const rating = (((((PlayerRating.minMax(compPerAtt)) + PlayerRating.minMax(yardsPerAtt)) + PlayerRating.minMax(tdsPerAtt) + PlayerRating.minMax(intsPerAtt)) / 6) * 100)
        return rating.toFixed(2);
    }
    static minMax(x: number) {
        return Math.max(0, Math.min(x, 2.375))
    }
    private addRecord() {
        const blanket = document.getElementById('blanket') as HTMLElement;
        blanket.style.display = '';
        const popup = document.getElementById('popup') as HTMLElement;
        popup.style.display = '';
        const playerForm = document.getElementById('playerForm') as HTMLFormElement;
        if (playerForm) {
            playerForm.reset();
        }
        const button = document.getElementById('playerFormAct') as HTMLButtonElement;
        button.innerText = "Add";

        PlayerRating.repositionPopup();
    }
    private async formAction() {

        const rating: RatingAPIType =
        {
            qb_name_f: (document.getElementById('qb_name_f') as HTMLInputElement).value as string,
            qb_name_l: (document.getElementById('qb_name_l') as HTMLInputElement).value as string,
            team: (document.getElementById('team') as HTMLInputElement).value as string,
            attempts: Number.parseInt((document.getElementById('attempts') as HTMLInputElement).value as string),
            completions: Number.parseInt((document.getElementById('completions') as HTMLInputElement).value as string),
            yards: Number.parseInt((document.getElementById('yards') as HTMLInputElement).value as string),
            touchdowns: Number.parseInt((document.getElementById('touchdowns') as HTMLInputElement).value as string),
            interceptions: Number.parseInt((document.getElementById('interceptions') as HTMLInputElement).value as string)
        };
        const typeAddOrSubmit = (this as unknown as HTMLButtonElement);
        if(typeAddOrSubmit.innerText === 'Add'){
            const savedRating = await PlayerRating.postData('http://localhost:8080/api/rating', rating);
            PlayerRating.addRow(savedRating.data);
        }else if(typeAddOrSubmit.innerText === 'Submit'){
            PlayerRating.changeRow();
        }
    }
    static async fillTable() {
        let pageSize = 0;
        const selectElement = document.getElementById('pageSize') as HTMLSelectElement;
        const selectedIndex: number = selectElement.selectedIndex;
        const selectOptions = selectElement.options as HTMLOptionsCollection;
        if (selectOptions && selectOptions && (selectedIndex >= 0)) {
            // const selectedValue: string = selectElement.value; // Value attribute of the selected option
            const selectedText =
                (selectOptions instanceof HTMLOptionsCollection) &&
                (selectOptions !== undefined) &&
                (selectedIndex >= 0)
                    ? selectOptions[selectedIndex]?.textContent//selectOptions[ selectedIndex ].text
                    : "" as string; // Visible text
            pageSize = Number(selectedText);
        } else {
            console.warn("No option selected.");
        }

        const pageNo = Number((document.getElementById('paging') as HTMLElement).textContent);
        const count = await PlayerRating.countRatings();
        if(pageNo > 1){
            document.getElementById('btnRev')?.classList.remove('disabled');
        }else{
            document.getElementById('btnRev')?.classList.add('disabled');
        }
        if(count <= (pageNo * pageSize)){
            document.getElementById('btnFwd')?.classList.add('disabled');
        }else if(count > pageSize || pageNo < (pageSize / count)){
            document.getElementById('btnFwd')?.classList.remove('disabled');
        }
        const ratings = await PlayerRating.getData(pageNo-1, pageSize);
        for (const i of ratings) {
            PlayerRating.addRow(i);
        }

    }
    static async countRatings(){
        const response = await fetch(`http://localhost:8080/api/ratings`, {
                method: 'OPTIONS', // HTTP method
                mode: "cors",
                headers: {
                    'Content-Type': 'application/json', // Sending JSON
                    'Accept': '*/*'        // Expecting JSON back
                }
        });
        const body = await response.json();
        if(response.ok && body.data.count){
            return body.data.count;
        }
        return 0;
    }
    /**
     * getData
     */
    static async getData(page=0, pagesize=5) {
        const response = await fetch(`http://localhost:8080/api/ratings?page=${page}&pagesize=${pagesize}`);
        const body = await response.json();
        if (response.ok && body.data){
            return (body.data.ratings);
        }
        return null
    }
    /**
     * postData
     */
    static async postData(url = '', data = {}) {
        try {
            const response = await fetch(url, {
                method: 'POST', // HTTP method
                mode: "cors",
                headers: {
                    'Content-Type': 'application/json', // Sending JSON
                    'Accept': '*/*'        // Expecting JSON back
                },
                body: JSON.stringify(data) // Convert object to JSON string
            });

            // Check if the response is OK (status in the range 200–299)
            if (!response.ok) {
                throw new Error(`HTTP error! Status: ${response.status}`);
            }

            // Parse and return JSON response
            return await response.json();
        } catch (error) {
            console.error((error as Error).stack);
            alert("Unable to send data");
        } finally {
            PlayerRating.hidePopup();
        }
    }
    static async putData(url = '', data = {}){
        try {
            const response = await fetch(url, {
                method: 'PUT', // HTTP method
                mode: "cors",
                headers: {
                    'Content-Type': 'application/json', // Sending JSON
                    'Accept': '*/*'        // Expecting JSON back
                },
                body: JSON.stringify(data) // Convert object to JSON string
            });

            // Check if the response is OK (status in the range 200–299)
            if (!response.ok) {
                throw new Error(`HTTP error! Status: ${response.status}`);
            }
        } catch (error) {
            console.error((error as Error).stack);
        } finally {
            PlayerRating.hidePopup();
        }
    }
    static updateTable(){
        const pageNo = Number((document.getElementById('paging') as HTMLElement).textContent);
        if(this instanceof HTMLElement && !this.classList.contains('disabled')){
            if(this.classList.contains('forward') && !this.classList.contains('disabled')){
                (document.getElementById('paging') as HTMLElement).textContent = String(pageNo+1);
            }
            if(this.classList.contains('back') && !this.classList.contains('disabled')){
                (document.getElementById('paging') as HTMLElement).textContent = String(pageNo-1)
            }
        }else if(this instanceof HTMLSelectElement){
            console.log(this)
        }
        const data = document.getElementById('data') as HTMLTableElement;
        while(data.firstChild){
            data.removeChild(data.firstChild);
        }
        PlayerRating.fillTable();
    }
    private init() {
        PlayerRating.hidePopup();
        const blanket = document.getElementById('blanket') as HTMLElement;
        blanket.onclick = PlayerRating.hidePopup;
        window.onresize = PlayerRating.repositionPopup;
        PlayerRating.fillTable();
        this.playerFormClose.onclick = PlayerRating.hidePopup;
        this.addRating.onclick = this.addRecord;
        this.playerFormAction.onclick = this.formAction;
        this.nextPage.onclick = PlayerRating.updateTable;
        this.prevPage.onclick = PlayerRating.updateTable;
        this.pageSize.onchange = PlayerRating.updateTable;
    }

}
(() => {
    ScrollbarHandler.registerCenteredElement(document.getElementById('root') as HTMLElement);

    const ck = new AntiPollution();
    ck.namespace(["rating"]);
    new PlayerRating();

})()
EOF

# -------------------------
# src/browser/ts/ScrollBarHandler.ts
# -------------------------
cat > $PROJECT_NAME/src/browser/ts/ScrollBarHandler.ts <<'EOF'
export class ScrollbarHandler {
    private _cachedWidth = 0;
    private readonly _element: HTMLElement;
    private readonly _scrollArea: HTMLElement | null;
    private readonly _sidebar: HTMLElement | null;
    private readonly _originalMinWidth: number;
    private _adjustment_scheduled = false;

    constructor(element: HTMLElement) {
        this._element = element;
        this._scrollArea = this._element?.parentElement;
        this._sidebar = document.getElementById('sidebar');
        const style = globalThis.getComputedStyle(this._element);
        // Note: assumes values were set in pixels
        this._originalMinWidth = Number.parseInt(style.getPropertyValue('min-width')) || 0;
        window.addEventListener('resize', this.adjust.bind(this), true);
        if (this._scrollArea && this._sidebar)
            this._scrollArea.addEventListener('scroll', this.adjust.bind(this), true);
    }

    /**
     * registerCenteredElement
     */
    static registerCenteredElement(el: HTMLElement) {
        const centeredElement = new ScrollbarHandler(el);
        centeredElement.adjust();
    }
    /**
     * get
     */
    public get scrollbarWidth() {
        if (this._cachedWidth)
            return this._cachedWidth;
        const element = document.createElement('div');
        element.style.position = 'absolute';
        element.style.left = '-1000px';
        element.style.width = '200px';
        element.style.height = '200px';
        element.style.overflow = 'auto';
        const subElement = document.createElement('div');
        subElement.style.height = '500px';
        element.appendChild(subElement);
        document.body.appendChild(element);
        const width = element.getBoundingClientRect().width;
        const inner_width = subElement.getBoundingClientRect().width;
        element.remove();
        this._cachedWidth = width - inner_width;
        return this._cachedWidth;
    }

    private adjust(): void {
        if (!this._element?.style || this._adjustment_scheduled)
            return;

        this._adjustment_scheduled = true;
        globalThis.requestAnimationFrame(this.actual_adjust_bound);
    }

    private get actual_adjust_bound() {
        return this.actual_adjust.bind(this);
    }

    private actual_adjust() {
        this._adjustment_scheduled = false;
        const availableWidth = window.innerWidth - this.scrollbarWidth;
        const elementWidth = this._element.getBoundingClientRect().width;
        this._element.style.marginInlineStart = Math.max(0, Math.floor((availableWidth - elementWidth) / 2)) + 'px';

        if (this._sidebar && this._scrollArea) {
            if (document.documentElement.dir === 'rtl')
                this._sidebar.style.marginInlineStart = this._scrollArea?.clientWidth +
                    this._scrollArea?.scrollLeft - this._scrollArea?.scrollWidth + 'px';
            else
                this._sidebar.style.marginInlineStart = -1 * this._scrollArea.scrollLeft + 'px';

            this._sidebar.style.bottom = this._scrollArea.clientWidth < this._originalMinWidth ?
                this.scrollbarWidth + 'px' : '';
        }
    }

    public isRegistered() {
        return this._element !== null;
    }

}
EOF

# -------------------------
# src/browser/ts/AntiPollution.ts
# -------------------------
cat > $PROJECT_NAME/src/browser/ts/AntiPollution.ts <<'EOF'
export class AntiPollution {
    private calebking;
    constructor() {
        if (this.calebking === "undefined") {
            this.calebking = {};
        }
        this.namespace(["rating"]);
    }
    /**
     * namespace
     */
    public namespace(argv: Array<string>) {
        const args = argv;
        const obj = new Map<string, object>();
        let arr: Array<string>;
        for (const element of args) {
            arr = ("" + element).split("."); //split the args
            obj.set("calebking", {});

            for (let j = (arr[0] === "calebking") ? 1 : 0; j < arr.length; j = j + 1) {
                obj.set(arr[j] as string, {});
                //obj = obj[arr[j]];
            }
        }
        this.calebking =  obj;
    }
    /**
     * assert
     */
    public assert(shouldBeTrue: boolean) {
        if(shouldBeTrue !== true){
            try {
                throw new Error("False condition");
            } catch (e) {
                const frames:Array<string>|undefined = (e as Error).stack?.split("@");
                frames?.shift();
                frames?.shift();
                throw new Error(`assert failed\n ${frames?.join("\n")}`, { cause: e });
            }
        }
    }
}
EOF

# -------------------------
# src/main/ts/index.ts
# -------------------------
cat > $PROJECT_NAME/src/main/ts/index.ts <<'EOF'
import { App } from './App.ts';
import { Api } from './Api.ts';
import { loadEnvFile } from 'node:process';
// Load variables from .env into process.env
loadEnvFile('.env');

// port available to the node.js runtime like an environment variable
const port: string | undefined = process.env.SERVER_PORT;
const apiPort: string | undefined = process.env.API_PORT;
/**
 * Listen method:
 *
 * @param port
 * @param lambda
 * Starts the Express server
 */
new App().express.listen(port, () => {
    // tslint:disable-next-line:no-console
    console.log(`server started at http://localhost:${port}`);
});

new Api().express.listen(apiPort, () => {
    console.log(`🚀 API Server running at http://localhost:${apiPort}/api`);
    console.log(`📄 Swagger docs at http://localhost:${apiPort}/api-docs`);
})
EOF

# -------------------------
# src/main/ts/Api.ts
# -------------------------
cat > $PROJECT_NAME/src/main/ts/Api.ts <<'EOF'
import express, { type Request, type Response, type NextFunction } from "express";
import { router as ratingRouter } from "./controllers/ratingController.ts";
import swaggerUi from "swagger-ui-express";
import console from "node:console";
import process from "node:process";
import fs from "node:fs";
import path from "node:path";

/**
 * @class Api
 *
 */
export class Api {
    public express;
    public applicationName = "Passer Rating API";

    /**
     * Sets up the App object attributes,
     * Loads routes and middleware,
     * Initializes the database.
     */
    constructor() {
        this.express = express();
        this.loadRoutes();
    }
    /**
     * Enable .json() for req.body content.
     * Enable urlencoded() for future use.
     * Set up routes
     */
    public loadRoutes(): void {
        // Load Swagger JSON
        const swaggerPath = path.resolve("./", "src", "main", "ts", "models", "swagger.json");
        if (!fs.existsSync(swaggerPath)) {
            console.error("Swagger file not found:", swaggerPath);
            process.exit(1);
        }
        const swaggerDocument = JSON.parse(fs.readFileSync(swaggerPath, "utf-8"));

        this.express.use(express.json());
        this.express.use(express.urlencoded());

        this.express.use("/api", (req: Request, res: Response, next: NextFunction) => {
            try {
                res.header("Access-Control-Allow-Origin", "http://localhost:3000"); // or specific domain
                res.header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
                res.header("Access-Control-Allow-Headers", "Content-Type, Authorization");

                next();
            } catch (error) {
                next(error);
            }
            return null;
        }, ratingRouter);
        // Swagger UI
        this.express.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerDocument));
    }
}
EOF

# -------------------------
# src/main/ts/App.ts
# -------------------------
cat > $PROJECT_NAME/src/main/ts/App.ts <<'EOF'
import express from "express";
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import {router as defaultRouter} from "./controllers/default.ts";
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
/**
 * @class App
 *
 */
export class App {
    public express;
    //public database;
    public applicationName = "NFL/NCAA QB Rating Application";

    /**
     * Sets up the App object attributes,
     * Loads routes and middleware,
     * Initializes the database.
     */
    constructor() {
        this.express = express();
        this.loadRoutes();
        // Set Pug (Jade) as the view engine
        this.express.set('views', path.join(__dirname, 'views'));
        this.express.set('view engine', 'pug');

        // Serve static files
        this.express.use(express.static(path.join(__dirname, '../public')));
    }

    /**
     * Enable .json() for req.body content.
     * Enable urlencoded() for future use.
     * Set up routes
     */
    public loadRoutes(): void {
        this.express.use(express.json());
        this.express.use(express.urlencoded());
        this.express.use("/", defaultRouter);
    }
}
EOF

# -------------------------
# src/main/ts/controllers/ratingController.ts
# -------------------------
cat > $PROJECT_NAME/src/main/ts/controllers/ratingController.ts<<EOF

import * as express from "express";
import JSONResponse from "../libs/JSONResponse.ts";
import { HTMLStatusError, processError } from "../libs/HTMLStatusError.ts";
import { type RatingAPIType } from "../types/RatingAPITypes.ts";
import { Rating } from "../models/Rating.ts";
export const router = express.Router();

router.options('/ratings', async (req, res) => {
    try {
        const count = await Rating.countAll();
        JSONResponse.goodToGo(req, res, "OK", count);
    } catch (error) {
        processError(req, res, error as HTMLStatusError);
    }

})
/**
 * Route for Creation of a rating
 *
 * Body: RatingAPIType JSON object with the new rating data
 */
router.post("/rating", async (req, res) => {
    try {
        if (!req.body || Object.keys(req.body).length === 0) {
            throw new HTMLStatusError("Empty JSON body", 400);
        }
        const data: RatingAPIType = req.body;
        const rating = await Rating.storeRating(data);

        JSONResponse.creationSuccess(req, res, "Created", rating as unknown as JSON);
    } catch (error) {
        processError(req, res, error as HTMLStatusError);
    }
});

/**
 * Route for Reading rating at /api/rating/{id}
 *
 * Params id The database id of the rating
 */
router.get("/rating/:id", async (req, res) => {
    try {
        if (!req.params || Object.keys(req.params).length === 0) {
            throw new Error("Parameter problem");
        }
        const data: number = Number.parseInt(req.params.id);
        if (data) {
            const rating: JSON = await Rating.fetchById(data);
            JSONResponse.goodToGo(req, res, "OK", rating);
        }
    } catch (error) {
        processError(req, res, error as HTMLStatusError);
    }
});

/**
 * Route for Updating rating at /api/rating/{id}
 *
 * Params id The database id of the rating
 * Body: RatingAPIType JSON object with the updated rating data
 *
 */
router.put("/rating/:id", async (req, res) => {
    try {
        if (!req.params || Object.keys(req.params).length === 0) {
            throw new Error("Parameter problem");
        }
        const id: number = Number.parseInt(req.params.id);
        if (!req.body || Object.keys(req.body).length === 0) {
            throw new HTMLStatusError("Empty JSON body", 400);
        }
        const data: RatingAPIType = req.body;
        if (await Rating.updateById(id, data)) {
            JSONResponse.updateSuccess(req, res, "Accepted", null);
        }
    } catch (error) {
        processError(req, res, error as HTMLStatusError);
    }
});


/**
 * Get all saved ratings
 *
 * Route for Reading all ratings at /api/ratings
 */
router.get("/ratings", async (req, res) => {
    try {
        const page = Number(req.query.page);
        const pagesize = Number(req.query.pagesize);
        const ratings: JSON = await Rating.fetchAllRatings(page, pagesize);
        JSONResponse.goodToGo(req, res, "OK", ratings);
    } catch (error) {
        JSONResponse.badRequest(req, res, (error as Error).message, null);
    }
});

/**
 * Route for Deleting rating at /api/rating/{id}
 *
 * Params id The database id of the rating
 */
router.delete("/rating/:id", async (req, res) => {
    try {
        if (!req.params || Object.keys(req.params).length === 0) {
            throw new Error("Parameter problem");
        }
        const id: number = Number.parseInt(req.params.id);
        const deletions = await Rating.deleteById(id) as unknown as { count: number | bigint };
        if (deletions.count === 0) {
            JSONResponse.notFound(req, res, "Not Found", null);
        } else {
            JSONResponse.noContent(req, res, "No Content", null);
        }
    } catch (error) {
        processError(req, res, error as HTMLStatusError);
    }
});
EOF

# -------------------------
# src/main/ts/controllers/default.ts
# -------------------------
cat > $PROJECT_NAME/src/main/ts/controllers/default.ts<<EOF
import * as express from "express";
import JSONResponse from "../libs/JSONResponse.ts";

export const router = express.Router();

/**
 * Route for /health
 */
router.get("/health", (req, res) => {
  try {
    res.header("Access-Control-Allow-Origin", "http://localhost:8080"); // or specific domain
    res.header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE");

    JSONResponse.goodToGo(req, res, "API Healthy", null);
  } catch (error) {
        JSONResponse.badRequest(req, res, (error as Error).message, null);
  }
});

router.get('/', (_req, res) => {
    res.render('index', { title: 'NFL/NCAA QB Rating' });
});
EOF

# -------------------------
# src/main/ts/types/RatingAPITypes.ts
# -------------------------
cat > $PROJECT_NAME/src/main/ts/types/RatingAPITypes.ts<<EOF
export interface RatingAPIType{
    id?: number,
    qb_name_f: string,
    qb_name_l: string,
    attempts: number,
    completions: number,
    yards: number,
    touchdowns: number,
    interceptions: number,
    team: string
}
EOF

# -------------------------
# src/main/ts/models/swagger.json
# -------------------------
cat > $PROJECT_NAME/src/main/ts/models/swagger.json<<EOF
{
  "openapi": "3.0.0",
  "info": {
    "title": "Passer Rating API",
    "version": "1.0.0",
    "description": "Passer Rating API with Swagger documentation"
  },
  "definitions": {
    "RatingItem": {
      "type": "object",
      "properties": {
        "qb_name_f": {
          "type": "string"
        },
        "qb_name_l": {
          "type": "string"
        },
        "team": {
          "type": "string"
        },
        "attempts": {
          "type": "integer"
        },
        "completions": {
          "type": "integer"
        },
        "yards": {
          "type": "integer"
        },
        "touchdowns": {
          "type": "integer"
        },
        "interceptions": {
          "type": "integer"
        }
      }
    },
    "ArrayOfRatingItems": {
      "type": "array",
      "items": {
        "": "#/definitions/RatingItem"
      }
    }
  },
  "paths": {
    "/health": {
      "get": {
        "summary": "Health check",
        "servers": [
          {
            "url": "http://localhost:3000"
          }
        ],
        "responses": {
          "200": {
            "description": "Successful response",
            "content": {
              "application/json": {
                "success": {
                  "code": 200,
                  "data": null,
                  "message": "API Healthy"
                }
              }
            }
          }
        }
      }
    },
    "/rating": {
      "post": {
        "summary": "Create Rating",
        "servers": [
          {
            "url": "http://localhost:8080/api"
          }
        ],
        "requestBody": {
          "required": true,
          "content": {
            "application/json": {
              "schema": {
                "ref": "#/definitions/RatingItem",
                "required": [
                  "qb_name_f",
                  "qb_name_l",
                  "team",
                  "attempts",
                  "completions",
                  "yards",
                  "touchdowns",
                  "interceptions"
                ]
              },
              "example": {
                "qb_name_f": "Tua",
                "qb_name_l": "Tagavailoa",
                "team": "2025 Miami Dolphins",
                "attempts": 384,
                "completions": 260,
                "yards": 2660,
                "touchdowns": 20,
                "interceptions": 15
              }
            }
          }
        },
        "responses": {
          "201": {
            "description": "Created"
          }
        }
      }
    },
    "/rating/{id}": {
      "get": {
        "summary": "Get rating by id",
        "servers": [
          {
            "url": "http://localhost:8080/api"
          }
        ],
        "parameters": [
          {
            "name": "id",
            "in": "path",
            "required": true,
            "description": "Unique identifier of the rating",
            "schema": {
              "type": "integer",
              "minimum": 1
            },
            "example": 42
          }
        ],
        "responses": {
          "200": {
            "description": "Rating retrieved successfully",
            "content": {
              "application/json": {
                "schema": {
                  "ref": "#/definitions/RatingItem"
                },
                "example": {
                  "id": 2,
                  "qb_name_f": "Quinn",
                  "qb_name_l": "Ewers",
                  "team": "2025 Miami Dolphins",
                  "attempts": 83,
                  "completions": 55,
                  "yards": 622,
                  "touchdowns": 3,
                  "interceptions": 3
                }
              }
            }
          },
          "404": {
            "description": "Rating not found"
          }
        }
      },
      "put": {
        "summary": "Update rating by id",
        "servers": [
          {
            "url": "http://localhost:8080/api"
          }
        ],
        "parameters": [
          {
            "name": "id",
            "in": "path",
            "required": true,
            "description": "Unique identifier of the rating",
            "schema": {
              "type": "integer",
              "minimum": 1
            },
            "example": 42
          }
        ],
        "requestBody": {
          "required": true,
          "content": {
            "application/json": {
              "schema": {
                "ref": "#/definitions/RatingItem",
                "required": [
                  "qb_name_f",
                  "qb_name_l",
                  "team",
                  "attempts",
                  "completions",
                  "yards",
                  "touchdowns",
                  "interceptions"
                ]
              },
              "example": {
                "qb_name_f": "Aaron",
                "qb_name_l": "Rodgers",
                "team": "2025 Pittsburgh Steelers",
                "attempts": 521,
                "completions": 344,
                "yards": 3468,
                "touchdowns": 24,
                "interceptions": 8
              }
            }
          }
        },
        "responses": {
          "202": {
            "description": "Accepted"
          },
          "404": {
            "description": "Rating not found"
          }
        }
      },
      "delete": {
        "summary": "Delete rating by id",
        "servers": [
          {
            "url": "http://localhost:8080/api"
          }
        ],
        "parameters": [
          {
            "name": "id",
            "in": "path",
            "required": true,
            "description": "Unique identifier of the rating",
            "schema": {
              "type": "integer",
              "minimum": 1
            },
            "example": 42
          }
        ],
        "responses": {
          "204": {
            "description": "No Content"
          },
          "404": {
            "description": "Rating not found",
            "content": {
              "application/json": {
                "schema": {
                  "code": {
                    "type": "integer"
                  },
                  "data": {
                    "type": null
                  },
                  "message": {
                    "type": "string"
                  },
                  "req": {
                    "type": "string"
                  }
                },
                "example": {
                  "code": 404,
                  "data": null,
                  "message": "Not Found",
                  "req": "/api/rating/42"
                }
              }
            }
          }
        }
      }
    },
    "/ratings": {
      "options": {
        "summary": "Count of ratings",
        "servers": [
          {
            "url": "http://localhost:8080/api"
          }
        ],
        "responses": {
          "200": {
            "description": "Successful response",
            "content": {
              "application/json": {
                "schema":{
                  "code":200,
                  "data":{
                    "count": {
                      "type": "integer"
                    }
                  },
                  "message": "OK"
                }
              }
            }
          }
        }
      },
      "get": {
        "summary": "Get all ratings",
        "servers": [
          {
            "url": "http://localhost:8080/api"
          }
        ],
        "responses": {
          "200": {
            "description": "Ratings retrieved successfully",
            "content": {
              "application/json": {
                "schema": {
                  "": "#/definitions/ArrayOfRatingItems"
                }
              }
            }
          }
        }
      }
    }
  }
}
EOF

# -------------------------
# src/main/ts/models/Rating.ts
# -------------------------
cat > $PROJECT_NAME/src/main/ts/models/Rating.ts<<EOF
import { type SQLOutputValue } from "node:sqlite";
import { HTMLStatusError } from "../libs/HTMLStatusError.ts";
import { Database } from "../libs/sqliteDB.ts";
import { type RatingAPIType } from "../types/RatingAPITypes.ts";

interface IRating {
    showRating(): RatingAPIType
}
/**
 * Rating
 */
export class Rating implements IRating {
    private pId!: number;
    private get id(): number {
        return this.pId;
    }
    private set id(value: number) {
        this.pId = value;
    }
    private pRating!: RatingAPIType;
    private get rating(): RatingAPIType {
        return this.pRating;
    }
    private set rating(value: RatingAPIType) {
        this.pRating = value;
    }
    constructor(
        rating: RatingAPIType
    ) {
        try {
            this.rating = rating;
            this.id = Number(rating.id);
        } catch (error) {
            throw new Error((error as Error).message, { cause: error });
        }
    }
    /**
     * Saves a rating to the database
     */
    static async storeRating(data: RatingAPIType) {
        const database = new Database();
        database.initDb();
        try {
            const q = await database.withTransaction(async (db) => {
                return db.prepare(``INSERT INTO ratings (
                    qb_name_f, qb_name_l, team,
                    attempts, completions, yards, interceptions, touchdowns
                    ) VALUES (
                    ?, ?, ?, ?, ?, ?, ?, ?)``).run(
                    data.qb_name_f,
                    data.qb_name_l,
                    data.team,
                    data.attempts,
                    data.completions,
                    data.yards,
                    data.touchdowns,
                    data.interceptions
                );
            });
            if (q.lastInsertRowid) {
                const ratingEntry = new Rating({
                    id: q.lastInsertRowid,
                    qb_name_f: data.qb_name_f as string,
                    qb_name_l: data.qb_name_l as string,
                    team: data.team as string,
                    attempts: data.attempts as number,
                    completions: data.completions as number,
                    yards: data.yards as number,
                    touchdowns: data.touchdowns as number,
                    interceptions: data.interceptions as number
                });
                return ratingEntry.rating;
            }
        } catch (error) {
            throw new HTMLStatusError((error as Error).message, 500);
        }
        return undefined;
    }
    public showRating(): RatingAPIType {
        return this.rating;
    }
    /**
     * Gets one rating from the database
     *
     * @param data integer
     * @returns Rating
     */
    static async fetchById(data: number) {
        const database = new Database();
        const connection = await database.pool.getConnection()
        try {
            const results = connection.prepare(``SELECT * FROM ratings WHERE id = ?;``).all(data);
            if (results[0]) {
                const output: RatingAPIType = resultToObject(results[0]);
                return output as unknown as JSON;
            } else {
                throw new HTMLStatusError("Rating not found", 404);
            }

        } catch (error) {
            if (error instanceof HTMLStatusError) {
                throw error;
            } else {
                throw new HTMLStatusError((error as Error).message, 500);
            }
        } finally {
            connection.close();
        }
    }
    /**
     * Gets all ratings
     * @returns Rating[]
     */
    static async fetchAllRatings(page: number, pagesize: number) {
        const database = new Database();
        const connection = await database.pool.getConnection()
        const output = {
            ratings: new Array<RatingAPIType>
        };
        try {
            const results = connection.prepare(``SELECT * FROM ratings LIMIT ? OFFSET ?``).all(pagesize, page*pagesize);
            for (const rating of results) {
                const ratingJSON: RatingAPIType = resultToObject(rating);
                output.ratings.push(ratingJSON);
            }
        } catch (error) {
            if (error instanceof HTMLStatusError) {
                throw error;
            } else {
                throw new HTMLStatusError((error as Error).message, 500);
            }
        } finally {
            connection.close();
        }
        return output as unknown as JSON;
    }
    /**
     * Updates a rating in the database
     *
     * @param id
     * @param data
     * @returns Rating
     */
    static async updateById(id: number, data: RatingAPIType) {
        try {
            let isUpdated = false;
            const database = new Database();
            const q = await database.withTransaction(async (db) => {
                return db.prepare(``UPDATE ratings SET qb_name_f = ?, qb_name_l = ?, team = ?, attempts = ?, completions = ?, yards = ?, touchdowns = ?, interceptions = ? WHERE id = ?``)
                    .run(
                        data.qb_name_f,
                        data.qb_name_l,
                        data.team,
                        data.attempts,
                        data.completions,
                        data.yards,
                        data.touchdowns,
                        data.interceptions,
                        id
                    );
            });
            if (q.changes === 0) {
                throw new HTMLStatusError("Rating not found", 404);
            } else {
                isUpdated = true;
            }
            return isUpdated;
        } catch (error) {
            if (error instanceof HTMLStatusError) {
                throw error;
            } else {
                throw new HTMLStatusError((error as Error).message, 500);
            }
        }
    }
    /**
     * Deletes a rating from the database
     *
     * @param id
     * @returns {}
     */
    static async deleteById(id: number) {
        let isDeleted = false;
        const database = new Database();
        try {
            database.withTransaction(async (db) => {
                const result = db.prepare(``DELETE FROM ratings WHERE id = ?``).run(id);
                if (result.changes) {
                    isDeleted = true;
                }
            });
        } catch (error) {
            if (error instanceof HTMLStatusError) {
                throw error;
            } else {
                throw new HTMLStatusError((error as Error).message, 500);
            }
        }
        return isDeleted;
    }
    static async countAll() {
        const database = new Database();
        const connection = await database.pool.getConnection()
        try {
            let countOfRatings: number = 0;
            const results = connection.prepare(``SELECT COUNT(*) AS count FROM ratings;``).all();
            if (results) {
                for(const count of results){
                    countOfRatings = Number(count.count);
                }
                return {count: countOfRatings} as unknown as JSON;
            } else {
                throw new HTMLStatusError("Error getting count", 500);
            }

        } catch (error) {
            if (error instanceof HTMLStatusError) {
                throw error;
            } else {
                throw new HTMLStatusError((error as Error).message, 500);
            }
        } finally {
            connection.close();
        }
    }
}

/**
 * Converts an SQL query result into a RatingAPIType
 *
 * @param rating
 * @returns Rating
 */
function resultToObject(rating: Record<string, SQLOutputValue>): RatingAPIType {
    return {
        id: rating.id,
        qb_name_f: rating.qb_name_f,
        qb_name_l: rating.qb_name_l,
        team: rating.team,
        attempts: rating.attempts,
        completions: rating.completions,
        yards: rating.yards,
        touchdowns: rating.touchdowns,
        interceptions: rating.interceptions
    } as RatingAPIType;
}
EOF

# -------------------------
# eslint.config.mjs
# -------------------------
cat > $PROJECT_NAME/eslint.config.mjs <<'EOF'
import { defineConfig } from "eslint/config";
import typescriptEslint from "@typescript-eslint/eslint-plugin";
import tsParser from "@typescript-eslint/parser";
import path from "node:path";
import { fileURLToPath } from "node:url";
import js from "@eslint/js";
import { FlatCompat } from "@eslint/eslintrc";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const compat = new FlatCompat({
    baseDirectory: __dirname,
    recommendedConfig: js.configs.recommended,
    allConfig: js.configs.all,
});

export default defineConfig([{
    extends: compat.extends(
        "eslint:recommended",
        "plugin:@typescript-eslint/recommended",
    ),
    ignores: [
        "assets/**",
    ],
    plugins: {
        "@typescript-eslint": typescriptEslint,
    },

    languageOptions: {
        parser: tsParser,
    },
    rules: {
    },
}]);
EOF

# -------------------------
# Install dependencies
# -------------------------
cd $PROJECT_NAME
npm install
echo "🚀 Starting development mode with hot-reload..."

npm run dev
