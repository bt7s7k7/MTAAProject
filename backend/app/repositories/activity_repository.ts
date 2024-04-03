// repositories/ActivityRepository.ts
import Activity from '#models/activity';
import User from '#models/user';
import { DateTime } from 'luxon';

export class ActivityRepository {
  async findUserActivities(userId: number) {
    return await Activity.query().where('userId', userId);
  }

  async findRecentActivitiesForFriends(userId: number, days: number = 1) {
    const fromDate = DateTime.now().minus({ days }).toJSDate();
    
    // Najskôr získajte zoznam ID priateľov
    const friendsIds = await User.query()
      .whereHas('friends', (query) => {
        query.where('users.id', userId); // alebo akékoľvek iné podmienky, ktoré definujú 'kamarátov'
      })
      .pluck('id'); // pluck získa len pole ID priateľov

    
    return await Activity.query()
      .whereIn('userId', friendsIds)
      .andWhere('created_at', '>=', fromDate);
  }

  
}
