import { NestFactory } from '@nestjs/core';
import { ExpressAdapter } from '@nestjs/platform-express';
import express from 'express';
import { AppModule } from '../src/app.module.js';
import type { Request, Response } from 'express';

const expressApp = express();
const adapter = new ExpressAdapter(expressApp);

// Cache the initialized app (warm starts reuse this)
let appInitialized = false;
const appPromise = NestFactory.create(AppModule, adapter).then(async (app) => {
  app.enableCors();
  await app.init();
  appInitialized = true;
  return expressApp;
});

export default async function handler(req: Request, res: Response) {
  const app = await appPromise;
  app(req, res);
}
