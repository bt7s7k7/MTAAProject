import vine from '@vinejs/vine'

export const activityValidator = vine.compile(
  vine.object({
    activityName: vine.string().maxLength(255),
    points: vine.number().min(0),
    distance: vine.number().min(0),
    steps: vine.number().min(0),
    duration: vine.number().min(0),
    path: vine.string().maxLength(2000).optional(),
  })
)
