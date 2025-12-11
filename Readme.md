🐕‍🦺 Amrita Retriever – Lost & Found App for Amrita University

A cross-platform Lost & Found system for students, staff, and administrators.

<p align="center"> <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-blue?style=flat-square"/> <img src="https://img.shields.io/badge/Frontend-Flutter-orange?style=flat-square"/> <img src="https://img.shields.io/badge/Backend-Node.js-green?style=flat-square"/> <img src="https://img.shields.io/badge/Database-Supabase-3ECF8E?style=flat-square"/> <img src="https://img.shields.io/badge/Auth-Supabase%20Auth-3ECF8E?style=flat-square"/> </p>
📌 Overview

Amrita Retriever is a campus-wide lost and found application designed to streamline the process of reporting, viewing, and claiming lost items at Amrita University.
It consists of:

📱 Flutter Mobile App (Students + Staff)
🖥️ React Admin Dashboard (Admins)
🔗 Node.js Backend with Supabase

The system ensures secure authentication, clean UI, and fast reporting/claiming of items.

✨ Key Features
👨‍🎓 For Students & Staff (Mobile App)

🔐 Login with Supabase authentication

🔍 Browse lost items with:
Photos
Location
Description
Date found

🎯 Filter items by block, category, or keywords

📤 Submit a claim request

📲 Fully responsive UI for Android & iOS

🔑 Secure JWT-based API access

🛠️ For Admins (Web App)

📤 Upload newly found items

📝 Add details: name, image, location, date, finder’s details

🪪 Manage verification and claiming process

🔄 Update claim instructions

🔎 Filter, Sort & Search all items

🧰 Tech Stack
Layer	Technology
Mobile App	Flutter (Dart)

Web Dashboard	React.js + Tailwind CSS

Backend	Node.js + Express.js

Authentication	Microsoft OAuth 2.0

Database	MongoDB

Image Storage	Amazon S3 Bucket

🔐 Authentication Flow

User initiates login → Redirects to Microsoft OAuth

Microsoft validates identity & returns profile

Backend creates or updates user in MongoDB

User receives JWT token

Token used for secure backend communication

🗄️ Database Schema




Image Flow:

Images uploaded → stored in Supabase bucket

Supabase bucket URL + metadata → stored in Supabase

🖼️ UI Screenshots

📸 Login Screen  
📸 Student Lost Items View  
📸 Admin Add Item  
📸 Admin Claim Item  
📸 Admin Dashboard  

(Add actual images in your repo’s /assets folder)

🧪 How to Run the Project

🖥 Backend Setup

cd backend
npm install
npm start

📱 Mobile App (Flutter)

cd mobile
flutter run

🌐 Admin Dashboard

cd admin
npm install
npm start

👥 Team

Team 404 Not Lost
