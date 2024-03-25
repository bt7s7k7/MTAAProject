// // import type { HttpContext } from '@adonisjs/core/http'

// export default class UserController {
//     // GET /user
//     // Returns details of the logged-in user
//     async index({ auth }: HttpContext) {
//       const user = auth.user!;
//       return user.serialize();
//     }

//     // POST /user
//     // Updates user data
//     async update({ auth, request }: HttpContext) {
//       const user = auth.user!;
//       const data = request.only(['name', 'email', 'bio']); // Assuming these are the fields you allow to update
//       user.merge(data);
//       await user.save();

//       return user.serialize();
//     }

//     // POST /user/photo
//     // Handles profile picture upload
//     async uploadPhoto({ auth, request }: HttpContext) {
//       const user = auth.user!;
//       const photo = request.file('photo', { size: '2mb' }); // Validate file size

//       if (photo) {
//         await photo.move(`./uploads/users/${user.id}`, {
//           name: `profile.${photo.extname}`, // Save with a custom name
//         });

//         // Update user's profile picture URL/path in the database
//         // Assuming there's a field `profile_photo` in the User model
//         user.profilePhoto = `uploads/users/${user.id}/profile.${photo.extname}`;
//         await user.save();
//       }

//       return { message: 'Profile photo uploaded successfully', path: user.profilePhoto };
//     }

//     // GET /user/:id
//     // Returns details of a selected user, if they are friends
//     async show({ auth, params }: HttpContext) {
//       const user = auth.user!;
//       const targetUserId = params.id;

//       if (!await user.isFriendWith(targetUserId)) { // Assuming a method to check friendship
//         return { error: 'You can only view details of your friends.' };
//       }

//       const friend = await User.findOrFail(targetUserId);
//       return friend.serialize();
//     }
//   }
