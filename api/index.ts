import { NestFactory } from '@nestjs/core';
import { ExpressAdapter } from '@nestjs/platform-express';
import express from 'express';
import { AppModule } from '../src/app.module.js';
import type { Request, Response } from 'express';

const expressApp = express();
const adapter = new ExpressAdapter(expressApp);

// Initialize once and reuse across warm invocations
const appPromise = NestFactory.create(AppModule, adapter, {
  bodyParser: false, // Better Auth handles its own body parsing
}).then(async (app) => {
  app.enableCors({
    origin: process.env.FRONTEND_URL,
    credentials: true,
  });
  await app.init();
  return expressApp;
});

export default async function handler(req: Request, res: Response) {
  const app = await appPromise;
  app(req, res);
}
