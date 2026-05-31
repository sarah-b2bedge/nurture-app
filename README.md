# Nurture Assistant

Mobile-first UX deliverables for **Nurture Assistant**, an AI assistant that helps new parents quickly track infant care through natural-language logging, quick add actions, safety-first medicine confirmation, and simple dashboards.

## Deliverables

- Flutter web app
  - Mobile-first implementation for web using Flutter.
  - Includes account entry, create account, log in, onboarding, dashboard, AI review, quick add, timeline, medicine, supplies, guide, settings, profile, change password, and subscription/payment screens.
- [UX specification](docs/nurture-assistant-ux.md)
  - User flow map
  - Mobile wireframes
  - Navigation structure
  - User management: account entry, create account, log in, profile, and change password
  - Subscription and payment page
  - AI logging and medicine confirmation flow
  - Quick Add forms
  - Empty, error, and confirmation states
  - Design system and high-fidelity UI direction
- [Static mobile prototype](prototype/index.html)
  - Self-contained HTML/CSS prototype with the primary mobile screens and states, including account and subscription/payment flows.

## Running the Flutter web app

```sh
flutter pub get
flutter run -d chrome
```

For a static web build:

```sh
flutter build web
```

## Viewing the original static prototype

Open `prototype/index.html` in a browser. No build step or dependencies are required.
