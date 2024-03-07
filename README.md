# Social Video App

## Description

This project is a take-home interview task designed as a social video application for iOS. The app allows users to browse a feed of videos, post their own videos, and view their profile with the videos they have created. It interacts with a backend server through specific API endpoints to fetch and post data.

## Features

- **Home Screen (Feed):** Displays a feed of videos from various users, showing the video content, the username of the uploader, and the number of likes. Includes a "pull-to-refresh" feature to reload the feed.
- **Post Page:** Displays the video content, the user's profile details (username, profile picture, etc.), and a like button.
- **Profile Page:** Shows the user's profile information, including their username and profile picture, and displays a grid or list of posts that the user has created.

## API Endpoints

The app mocks a server and calls the following endpoints:

- **GET /api/feed:** Fetches the feed of videos for the home screen.
- **GET /api/post/{post_id}:** Retrieves data for a particular post.
- **GET /api/profile/{username}:** Fetches the user's profile information and posts.

## Installation

Before you start, ensure you have CocoaPods installed on your machine. If not, install it by running:

```bash
sudo gem install cocoapods

pod install
open [Your-Project-Name].xcworkspace
