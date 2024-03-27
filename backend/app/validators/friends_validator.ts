import vine from '@vinejs/vine'

export const searchFriendsValidator = vine.compile(
  vine.object({
    query: vine.string(),
  })
)
