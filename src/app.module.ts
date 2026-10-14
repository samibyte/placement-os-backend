import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { ConfigModule } from '@nestjs/config';
import { AuthGuard, AuthModule } from '@thallesp/nestjs-better-auth';
import { AppController } from './app.controller.js';
import { AppService } from './app.service.js';
import { auth } from './auth.js';
import { validateEnv } from './config/env.config.js';
import { UsersModule } from './modules/users/users.module.js';

@Module({
  imports: [
    // Better Auth integration (global scoped)
    AuthModule.forRoot({ auth }),

    // Environment configuration
    ConfigModule.forRoot({
      isGlobal: true,
      validate: validateEnv,
      cache: true,
    }),

    // Feature Modules
    UsersModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    // Global AuthGuard: Secure by default. All endpoints require authentication
    // unless explicitly annotated with @AllowAnonymous() or @OptionalAuth()
    {
      provide: APP_GUARD,
      useClass: AuthGuard,
    },
  ],
})
export class AppModule {}
