import vine from '@vinejs/vine'

export const loginValidator = vine.compile(
  vine.object({
    email: vine.string(),
    password: vine.string(),
  })
)

export const registerValidator = vine.compile(
  vine.object({
    email: vine.string(),
    fullName: vine.string(),
    password: vine.string(),
  })
)
