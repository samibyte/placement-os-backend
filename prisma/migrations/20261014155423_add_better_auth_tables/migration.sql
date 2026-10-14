/*
  Warnings:

  - You are about to drop the `User` table. If the table is not empty, all the data it contains will be lost.

*/
-- CreateEnum
CREATE TYPE "career_level" AS ENUM ('INTERN', 'JUNIOR', 'MID', 'SENIOR');

-- CreateEnum
CREATE TYPE "role_category" AS ENUM ('BACKEND', 'FRONTEND', 'FULLSTACK', 'AI_ML', 'DEVOPS', 'MOBILE', 'QA', 'DATA', 'OTHER');

-- CreateEnum
CREATE TYPE "employment_type" AS ENUM ('FULL_TIME', 'PART_TIME', 'CONTRACT', 'INTERNSHIP');

-- CreateEnum
CREATE TYPE "work_mode" AS ENUM ('REMOTE', 'HYBRID', 'ONSITE');

-- CreateEnum
CREATE TYPE "salary_period" AS ENUM ('MONTHLY', 'YEARLY');

-- CreateEnum
CREATE TYPE "job_source_kind" AS ENUM ('API', 'ATS_BOARD');

-- CreateEnum
CREATE TYPE "job_origin" AS ENUM ('EXTERNAL', 'MANUAL');

-- CreateEnum
CREATE TYPE "job_status" AS ENUM ('ACTIVE', 'EXPIRED', 'REMOVED');

-- CreateEnum
CREATE TYPE "job_visibility" AS ENUM ('PRIVATE', 'PUBLIC');

-- CreateEnum
CREATE TYPE "parse_status" AS ENUM ('PENDING', 'PARSED', 'FAILED', 'MANUAL');

-- CreateEnum
CREATE TYPE "application_status" AS ENUM ('SAVED', 'CONSIDERING', 'APPLIED', 'INTERVIEW', 'OFFER', 'ACCEPTED', 'REJECTED', 'WITHDRAWN');

-- CreateEnum
CREATE TYPE "event_type" AS ENUM ('STATUS_CHANGED', 'INTERVIEW_SCHEDULED', 'INTERVIEW_RESULT', 'CONTACT', 'NOTE');

-- DropTable
DROP TABLE "User";

-- CreateTable
CREATE TABLE "job_skills" (
    "job_id" UUID NOT NULL,
    "skill_id" UUID NOT NULL,
    "is_required" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "job_skills_pkey" PRIMARY KEY ("job_id","skill_id")
);

-- CreateTable
CREATE TABLE "job_sources" (
    "id" UUID NOT NULL,
    "slug" VARCHAR(60) NOT NULL,
    "name" VARCHAR(120) NOT NULL,
    "kind" TEXT NOT NULL,
    "base_url" VARCHAR(500),
    "config" JSONB,
    "is_enabled" BOOLEAN NOT NULL DEFAULT true,
    "last_synced_at" TIMESTAMPTZ(6),
    "last_sync_status" VARCHAR(20),
    "last_sync_error" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "job_sources_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "jobs" (
    "id" UUID NOT NULL,
    "origin" "job_origin" NOT NULL,
    "source_id" UUID,
    "external_id" VARCHAR(255),
    "created_by_user_id" UUID,
    "dedup_hash" VARCHAR(64),
    "title" VARCHAR(255) NOT NULL,
    "company_name" VARCHAR(255) NOT NULL,
    "company_url" VARCHAR(500),
    "location_text" VARCHAR(255),
    "work_mode" "work_mode",
    "employment_type" "employment_type",
    "description" TEXT NOT NULL,
    "requirements" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "responsibilities" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "education_requirement" VARCHAR(255),
    "apply_url" VARCHAR(1000),
    "role_category" "role_category",
    "experience_level" "career_level",
    "min_years" SMALLINT,
    "max_years" SMALLINT,
    "salary_min" INTEGER,
    "salary_max" INTEGER,
    "salary_currency" VARCHAR(3),
    "salary_period" "salary_period",
    "posted_at" TIMESTAMPTZ(6),
    "application_deadline" TIMESTAMPTZ(6),
    "status" "job_status" NOT NULL DEFAULT 'ACTIVE',
    "visibility" "job_visibility" NOT NULL DEFAULT 'PRIVATE',
    "visibility_locked" BOOLEAN NOT NULL DEFAULT false,
    "parse_status" "parse_status" NOT NULL DEFAULT 'PENDING',
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "jobs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "skills" (
    "id" UUID NOT NULL,
    "slug" VARCHAR(100) NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "aliases" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "skills_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "emailVerified" BOOLEAN NOT NULL DEFAULT false,
    "image" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "user_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "session" (
    "id" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "token" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "ipAddress" TEXT,
    "userAgent" TEXT,
    "userId" TEXT NOT NULL,

    CONSTRAINT "session_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "account" (
    "id" TEXT NOT NULL,
    "accountId" TEXT NOT NULL,
    "providerId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "accessToken" TEXT,
    "refreshToken" TEXT,
    "idToken" TEXT,
    "accessTokenExpiresAt" TIMESTAMP(3),
    "refreshTokenExpiresAt" TIMESTAMP(3),
    "scope" TEXT,
    "password" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "account_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "verification" (
    "id" TEXT NOT NULL,
    "identifier" TEXT NOT NULL,
    "value" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "verification_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "job_skills_skill_id_idx" ON "job_skills"("skill_id");

-- CreateIndex
CREATE UNIQUE INDEX "job_sources_slug_key" ON "job_sources"("slug");

-- CreateIndex
CREATE INDEX "jobs_dedup_hash_idx" ON "jobs"("dedup_hash");

-- CreateIndex
CREATE INDEX "jobs_status_visibility_posted_at_idx" ON "jobs"("status", "visibility", "posted_at" DESC);

-- CreateIndex
CREATE INDEX "jobs_created_by_user_id_idx" ON "jobs"("created_by_user_id");

-- CreateIndex
CREATE INDEX "jobs_role_category_experience_level_idx" ON "jobs"("role_category", "experience_level");

-- CreateIndex
CREATE INDEX "jobs_application_deadline_idx" ON "jobs"("application_deadline");

-- CreateIndex
CREATE UNIQUE INDEX "jobs_source_id_external_id_key" ON "jobs"("source_id", "external_id");

-- CreateIndex
CREATE UNIQUE INDEX "skills_slug_key" ON "skills"("slug");

-- CreateIndex
CREATE UNIQUE INDEX "user_email_key" ON "user"("email");

-- CreateIndex
CREATE INDEX "session_userId_idx" ON "session"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "session_token_key" ON "session"("token");

-- CreateIndex
CREATE INDEX "account_userId_idx" ON "account"("userId");

-- CreateIndex
CREATE INDEX "verification_identifier_idx" ON "verification"("identifier");

-- AddForeignKey
ALTER TABLE "job_skills" ADD CONSTRAINT "job_skills_job_id_fkey" FOREIGN KEY ("job_id") REFERENCES "jobs"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "job_skills" ADD CONSTRAINT "job_skills_skill_id_fkey" FOREIGN KEY ("skill_id") REFERENCES "skills"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "jobs" ADD CONSTRAINT "jobs_source_id_fkey" FOREIGN KEY ("source_id") REFERENCES "job_sources"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "session" ADD CONSTRAINT "session_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "account" ADD CONSTRAINT "account_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;
