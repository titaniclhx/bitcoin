# from flask_wtf import Form
from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, BooleanField, SubmitField, IntegerField, ValidationError
from wtforms.validators import DataRequired, Length, Regexp, EqualTo
from ..models import User


class LoginForm(FlaskForm):
    mobile = IntegerField('手机号', validators=[DataRequired()])
    password = PasswordField('密码', validators=[DataRequired()])
    remember_me = BooleanField('keep me logged in')
    submit = SubmitField('登录')


class RegistrationForm(FlaskForm):
    mobile = IntegerField('手机号', validators=[DataRequired()])
    name = StringField('姓名', validators=[DataRequired()])
    identity = StringField('身份证号', validators=[DataRequired()])
    password = PasswordField('密码', validators=[DataRequired()])
    password2 = PasswordField('密码确认', validators=[DataRequired(), EqualTo('password', message='两次输入密码不一样!')])
    submit = SubmitField('提交')

    def validate_mobile(self, field):
        if User.query.filter_by(mobile=field.data).first():
            raise ValidationError('这个手机号已经注册过!')


class ChangePasswordForm(FlaskForm):
    old_password = PasswordField('旧密码', validators=[DataRequired()])
    password1 = PasswordField('新密码', validators=[DataRequired()])
    password2 = PasswordField('新密码确认', validators=[DataRequired(), EqualTo('password1', message='两次输入密码不一样!')])
    submit = SubmitField('提交')



