import { Role, Grade, Province, Syllabus } from '@prisma/client';
import Joi from 'joi';
import { password } from './custom.validation';

const createUser = {
  body: Joi.object().keys({
    email: Joi.string().required().email(),
    password: Joi.string().required().custom(password),
    firstName: Joi.string().required(),
    lastName: Joi.string().required(),
    grade: Joi.string().required().valid(...Object.values(Grade)),
    province: Joi.string().required().valid(...Object.values(Province)),
    syllabus: Joi.string().valid(...Object.values(Syllabus)).optional(),
    schoolName: Joi.string().optional(),
    role: Joi.string().valid(...Object.values(Role)).optional()
  })
};

const getUsers = {
  query: Joi.object().keys({
    firstName: Joi.string(),
    lastName: Joi.string(),
    role: Joi.string().valid(...Object.values(Role)),
    grade: Joi.string().valid(...Object.values(Grade)),
    province: Joi.string().valid(...Object.values(Province)),
    sortBy: Joi.string(),
    limit: Joi.number().integer(),
    page: Joi.number().integer()
  })
};

const getUser = {
  params: Joi.object().keys({
    userId: Joi.string().required() // cuid
  })
};

const updateUser = {
  params: Joi.object().keys({
    userId: Joi.string().required() // cuid
  }),
  body: Joi.object()
    .keys({
      email: Joi.string().email(),
      password: Joi.string().custom(password),
      firstName: Joi.string(),
      lastName: Joi.string(),
      grade: Joi.string().valid(...Object.values(Grade)),
      province: Joi.string().valid(...Object.values(Province)),
      syllabus: Joi.string().valid(...Object.values(Syllabus)),
      schoolName: Joi.string(),
      role: Joi.string().valid(...Object.values(Role))
    })
    .min(1)
};

const deleteUser = {
  params: Joi.object().keys({
    userId: Joi.string().required() // cuid
  })
};

export default {
  createUser,
  getUsers,
  getUser,
  updateUser,
  deleteUser
};
