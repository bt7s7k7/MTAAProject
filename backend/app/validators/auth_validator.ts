import vine from '@vinejs/vine'

/** Validates a login request */
export const loginValidator = vine.compile(
  vine.object({
    email: vine.string(),
    password: vine.string(),
  })
)

/** Validates a register request */
export const registerValidator = vine.compile(
  vine.object({
    email: vine.string(),
    fullName: vine.string(),
    password: vine.string(),
  })
)
