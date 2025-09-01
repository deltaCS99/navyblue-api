import httpStatus from 'http-status';
import pick from '../utils/pick';
import ApiError from '../utils/ApiError';
import catchAsync from '../utils/catchAsync';
import userService from '../services/user.service';
import { Role, Grade, Province, Syllabus } from '@prisma/client';

const createUser = catchAsync(async (req, res) => {
  const { email, password, firstName, lastName, grade, province, syllabus, schoolName, role } = req.body;

  // validate required fields
  if (!email || !password || !firstName || !lastName || !grade || !province) {
    throw new ApiError(httpStatus.BAD_REQUEST, 'Missing required user fields');
  }

  const user = await userService.createUser({
    email,
    password,
    firstName,
    lastName,
    grade: grade as Grade,
    province: province as Province,
    syllabus: syllabus as Syllabus | undefined,
    schoolName,
    role: role as Role | undefined
  });

  res.status(httpStatus.CREATED).send(user);
});

const getUsers = catchAsync(async (req, res) => {
  const filter = pick(req.query, ['firstName', 'lastName', 'email', 'role', 'grade', 'province']);
  const options = pick(req.query, ['sortBy', 'limit', 'page', 'sortType']);
  const users = await userService.queryUsers(filter, options);
  res.send(users);
});

const getUser = catchAsync(async (req, res) => {
  const user = await userService.getUserById(req.params.userId);
  if (!user) {
    throw new ApiError(httpStatus.NOT_FOUND, 'User not found');
  }
  res.send(user);
});

const updateUser = catchAsync(async (req, res) => {
  const user = await userService.updateUserById(req.params.userId, req.body);
  res.send(user);
});

const deleteUser = catchAsync(async (req, res) => {
  await userService.deleteUserById(req.params.userId);
  res.status(httpStatus.NO_CONTENT).send();
});

export default {
  createUser,
  getUsers,
  getUser,
  updateUser,
  deleteUser
};
