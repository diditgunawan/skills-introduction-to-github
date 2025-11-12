"""
Configuration file for the Big Data ML/AI Image Processing System
Manages different environment configurations
"""

import os
from datetime import timedelta


class Config:
    """Base configuration"""
    # Application
    SECRET_KEY = os.getenv('SECRET_KEY', 'dev-secret-key-change-in-production')
    APP_NAME = 'BigData ML/AI Image Processing'
    
    # Database
    SQLALCHEMY_DATABASE_URI = os.getenv('DATABASE_URL', 'postgresql://localhost/imageprocessing')
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_POOL_SIZE = 10
    SQLALCHEMY_MAX_OVERFLOW = 20
    
    # Upload settings
    UPLOAD_FOLDER = os.getenv('UPLOAD_FOLDER', 'uploads')
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024  # 16MB
    ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'bmp', 'tiff'}
    
    # ML/AI settings
    MODEL_PATH = os.getenv('MODEL_PATH', 'models')
    BATCH_SIZE = int(os.getenv('BATCH_SIZE', '32'))
    
    # Big Data settings
    SPARK_MASTER = os.getenv('SPARK_MASTER', 'local[*]')
    DASK_SCHEDULER = os.getenv('DASK_SCHEDULER', 'threads')
    
    # API settings
    API_RATE_LIMIT = os.getenv('API_RATE_LIMIT', '100 per hour')
    API_TIMEOUT = int(os.getenv('API_TIMEOUT', '300'))  # 5 minutes
    
    # Caching
    CACHE_TYPE = 'simple'
    CACHE_DEFAULT_TIMEOUT = 300


class DevelopmentConfig(Config):
    """Development configuration"""
    DEBUG = True
    TESTING = False


class ProductionConfig(Config):
    """Production configuration"""
    DEBUG = False
    TESTING = False
    
    # Enhanced security in production
    SESSION_COOKIE_SECURE = True
    SESSION_COOKIE_HTTPONLY = True
    SESSION_COOKIE_SAMESITE = 'Lax'


class TestingConfig(Config):
    """Testing configuration"""
    TESTING = True
    DEBUG = True
    SQLALCHEMY_DATABASE_URI = 'postgresql://localhost/imageprocessing_test'


# Configuration dictionary
config = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'testing': TestingConfig,
    'default': DevelopmentConfig
}
