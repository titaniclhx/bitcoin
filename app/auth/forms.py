from flask_wtf import Form
from wtforms import StringField, PasswordField, BooleanField, SubmitField, IntegerField
from wtforms.validators import Required, Length


class LoginForm(Form):
    mobile = IntegerField('手机号', validators=[Required, Length(11)])
    password = PasswordField('密码', validators=[Required])
    remember_me = BooleanField('keep me logged in')
    submit = SubmitField('登录')






