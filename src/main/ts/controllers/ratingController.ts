
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
