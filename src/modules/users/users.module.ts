import { Module } from '@nestjs/common';
import { UserController } from './user.controller.js';
import { UsersService } from './users.service.js';

@Module({
  controllers: [UserController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}
