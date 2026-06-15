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
