-- CreateEnum
CREATE TYPE "Grade" AS ENUM ('GRADE_10', 'GRADE_11', 'GRADE_12');

-- CreateEnum
CREATE TYPE "Province" AS ENUM ('GAUTENG', 'WESTERN_CAPE', 'KWAZULU_NATAL', 'EASTERN_CAPE', 'LIMPOPO', 'MPUMALANGA', 'NORTH_WEST', 'FREE_STATE', 'NORTHERN_CAPE');

-- CreateEnum
CREATE TYPE "Subject" AS ENUM ('MATH', 'PHYS_SCI');

-- CreateEnum
CREATE TYPE "Syllabus" AS ENUM ('CAPS', 'IEB');

-- CreateEnum
CREATE TYPE "ExamPeriod" AS ENUM ('TERM_1', 'TERM_2', 'TERM_3', 'TERM_4');

-- CreateEnum
CREATE TYPE "ExamLevel" AS ENUM ('TEACHER_MADE', 'PROVINCIAL', 'NATIONAL');

-- CreateEnum
CREATE TYPE "PaperType" AS ENUM ('PAPER_1', 'PAPER_2', 'PAPER_3');

-- CreateEnum
CREATE TYPE "StepMarkingStatus" AS ENUM ('CORRECT', 'INCORRECT', 'NOT_ATTEMPTED');

-- CreateEnum
CREATE TYPE "Role" AS ENUM ('USER', 'ADMIN');

-- CreateEnum
CREATE TYPE "TokenType" AS ENUM ('ACCESS', 'REFRESH', 'RESET_PASSWORD', 'VERIFY_EMAIL');

-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "grade" "Grade" NOT NULL,
    "province" "Province" NOT NULL,
    "syllabus" "Syllabus" NOT NULL DEFAULT 'CAPS',
    "school_name" TEXT,
    "role" "Role" NOT NULL DEFAULT 'USER',
    "is_email_verified" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tokens" (
    "id" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "type" "TokenType" NOT NULL,
    "expires" TIMESTAMP(3) NOT NULL,
    "blacklisted" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "user_id" TEXT NOT NULL,

    CONSTRAINT "tokens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "exam_papers" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "subject" "Subject" NOT NULL,
    "grade" "Grade" NOT NULL,
    "syllabus" "Syllabus" NOT NULL DEFAULT 'CAPS',
    "year" INTEGER NOT NULL,
    "exam_period" "ExamPeriod" NOT NULL,
    "exam_level" "ExamLevel" NOT NULL,
    "paper_type" "PaperType" NOT NULL,
    "province" "Province",
    "paper_number" TEXT NOT NULL,
    "duration_minutes" INTEGER NOT NULL,
    "instructions" TEXT,
    "total_marks" INTEGER,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "uploaded_by" TEXT,
    "uploaded_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "exam_papers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "questions" (
    "id" TEXT NOT NULL,
    "paper_id" TEXT NOT NULL,
    "question_number" TEXT NOT NULL,
    "context_text" TEXT NOT NULL,
    "context_images" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "topics" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "total_marks" INTEGER,
    "order_index" INTEGER NOT NULL,
    "page_number" INTEGER NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "questions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "question_parts" (
    "id" TEXT NOT NULL,
    "question_id" TEXT NOT NULL,
    "parent_part_id" TEXT,
    "part_number" TEXT NOT NULL,
    "part_text" TEXT NOT NULL,
    "marks" INTEGER NOT NULL DEFAULT 0,
    "part_images" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "nesting_level" INTEGER NOT NULL DEFAULT 1,
    "order_index" INTEGER NOT NULL,
    "requires_working" BOOLEAN NOT NULL DEFAULT false,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "question_parts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "solution_steps" (
    "id" TEXT NOT NULL,
    "part_id" TEXT NOT NULL,
    "step_number" INTEGER NOT NULL,
    "description" TEXT NOT NULL,
    "working_out" TEXT,
    "marks_for_this_step" INTEGER NOT NULL,
    "solution_images" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "teaching_note" TEXT,
    "hint_text" TEXT,
    "order_index" INTEGER NOT NULL,
    "is_critical_step" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "solution_steps_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "student_attempts" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "paper_id" TEXT NOT NULL,
    "started_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completed_at" TIMESTAMP(3),
    "last_activity_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "total_marks_earned" INTEGER,
    "total_marks_possible" INTEGER,
    "percentage_score" DOUBLE PRECISION,
    "time_spent_minutes" INTEGER,
    "questions_attempted" INTEGER NOT NULL DEFAULT 0,
    "questions_completed" INTEGER NOT NULL DEFAULT 0,
    "is_abandoned" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "student_attempts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "step_attempts" (
    "id" TEXT NOT NULL,
    "student_attempt_id" TEXT NOT NULL,
    "step_id" TEXT NOT NULL,
    "status" "StepMarkingStatus" NOT NULL,
    "marked_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "step_attempts_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE INDEX "users_grade_syllabus_idx" ON "users"("grade", "syllabus");

-- CreateIndex
CREATE INDEX "users_created_at_idx" ON "users"("created_at");

-- CreateIndex
CREATE INDEX "tokens_user_id_idx" ON "tokens"("user_id");

-- CreateIndex
CREATE INDEX "tokens_token_idx" ON "tokens"("token");

-- CreateIndex
CREATE INDEX "tokens_expires_idx" ON "tokens"("expires");

-- CreateIndex
CREATE INDEX "exam_papers_subject_grade_syllabus_idx" ON "exam_papers"("subject", "grade", "syllabus");

-- CreateIndex
CREATE INDEX "exam_papers_year_exam_period_idx" ON "exam_papers"("year", "exam_period");

-- CreateIndex
CREATE INDEX "exam_papers_paper_type_idx" ON "exam_papers"("paper_type");

-- CreateIndex
CREATE INDEX "exam_papers_is_active_idx" ON "exam_papers"("is_active");

-- CreateIndex
CREATE INDEX "exam_papers_uploaded_at_idx" ON "exam_papers"("uploaded_at");

-- CreateIndex
CREATE INDEX "questions_paper_id_idx" ON "questions"("paper_id");

-- CreateIndex
CREATE INDEX "questions_paper_id_page_number_idx" ON "questions"("paper_id", "page_number");

-- CreateIndex
CREATE INDEX "questions_paper_id_order_index_idx" ON "questions"("paper_id", "order_index");

-- CreateIndex
CREATE INDEX "questions_topics_idx" ON "questions"("topics");

-- CreateIndex
CREATE INDEX "question_parts_question_id_idx" ON "question_parts"("question_id");

-- CreateIndex
CREATE INDEX "question_parts_question_id_order_index_idx" ON "question_parts"("question_id", "order_index");

-- CreateIndex
CREATE INDEX "question_parts_parent_part_id_idx" ON "question_parts"("parent_part_id");

-- CreateIndex
CREATE INDEX "solution_steps_part_id_idx" ON "solution_steps"("part_id");

-- CreateIndex
CREATE INDEX "solution_steps_part_id_order_index_idx" ON "solution_steps"("part_id", "order_index");

-- CreateIndex
CREATE INDEX "student_attempts_user_id_idx" ON "student_attempts"("user_id");

-- CreateIndex
CREATE INDEX "student_attempts_paper_id_idx" ON "student_attempts"("paper_id");

-- CreateIndex
CREATE INDEX "student_attempts_user_id_paper_id_idx" ON "student_attempts"("user_id", "paper_id");

-- CreateIndex
CREATE INDEX "student_attempts_started_at_idx" ON "student_attempts"("started_at");

-- CreateIndex
CREATE INDEX "student_attempts_completed_at_idx" ON "student_attempts"("completed_at");

-- CreateIndex
CREATE UNIQUE INDEX "step_attempts_student_attempt_id_step_id_key" ON "step_attempts"("student_attempt_id", "step_id");

-- AddForeignKey
ALTER TABLE "tokens" ADD CONSTRAINT "tokens_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "questions" ADD CONSTRAINT "questions_paper_id_fkey" FOREIGN KEY ("paper_id") REFERENCES "exam_papers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "question_parts" ADD CONSTRAINT "question_parts_question_id_fkey" FOREIGN KEY ("question_id") REFERENCES "questions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "question_parts" ADD CONSTRAINT "question_parts_parent_part_id_fkey" FOREIGN KEY ("parent_part_id") REFERENCES "question_parts"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "solution_steps" ADD CONSTRAINT "solution_steps_part_id_fkey" FOREIGN KEY ("part_id") REFERENCES "question_parts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "student_attempts" ADD CONSTRAINT "student_attempts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "student_attempts" ADD CONSTRAINT "student_attempts_paper_id_fkey" FOREIGN KEY ("paper_id") REFERENCES "exam_papers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "step_attempts" ADD CONSTRAINT "step_attempts_student_attempt_id_fkey" FOREIGN KEY ("student_attempt_id") REFERENCES "student_attempts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "step_attempts" ADD CONSTRAINT "step_attempts_step_id_fkey" FOREIGN KEY ("step_id") REFERENCES "solution_steps"("id") ON DELETE CASCADE ON UPDATE CASCADE;
