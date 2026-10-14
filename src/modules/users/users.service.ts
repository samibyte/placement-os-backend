import { Injectable, NotFoundException } from '@nestjs/common';
import { AuthService } from '@thallesp/nestjs-better-auth';
import type { auth } from '../../auth.js';
import { prisma } from '../../lib/prisma.js';

@Injectable()
export class UsersService {
  constructor(private readonly authService: AuthService<typeof auth>) {}

  /**
   * Fetch full user profile along with active session metadata.
   */
  async getProfile(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        sessions: {
          select: {
            id: true,
            createdAt: true,
            expiresAt: true,
            userAgent: true,
            ipAddress: true,
          },
        },
      },
    });

    if (!user) {
      throw new NotFoundException(`User with ID ${userId} not found`);
    }

    return user;
  }
}
