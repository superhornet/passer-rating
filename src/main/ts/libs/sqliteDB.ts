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
