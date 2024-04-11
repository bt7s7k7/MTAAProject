import vine from '@vinejs/vine'

export const likeValidator = vine.compile(
  vine.object({
    activityId: vine.number().min(1),
  })
)
