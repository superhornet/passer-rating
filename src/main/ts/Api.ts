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
