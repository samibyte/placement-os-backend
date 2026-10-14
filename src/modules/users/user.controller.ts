import { Controller, Get } from '@nestjs/common';
import { Session, AllowAnonymous } from '@thallesp/nestjs-better-auth';
import type { UserSession } from '@thallesp/nestjs-better-auth';
import { CurrentUser } from '../../common/decorators/current-user.decorator.js';
import { UsersService } from './users.service.js';

@Controller('users')
export class UserController {
  constructor(private readonly usersService: UsersService) {}

  /**
   * Protected route: Returns the current authenticated session and user.
   * With global AuthGuard, protected by default.
   */
  @Get('me')
  async getProfile(@Session() session: UserSession) {
    return {
      user: session.user,
      session: session.session,
    };
  }

  /**
   * Protected route: Returns detailed profile with session history from DB.
   */
  @Get('profile')
  async getFullProfile(@CurrentUser('id') userId: string) {
    return this.usersService.getProfile(userId);
  }

  /**
   * Public route: Explicitly marked with @AllowAnonymous() to bypass global AuthGuard.
   */
  @AllowAnonymous()
  @Get('public-info')
  getPublicData() {
    return {
      message: 'This is a public endpoint accessible without authentication.',
    };
  }
}