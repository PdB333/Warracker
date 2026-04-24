# backend/extensions.py
import logging
from authlib.integrations.flask_client import OAuth
from flask_cors import CORS
from flask_bcrypt import Bcrypt

logger = logging.getLogger(__name__)

# Initialize extensions without app instance
oauth = OAuth()
cors = CORS()
bcrypt = Bcrypt()
babel = None  # Will be initialized in initialize_extensions
db_pool = None  # Database connection pool

def initialize_extensions(app):
    """Initialize all extensions with the Flask app object."""
    global babel, db_pool
    
    logger.info("Initializing Flask extensions...")
    
    # Initialize OAuth
    oauth.init_app(app)
    logger.info("OAuth initialized")
    
    # Initialize CORS with credentials support
    cors.init_app(app, supports_credentials=True)
    logger.info("CORS initialized")
    
    # Initialize Bcrypt
    bcrypt.init_app(app)
    logger.info("Bcrypt initialized")
    
    # Initialize Babel for localization
    try:
        from .localization import init_babel, get_current_language
        babel = init_babel(app)
        logger.info("Babel localization initialized successfully")
    except ImportError:
        try:
            from localization import init_babel, get_current_language
            babel = init_babel(app)
            logger.info("Babel localization initialized successfully")
        except ImportError as e:
            logger.error(f"Failed to initialize localization: {e}")
            babel = None
    
    # Initialize the database connection pool
    try:
        from .db_handler import init_db_pool
        db_pool = init_db_pool()
        logger.info("Database connection pool initialized successfully")
    except ImportError:
        try:
            from db_handler import init_db_pool
            db_pool = init_db_pool()
            logger.info("Database connection pool initialized successfully")
        except ImportError as e:
            logger.critical(f"CRITICAL: Failed to initialize database pool: {e}")
            raise
    
    # Initialize Apprise notification handler
    try:
        try:
            from .apprise_handler import AppriseNotificationHandler
        except ImportError:
            from apprise_handler import AppriseNotificationHandler
        
        apprise_handler = AppriseNotificationHandler()
        app.config['APPRISE_HANDLER'] = apprise_handler
        app.config['APPRISE_AVAILABLE'] = True
        logger.info("Apprise notification handler initialized successfully")
    except ImportError as e:
        app.config['APPRISE_HANDLER'] = None
        app.config['APPRISE_AVAILABLE'] = False
        logger.warning(f"Apprise not available: {e}. Notification features will be disabled.")
    
    logger.info("All extensions initialized successfully") 