import os
basedir = os.path.abspath(os.path.dirname(__file__))


class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'i use flask'
    SQLALCHEMY_COMMIT_ON_TEARDOWN = True

    @staticmethod
    def init_app(app):
        pass


class DevelopmentConfig(Config):
    DEBUG = True
    # SQLALCHEMY_DATABASE_URI = os.environ.get('DEV_DATABASE_URL') or 'mysql://lianghuaxiong:lianghuaxiong@localhost/bitcoin'
    SQLALCHEMY_DATABASE_URI = os.environ.get('DEV_DATABASE_URL') or 'mysql+pymysql://lianghuaxiong:lianghuaxiong@localhost/bitcoin?charset=utf8'


class TestingConfig(Config):
    TESTING = True
    # SQLALCHEMY_DATABASE_URI = os.environ.get('DEV_DATABASE_URL') or 'mysql://lianghuaxiong:lianghuaxiong@localhost/bitcoin'
    SQLALCHEMY_DATABASE_URI = os.environ.get('DEV_DATABASE_URL') or 'mysql+pymysql://lianghuaxiong:lianghuaxiong@localhost/bitcoin?charset=utf8'


class ProductionConfig(Config):
    # SQLALCHEMY_DATABASE_URI = os.environ.get('DEV_DATABASE_URL') or 'mysql://lianghuaxiong:lianghuaxiong@localhost/bitcoin'
    SQLALCHEMY_DATABASE_URI = os.environ.get('DEV_DATABASE_URL') or 'mysql+pymysql://lianghuaxiong:lianghuaxiong@localhost/bitcoin?charset=utf8'


config = {'development': DevelopmentConfig, 'testing': DevelopmentConfig, 'production': DevelopmentConfig, 'default': DevelopmentConfig}

