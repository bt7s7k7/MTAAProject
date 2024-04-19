import vine from '@vinejs/vine'

export const notificationValidator = vine.compile(
  vine.object({
    pushToken: vine.string(),
  })
)
