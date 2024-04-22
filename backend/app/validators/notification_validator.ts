import vine from '@vinejs/vine'

/** Validates notification enable request */
export const notificationValidator = vine.compile(
  vine.object({
    pushToken: vine.string(),
  })
)
