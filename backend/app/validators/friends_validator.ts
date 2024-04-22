import vine from '@vinejs/vine'

/** Validates a user search request */
export const searchFriendsValidator = vine.compile(
  vine.object({
    query: vine.string(),
  })
)
