# backend/app.py
# Updated: 2025-01-24 - Fixed scheduler detection for ultra-light mode
"""
Warracker Flask Application Entry Point

This file creates the Flask application using the Application Factory pattern.
The actual application configuration and initialization is handled by the factory.
"""
import os
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create the app instance using the factory
try:
    from . import create_app
    from . import db_handler
    
    app = create_app(os.getenv('FLASK_CONFIG') or 'default')
    logger.info("Application created successfully using factory pattern")
    
    # Initialize the notification scheduler with the created app context
    try:
        from . import notifications
        
        with app.app_context():
            notifications.init_scheduler(app, db_handler.get_db_connection, db_handler.release_db_connection)
            logger.info("Notification scheduler initialized successfully")
    except Exception as e:
        logger.error(f"Failed to initialize notification scheduler: {e}")
        # Continue without notifications - the app can still function
    
except ImportError:
    # Fallback for development environment
    from __init__ import create_app
    import db_handler
    
    app = create_app(os.getenv('FLASK_CONFIG') or 'default')
    logger.info("Application created successfully using factory pattern (development mode)")
    
    # Initialize the notification scheduler with the created app context
    try:
        import notifications
        
        with app.app_context():
            notifications.init_scheduler(app, db_handler.get_db_connection, db_handler.release_db_connection)
            logger.info("Notification scheduler initialized successfully")
    except Exception as e:
        logger.error(f"Failed to initialize notification scheduler: {e}")
        # Continue without notifications - the app can still function

except Exception as e:
    logger.critical(f"CRITICAL: Failed to create application: {e}")
    raise

# The app object is now ready for Gunicorn/Docker to use
# For local development, you can run: flask run
# For production, Gunicorn will use: gunicorn "backend:create_app()"

if __name__ == '__main__':
    # This is only for local development
    app.run(debug=True, host='0.0.0.0', port=5000)
