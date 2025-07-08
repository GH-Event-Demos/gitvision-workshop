The lib/utils/ folder in your GitVision codebase is used for utility functions and helper classes that provide common, reusable logic across the app.

Key roles of lib/utils/:

Contains stateless functions or classes for tasks like formatting dates, parsing data, string manipulation, or handling common calculations.
Promotes code reuse and keeps business logic and UI code clean by moving generic helpers out of screens, services, and models.
Makes it easier to test and maintain utility logic in one place.
Should not contain app state or business logic specific to a single feature.
In summary, lib/utils/ is where you put general-purpose helpers that can be used anywhere in the app to keep your code DRY and organized.