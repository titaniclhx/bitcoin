from . import auth
from .forms import LoginForm, RegistrationForm, ChangePasswordForm
from ..models import User
from .. import db
from flask_login import login_user, logout_user, login_required, current_user
from flask import render_template, redirect, url_for, flash, request


@auth.route('/login', methods=['POST', 'GET'])
def login():
    form = LoginForm()
    if form.validate_on_submit():
        user = User.query.filter_by(mobile=form.mobile.data).first()
        if user is not None and user.verif_password(form.password.data):
            login_user(user, form.remember_me.data)
            return redirect(request.args.get('next') or url_for('main.index'))
        flash('用户名或者密码不对!')
    form.password.data = ''
    return render_template('auth/login.html', form=form)


@auth.route('/logout')
@login_required
def logout():
    logout_user()
    flash('你已退出！')
    return redirect(url_for('main.index'))


@auth.route('/register', methods=['GET', 'POST'])
def register():
    form = RegistrationForm()
    if form.validate_on_submit():
        user = User(mobile=form.mobile.data,
                    name=form.name.data,
                    identity=form.identity.data,
                    password=form.password.data)
        db.session.add(user)
        db.session.commit()
        flash('注册成功！')
        return redirect(url_for('auth.login'))
    return render_template('auth/register.html', form=form)


@auth.route('/change_password', methods=['GET', 'POST'])
@login_required
def change_password():
    form = ChangePasswordForm()
    if form.validate_on_submit():
        if current_user.verif_password(form.old_password.data):
            current_user.password = form.password1.data
            db.session.add(current_user)
            db.session.commit()
            logout_user()
            flash('密码修改成功，请重新登录！')
            return redirect(url_for('auth.login'))
        else:
            flash('原密码不对!')
    return render_template('auth/change_password.html', form=form)
