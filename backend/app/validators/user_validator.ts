import vine from '@vinejs/vine'

/** Validates user account update request */
export const userUpdateValidator = vine.compile(
  vine.object({
    name: vine.string().optional(),
    password: vine.string().optional(),
  })
)
