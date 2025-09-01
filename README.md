# NavyBlue API - SA Exam Prep Platform

A comprehensive RESTful API for South African exam preparation, built with [Node.js](https://nodejs.org), [TypeScript](https://www.typescriptlang.org), [Express](https://expressjs.com), and [Prisma](https://www.prisma.io).

NavyBlue provides a self-marking exam preparation system where students can practice past papers and mark individual solution steps, enabling immediate feedback and personalized learning paths.

## Key Features

- **Self-Marking System**: Students mark individual solution steps for granular feedback
- **Curriculum-Aligned Content**: Supports CAPS and IEB syllabi for Mathematics and Physical Sciences
- **Topic-Based Progress**: Track performance across mathematical topics and subtopics
- **Offline-First Ready**: API designed for Flutter Brick offline synchronization
- **Admin Content Management**: Upload and manage exam papers, questions, and solution steps

## Quick Start

Clone the repository:

```bash
git clone <your-repo-url> navyblue-api
cd navyblue-api
```

Install dependencies:

```bash
pnpm install
```

Set up environment variables:

```bash
cp .env.example .env
# Edit .env with your database credentials and JWT secrets
```

Start PostgreSQL database:

```bash
docker run --name navyblue-postgres \
  -e POSTGRES_DB=navyblue_dev \
  -e POSTGRES_USER=navyblue \
  -e POSTGRES_PASSWORD=navyblue123 \
  -p 5432:5432 -d postgres:15-alpine
```

Initialize database:

```bash
pnpm db:push
pnpm db:seed # Optional: Load sample curriculum data
```

Start development server:

```bash
pnpm dev
```

## Table of Contents

- [Features](#features)
- [Commands](#commands)
- [Environment Variables](#environment-variables)
- [Project Structure](#project-structure)
- [API Documentation](#api-documentation)
- [Authentication](#authentication)
- [Self-Marking System](#self-marking-system)
- [Future Roadmap](#future-roadmap)
- [Error Handling](#error-handling)
- [Deployment](#deployment)

## Features

- **SQL Database**: [PostgreSQL](https://www.postgresql.org) with [Prisma](https://www.prisma.io) ORM
- **Authentication & Authorization**: JWT tokens with refresh token rotation
- **Self-Marking Engine**: Granular step-by-step solution marking system
- **Content Management**: Admin tools for uploading papers and managing users
- **Topic Progress Tracking**: Performance analytics by mathematical topics
- **Validation**: Request data validation using [Joi](https://joi.dev)
- **Logging**: Comprehensive logging with [Winston](https://github.com/winstonjs/winston)
- **API Documentation**: Auto-generated with [Swagger](https://swagger.io/)
- **Error Handling**: Centralized error handling with proper HTTP status codes
- **Security**: HTTP headers, XSS protection, and rate limiting
- **Testing**: Unit and integration tests with [Jest](https://jestjs.io)
- **Docker Support**: Containerized deployment ready
- **Process Management**: Production deployment with [PM2](https://pm2.keymetrics.io)

## Commands

Development:

```bash
pnpm dev          # Start development server with hot reload
pnpm build        # Build TypeScript to JavaScript
pnpm start        # Start production server
```

Database:

```bash
pnpm db:push      # Push schema changes to database
pnpm db:studio    # Open Prisma Studio database browser
pnpm db:seed      # Seed database with sample data
pnpm db:reset     # Reset database (destructive)
```

Testing:

```bash
pnpm test         # Run all tests
pnpm test:watch   # Run tests in watch mode
pnpm coverage     # Generate test coverage report
```

Docker:

```bash
pnpm docker:dev        # Run development container
pnpm docker:prod       # Run production container
pnpm docker:dev-db:start  # Start PostgreSQL container
pnpm docker:dev-db:stop   # Stop PostgreSQL container
```

Code Quality:

```bash
pnpm lint         # Run ESLint
pnpm lint:fix     # Fix ESLint errors
pnpm prettier     # Check Prettier formatting
pnpm prettier:fix # Fix Prettier formatting
```

## Environment Variables

```bash
# Server Configuration
PORT=8080
NODE_ENV=development

# Database
DATABASE_URL=postgresql://navyblue:navyblue123@localhost:5432/navyblue_dev

# JWT Authentication
JWT_SECRET=your-super-secret-jwt-key
JWT_ACCESS_EXPIRATION_MINUTES=1440
JWT_REFRESH_EXPIRATION_DAYS=30

# File Upload
MAX_FILE_SIZE=10MB
UPLOAD_PATH=./uploads

# Email (Optional)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
EMAIL_FROM=noreply@navyblue.co.za

# Admin Configuration
ADMIN_EMAIL=admin@navyblue.co.za
ADMIN_PASSWORD=change-in-production
```

## Project Structure

```
src/
 |--config/         # Configuration files and environment variables
 |--controllers/    # Request handlers and response logic
 |--docs/           # Swagger API documentation
 |--middlewares/    # Express middlewares (auth, validation, etc.)
 |--routes/         # API route definitions
 |--services/       # Business logic layer
 |--utils/          # Utility functions and helpers
 |--validations/    # Request validation schemas
 |--types/          # TypeScript type definitions
 |--app.ts          # Express application setup
 |--server.ts       # Server entry point
prisma/
 |--schema.prisma   # Database schema definition
 |--migrations/     # Database migration files
 |--seed.ts         # Database seeding script
```

## API Documentation

View the interactive API documentation at `http://localhost:8080/v1/docs` when running the server.

### Core API Endpoints

**Authentication:**
```
POST /v1/auth/register     # Student registration
POST /v1/auth/login        # User login
POST /v1/auth/refresh      # Refresh access token
GET  /v1/auth/me           # Get current user
```

**Papers & Questions:**
```
GET  /v1/papers                    # List exam papers (filtered)
GET  /v1/papers/:id                # Get specific paper with questions
GET  /v1/questions/:id             # Get question with parts/solutions
```

**Self-Marking System:**
```
POST /v1/attempts                  # Start new attempt
POST /v1/attempts/:id/mark-step    # Mark individual solution step
GET  /v1/attempts/:id/progress     # Get attempt progress
PUT  /v1/attempts/:id/complete     # Complete attempt
```

**Progress & Analytics:**
```
GET  /v1/users/progress           # User progress by topics
GET  /v1/users/weak-topics        # Areas needing improvement
```

**Admin Operations:**
```
POST /v1/admin/papers             # Upload exam papers
POST /v1/admin/images             # Upload question images
GET  /v1/admin/users              # Manage user accounts
```

## Authentication

NavyBlue uses JWT tokens with refresh token rotation for secure authentication.

### Student Registration
```typescript
POST /v1/auth/register
{
  "email": "student@school.co.za",
  "password": "securePassword123",
  "firstName": "John",
  "lastName": "Doe",
  "grade": "GRADE_12",
  "province": "GAUTENG",
  "syllabus": "CAPS"
}
```

### Admin Access
Admin users have additional permissions for content management and user administration. Admin status is assigned during user creation.

## Self-Marking System

The core innovation of NavyBlue is the granular self-marking system where students evaluate individual solution steps.

### How It Works

1. **Start Attempt**: Student begins working on a paper
2. **View Solutions**: Step-by-step worked solutions are provided
3. **Mark Steps**: Student marks each step as Correct/Incorrect/Not Attempted
4. **Calculate Progress**: Real-time scoring based on marked steps
5. **Track Analytics**: Performance data feeds into progress tracking

### Example Step Marking
```typescript
POST /v1/attempts/{attemptId}/mark-step
{
  "stepId": "step-uuid-123",
  "status": "CORRECT"
}
```

## Future Roadmap

### Planned Features
- **Practice Paper Generation**: Template-based papers matching official CAPS/IEB structures
- **AI-Powered Recommendations**: Personalized study plans based on performance analytics
- **Advanced Progress Analytics**: Detailed insights and readiness assessments
- **Multi-Subject Expansion**: Chemistry, Biology, and other STEM subjects
- **Collaborative Learning**: Study groups and peer comparison features
- **Mobile Optimization**: Enhanced Flutter app with full offline capabilities

### Long-term Vision
- **Institutional Dashboards**: School-wide analytics for educators
- **Adaptive Learning Paths**: Dynamic content adjustment based on learning patterns
- **Integration Ecosystem**: Seamless connection with existing educational platforms

## Error Handling

Centralized error handling provides consistent error responses:

```json
{
  "code": 400,
  "message": "Invalid request data",
  "stack": "Error stack (development only)"
}
```

Custom ApiError class for throwing specific errors:
```typescript
import { ApiError } from '../utils/ApiError';
import httpStatus from 'http-status';

throw new ApiError(httpStatus.NOT_FOUND, 'Paper not found');
```

## Validation

Request validation using Joi schemas ensures data integrity:

```typescript
const markStepSchema = {
  body: Joi.object().keys({
    stepId: Joi.string().required(),
    status: Joi.string().valid('CORRECT', 'INCORRECT', 'NOT_ATTEMPTED').required()
  })
};
```

## Deployment

### Development
```bash
pnpm dev
```

### Production with PM2
```bash
pnpm build
pm2 start ecosystem.config.js
```

### Docker
```bash
docker build -t navyblue-api .
docker run -p 8080:8080 --env-file .env navyblue-api
```

### Environment Setup
1. Set up PostgreSQL database
2. Configure environment variables
3. Run database migrations
4. Seed initial data (sample papers, admin users)
5. Configure file storage for images
6. Set up monitoring and logging

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**NavyBlue** - Empowering South African students with intelligent exam preparation and self-assessment tools.