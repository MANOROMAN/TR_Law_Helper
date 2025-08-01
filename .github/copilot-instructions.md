<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# Hukuki Asistan Flutter App

This is a Flutter mobile application for Turkish legal assistance. The app provides AI-powered legal consultation using Google's Gemini API, along with lawyer contact, document management, and calendar features.

## Key Features:
- AI Chat with Gemini API integration for Turkish legal advice
- Lawyer contact screen with phone, WhatsApp, email options
- Document management with categorization
- Calendar for scheduling appointments and court dates

## Tech Stack:
- Flutter framework
- Gemini AI API for legal consultation
- Material Design UI components
- Local storage with SharedPreferences
- File picker for document uploads
- URL launcher for communication features
- Table calendar for scheduling

## Code Guidelines:
- Use Turkish language for UI text and user-facing content
- Follow Material Design principles
- Implement proper error handling for API calls
- Use consistent color scheme (primary: #2D3E50)
- Maintain clean architecture with separate screens and services
- Focus on legal domain-specific features and terminology

## API Configuration:
- Replace 'YOUR_GEMINI_API_KEY_HERE' in services/gemini_service.dart with actual Gemini API key
- The AI is configured with specific prompt engineering for Turkish legal system expertise only
