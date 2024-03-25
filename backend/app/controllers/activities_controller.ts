// import type { HttpContext } from '@adonisjs/core/http'

// export default class ActivitiesController {
//     // GET /activity
//     // Returns a list of activities, both the user's own and their friends'
//     async index({ auth }: HttpContext) {
//       const user = auth.user!;
//       const activities = await user.getActivitiesWithFriends(); // Assuming a method to fetch user's and friends' activities

//       return activities.map((activity) => activity.serialize());
//     }

//     // GET /activity/user/:id
//     // Returns activities of a given user, if they are friends
//     async userActivities({ auth, params }: HttpContext) {
//       const user = auth.user!;
//       const targetUserId = params.id;
//       if (!await user.isFriendWith(targetUserId)) { // Assuming a method to check if users are friends
//         return { error: 'You can only view activities of your friends.' };
//       }

//       const activities = await Activity.query().where('user_id', targetUserId);
//       return activities.map((activity) => activity.serialize());
//     }

//     // GET /activity/:id
//     // Returns details of a specific activity if it belongs to the user or a friend
//     async show({ auth, params }: HttpContext) {
//       const user = auth.user!;
//       const activity = await Activity.findOrFail(params.id);

//       if (activity.userId !== user.id && !await user.isFriendWith(activity.userId)) {
//         return { error: 'You can only view your own activities or those of your friends.' };
//       }

//       return activity.serialize();
//     }

//     // POST /activity
//     // Creates a new activity
//     async store({ auth, request }: HttpContext) {
//       const user = auth.user!;
//       const data = request.only(['title', 'description', 'location', 'time']); // Example fields
//       const activity = await user.related('activities').create(data); // Assuming a relation is set up

//       return activity.serialize();
//     }

//     // POST /activity/:id/like
//     // Likes an activity
//     async like({ auth, params }: HttpContext) {
//       const user = auth.user!;
//       const activityId = params.id;
//       const liked = await user.likeActivity(activityId); // Assuming a method to like an activity

//       if (!liked) {
//         return { error: 'Unable to like the activity.' };
//       }

//       return { message: 'Activity liked successfully.' };
//     }
//   }
