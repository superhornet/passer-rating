import { DatabaseSync as Database} from 'node:sqlite';
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
            const db = new Database(
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
