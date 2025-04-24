# Voyager

Development of a Mobile-based Mentorship Application using Flutter for Computer Science Students at VSU

| Internal Release Code | Date Released |
| --------------------- | ------------- |
| VG.010.001            | 2025-03-12    |
| VG.010.002            | 2025-03-24    |
| VG.010.003            | 2025-03-29    |
| VG.010.004            | 2025-04-02    |
| VG.010.005            | 2025-04-12    |
| VG.010.006            | 2025-04-15    |
| VG.010.007            | 2025-04-21    |
| VG.010.008            | 2025-04-24    |

## VG.010.008 Release Notes
**Admin Features**  
- Added custome photos for admin's mentor card
- Added safearea on dashboard for three interfaces
- Fix bugs on coverphot, create of empty course, mentor pop-up, and number of mentees bugs
- Improve UI in admin interface
- Implemented darft view in mentors list
  
**Mentor Features**
- UI improvement in mentor screen
- Improve the native splash
- Ensurve valid link and input checking
- Added lottie files to improve UI
- Fix bugs in the update of mentor information
- Update mentee home interface
- Improve UI of the splash screen when transitioning
- Fix the functionality in the reject feature of a mentee
- Add interface for error and encapsulate the screens on the scaffold

 **Mentee Features**
- Update course list and mentor list
- Add refresh functionality on mentee home
- Update course display logic
- Improve interface in mentee UI
- Update course card


## VG.010.007 Release Notes
**Admin Features**  
- Alignment of mentor status
- Refactor the widget cards for improve UI
- Proper navigation for canceling adding mentor
  
**Mentor Features**
- Implemented search functionality in mentee interface
- Implemented display feature for course view
- Improve UI for expertise to make it responsive design
- Implemented a notification view
- Implemented regular schedule view in calendar
- Enhance and improve the mentor profile view across the interfaces

 **Mentee Features**
- Improve the session filtering
- Improve the interface for mentee home
- Added features for mentor profile
- Implemented the mentee personal information

## VG.010.006 Release Notes
**Admin Features**  
- Fixed social account links 
- Added course details interface
- Fix issue in connecting with firestore
- Add additional content for admin profile
- Add additional administrative actions (update, edit, archive)
- Adjusted the UI for admin to follow standard designs
  
**Mentor Features**
- Replace Stack with CustomScrollView in viewing mentor info
- Implemented sorting for upcoming schedule
- Ensury query posts can be shown only for enrolled and accepted mentee
- Ensure links are clickable in post and adaptive sizing for mentee list
- Centralize video control for post to pause on screen transition

 **Mentee Features**
- Update the viewing of session for mentee
- Implement the backend for notifications to query from database
- Update the firestore instance to add backend features for mentee (enroll functionality)
- Fix issue in overlapping card elements
- Fix bug in incorrect parameters passed 

## VG.010.005 Release Notes
**Admin Features**  
- Fixed admin profile rendering issues across devices
- Resolved avatar loading errors in the admin dashboard
- Fixed responsive layout for admin panels on mobile devices
- Fixed filter persistence across pagination
- Integrated Supabase Storage for profile pictures 
- Automated Firebase Firestore document generation
- Added comprehensive mentor detail modals
- Multi-select interface for mentor assignment


**Mentor Features**
- Improve mentor info update experience and multiselect UI
- Correctly update and fetch user pic and username from Firebase and Supabase
- Improve user image loading performance
- Ensure profile picture and info update correctly
- Update Mentor Information and saves it to firebase and supabase

 **Mentee Features**
- Add Enroll Course Function
- Add Database Connection to Mentor Profile
- View and get courses from database
- Populate data for courses from firebase
  
  
## VG.010.004 Release Notes
**Mentor Features**  
- Enabled mentor profile update functionality
- Implemented screen refresh on navigation transitions
- Integrated search functionality with refresh support
- Resolved code warnings and errors for improved debugging
- Updated mentor schedule view with real-time updates
  
**System Improvements**
- Enhanced backend query performance
- Implemented data sorting capabilities


## VG.010.003 Release Notes
**Admin Panel**  
- Added admin profile management screen  
- Implemented course creation interface  
- Developed course list view with filtering capabilities  
- Built detailed course information view
   
**Mentor Features**  
- Connected mentee list to Firebase backend  
- Implemented post creation interface with file attachment support  
- Integrated post functionality with Firebase/Supabase backend  
- Added post display with downloadable attachments
  
**Mentee Features**  
- Developed mentor profile viewing interface  
- Implemented course enrollment interface  
- Built backend for displaying mentor cards  

## VG.010.002 Release Notes
- Migrated back to Firebase for Authentication, Supabase for storage 
- UI Updates for Admin, Mentor, and Mentee interfaces
- Set up the authentication for users
- **Commit Messages**
- Add admin interface
- Migrate from Supabase Auth to Firebase Auth
- Ensure password-based authentication during user registration

## VG.010.001 Release Notes
- Added assets and Supabase configuration  
- Configured project dependencies  
- Set up project with structured architecture  
- **Commit Messages**
- Update pubspec.yaml with dependencies and assets  
- Initialize Flutter project with structured architecture  
- Improve README.md formatting  
- Set up Supabase and integrate with main.dart  
- Simplify and standardize theme design  

## VG.010.000 Release Notes
- [MD03] Update mockup image links to remove token dependency
- [MD02] Update mockup image links to remove token dependency
- [MD01] Update mockup image links to remove token dependency
- Format versioning table to follow guidelines
- Update README formatting and versioning guide
- Add README file
  
Important Links:
- Design Specs: https://github.com/VSUrhuel/voyager-dev/
- Code Based: https://github.com/VSUrhuel/voyager
- Testing timeline: https://docs.google.com/spreadsheets/d/1zHLYSz4JuLxLTUGvIjhp0272QfydunSh-wI66Z5jg2I/edit?usp=sharing

