import { Role } from '@prisma/client';

const allRoles = {
  [Role.USER]: [],
  [Role.ADMIN]: [
    'getUsers',
    'manageUsers',
    'uploadPapers',
    'uploadImages',
    'manageContent'
  ]
};

export const roles = Object.keys(allRoles);
export const roleRights = new Map(Object.entries(allRoles));
