import vine from '@vinejs/vine'

export const userUpdateValidator = vine.compile(
  vine.object({
    name: vine.string().nullable(),
    password: vine.string().nullable(),
  })
)
