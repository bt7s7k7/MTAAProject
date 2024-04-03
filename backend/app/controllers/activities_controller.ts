// controllers/ActivityController.ts
import type { HttpContextContract } from '@adonisjs/core/build/standalone';
import Activity from '#models/activity';

export default class ActivityController {
  public async index({ auth }: HttpContextContract) {
    const user = auth.user!;
    return await Activity.query().where('userId', user.id);
  }

  public async store({ auth, request }: HttpContextContract) {
    const user = auth.user!;
    const data = request.only(['activityName', 'points', 'distance', 'steps', 'duration', 'path']);

    const activity = await user.related('activities').create(data);
    return activity;
  }

  public async show({ params }: HttpContextContract) {
    return await Activity.findOrFail(params.id);
  }

  public async update({ request, params }: HttpContextContract) {
    const activity = await Activity.findOrFail(params.id);
    const data = request.only(['activityName', 'points', 'distance', 'steps', 'duration', 'path']);

    activity.merge(data);
    await activity.save();

    return activity;
  }

  public async destroy({ params }: HttpContextContract) {
    const activity = await Activity.findOrFail(params.id);
    await activity.delete();
    return { message: 'Activity deleted' };
  }
}
