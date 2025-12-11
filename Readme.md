
# Amrita Retriever – Lost & Found Application
<img src= "assets/logo.png">
A cross-platform Lost & Found system built for students, staff, and administrators at Amrita.

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-blue?style=flat-square"/>
  <img src="https://img.shields.io/badge/Frontend-Flutter-orange?style=flat-square"/>
  <img src="https://img.shields.io/badge/Backend-Node.js-green?style=flat-square"/>
  <img src="https://img.shields.io/badge/Database-Supabase-3ECF8E?style=flat-square"/>
  <img src="https://img.shields.io/badge/Auth-Supabase%20Auth-3ECF8E?style=flat-square"/>
</p>

---

## Overview

Amrita Retriever is a campus-wide lost and found application designed to streamline the reporting, listing, and claiming of lost items within Amrita University.

It consists of:
- Flutter Mobile Application (Students and Staff)
- React-based Admin Dashboard (Administrators)
- Node.js Backend integrated with Supabase

The platform ensures secure authentication, a clean user interface, and efficient item reporting and claim management.

---

## Key Features

### For Students & Staff (Mobile Application)
- Secure login using Supabase Authentication  
- Browse lost items with:
  - Photos  
  - Location  
  - Description  
  - Date found  
- Filter items by block, category, or keywords  
- Submit claim requests  
- Fully responsive UI for Android and iOS   

### For Administrators (Web Dashboard)
- Upload newly found items  
- Add item details including name, image, location, date, and finder information  
- Manage verification and claim processing  
- Update claim instructions  
- Filter, sort, and search across all items  

---

## Tech Stack

| Layer            | Technology                     |
|------------------|--------------------------------|
| Mobile App       | Flutter (Dart)                 |
| Web Dashboard    | React.js, Tailwind CSS         |
| Backend          | Node.js, Express.js            |
| Database         | SupaBase                       |
| Image Storage    | SupaBase Bucket                |

---

## Authentication Flow

1. User initiates login and is redirected to Supabase.  
2. SupaBase validates identity and returns the user profile.  
3. Backend creates or updates the user entry in SupaBase.  
---


### Image Flow
1. Images are uploaded and stored in the Supabase bucket.  
2. Image URL and metadata are stored in Supabase for retrieval.

---

## UI Screenshots

Suggested screenshots to include:
- Login Screen  
- Student Lost Items View  
- Admin Add Item Page  
- Admin Claim Item Page  
- Admin Dashboard  

(Add actual images in your repository’s `/assets` folder.)

---

## How to Run the Project

### Backend Setup
First clone the repository.
Then, run the following:
`cd backend
npm install
npm start`

### Mobile Application:
`cd frontend
flutter run
`

### Admin Dashboard:
`cd admin
npm install
npm start
`


