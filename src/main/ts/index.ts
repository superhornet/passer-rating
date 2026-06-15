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
