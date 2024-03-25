// import type { HttpContext } from '@adonisjs/core/http'

// export default class FriendsController {
//     // GET /friends
//     // This method returns a list of friends for the authenticated user
//     async index({ auth }: HttpContext) {
//       const user = auth.user!;
//       const friends = await user.getFriends(); // Assuming there's a method to get friends

//       return friends.map((friend) => friend.serialize());
//     }

//     // GET /friends/search?query=someone
//     // This method searches for users based on a query string
//     async search({ request, auth }: HttpContext) {
//       const query = request.input('query');
//       const results = await User.search(query); // Assuming a static search method on the User model

//       return results.map((user) => user.serialize());
//     }

//     // POST /friends/invite
//     // This method sends a friend invite from the authenticated user to another user
//     async invite({ request, auth }: HttpContext) {
//       const recipientId = request.input('recipientId');
//       const user = auth.user!;
//       const invite = await user.sendFriendInvite(recipientId); // Assuming a method to send a friend invite

//       return {
//         message: 'Friend invite sent successfully',
//         invite: invite.serialize(),
//       };
//     }

//     // POST /friends/accept
//     // This method allows a user to accept a friend invite
//     async accept({ request, auth }: HttpContext) {
//       const inviteId = request.input('inviteId');
//       const user = auth.user!;
//       const invite = await user.acceptFriendInvite(inviteId); // Assuming a method to accept a friend invite

//       return {
//         message: 'Friend invite accepted successfully',
//         friend: invite.friend.serialize(), // Assuming the invite has a friend property
//       };
//     }
//   }
