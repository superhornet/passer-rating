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
                return db.prepare(`INSERT INTO ratings (
                    qb_name_f, qb_name_l, team,
                    attempts, completions, yards, interceptions, touchdowns
                    ) VALUES (
                    ?, ?, ?, ?, ?, ?, ?, ?)`).run(
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
            const results = connection.prepare(`SELECT * FROM ratings WHERE id = ?;`).all(data);
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
            const results = connection.prepare(`SELECT * FROM ratings LIMIT ? OFFSET ?`).all(pagesize, page*pagesize);
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
                return db.prepare(`UPDATE ratings SET qb_name_f = ?, qb_name_l = ?, team = ?, attempts = ?, completions = ?, yards = ?, touchdowns = ?, interceptions = ? WHERE id = ?`)
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
                const result = db.prepare(`DELETE FROM ratings WHERE id = ?`).run(id);
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
            const results = connection.prepare(`SELECT COUNT(*) AS count FROM ratings;`).all();
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
