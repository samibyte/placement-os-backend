import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import type { UserSession } from '@thallesp/nestjs-better-auth';

/**
 * Parameter decorator to extract the current authenticated user (or a specific user property)
 * from the request session.
 *
 * Example:
 *   @Get('profile')
 *   getProfile(@CurrentUser() user: UserSession['user']) { ... }
 *
 *   @Get('email')
 *   getEmail(@CurrentUser('email') email: string) { ... }
 */
export const CurrentUser = createParamDecorator(
  (property: keyof UserSession['user'] | undefined, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest<{ session?: UserSession }>();
    const user = request.session?.user;
    if (!user) {
      return null;
    }
    return property ? user[property] : user;
  },
);
