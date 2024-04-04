import vine from '@vinejs/vine'

export const activityValidator = vine.compile(
  vine.object({
    activityName: vine.string().maxLength(255),
    points: vine.number().min(0).max(1000),
    distance: vine.number(),
    steps: vine.number(),
    duration: vine.number(),
    path: vine.string().maxLength(2000).optional(),
  })
)
