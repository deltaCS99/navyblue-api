import httpStatus from 'http-status';
import tokenService from './token.service';
import userService from './user.service';
import ApiError from '../utils/ApiError';
import { TokenType, User } from '@prisma/client';
import prisma from '../client';
import { encryptPassword, isPasswordMatch } from '../utils/encryption';
import { AuthTokensResponse } from '../types/response';

/**
 * Login with email and password
 */
const loginUserWithEmailAndPassword = async (
  email: string,
  password: string
): Promise<Omit<User, 'password'>> => {
  const user = await userService.getUserByEmail(email, [
    'id',
    'email',
    'firstName',
    'lastName',
    'password',
    'grade',
    'province',
    'syllabus',
    'schoolName',
    'role',
    'isEmailVerified',
    'createdAt',
    'updatedAt'
  ]);


  if (!user || !(await isPasswordMatch(password, user.password as string))) {
    throw new ApiError(httpStatus.UNAUTHORIZED, 'Incorrect email or password');
  }

  const { password: _password, ...rest } = user;
  return rest;
};

/**
 * Logout by deleting refresh token
 */
const logout = async (refreshToken: string): Promise<void> => {
  const refreshTokenData = await prisma.token.findFirst({
    where: {
      token: refreshToken,
      type: TokenType.REFRESH,
      blacklisted: false
    }
  });

  if (!refreshTokenData) {
    throw new ApiError(httpStatus.NOT_FOUND, 'Not found');
  }

  await prisma.token.delete({ where: { id: refreshTokenData.id } });
};

/**
 * Refresh auth tokens
 */
const refreshAuth = async (refreshToken: string): Promise<AuthTokensResponse> => {
  try {
    const refreshTokenData = await tokenService.verifyToken(refreshToken, TokenType.REFRESH);
    const { userId } = refreshTokenData;

    await prisma.token.delete({ where: { id: refreshTokenData.id } });

    return tokenService.generateAuthTokens({ id: userId });
  } catch (error) {
    throw new ApiError(httpStatus.UNAUTHORIZED, 'Please authenticate');
  }
};

/**
 * Reset password
 */
const resetPassword = async (resetPasswordToken: string, newPassword: string): Promise<void> => {
  try {
    const resetTokenData = await tokenService.verifyToken(resetPasswordToken, TokenType.RESET_PASSWORD);
    const user = await userService.getUserById(resetTokenData.userId);

    if (!user) throw new ApiError(httpStatus.NOT_FOUND, 'User not found');

    const encryptedPassword = await encryptPassword(newPassword);
    await userService.updateUserById(user.id, { password: encryptedPassword });

    await prisma.token.deleteMany({ where: { userId: user.id, type: TokenType.RESET_PASSWORD } });
  } catch (error) {
    throw new ApiError(httpStatus.UNAUTHORIZED, 'Password reset failed');
  }
};

/**
 * Verify email
 */
const verifyEmail = async (verifyEmailToken: string): Promise<void> => {
  try {
    const verifyTokenData = await tokenService.verifyToken(verifyEmailToken, TokenType.VERIFY_EMAIL);

    await prisma.token.deleteMany({
      where: { userId: verifyTokenData.userId, type: TokenType.VERIFY_EMAIL }
    });

    await userService.updateUserById(verifyTokenData.userId, { isEmailVerified: true });
  } catch (error) {
    throw new ApiError(httpStatus.UNAUTHORIZED, 'Email verification failed');
  }
};

export default {
  loginUserWithEmailAndPassword,
  logout,
  refreshAuth,
  resetPassword,
  verifyEmail
};
