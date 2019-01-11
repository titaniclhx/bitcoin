from . import auth
from .forms import LoginForm
from ..models import User
from flask_login import login_user, logout_user, login_required
from flask import render_template, redirect, url_for, flash, request


@auth.route('/login', methods=['POST', 'GET'])
def login():
    form = LoginForm()
    if form.validate_on_submit():
        user = User.query.filter_by(mobile=form.mobile.data).first()
        if user is not None and user.verif_password(form.password.data):
            login_user(user, form.remember_me.data)
            print('55555555555555')
            return redirect(request.args.get('next') or url_for('main.index'))
        flash('invalid username or password!')
    return render_template('auth/login.html', form=form)


@auth.route('/logout')
@login_required
def logout():
    logout_user()
    flash('你已退出！')
    return redirect(url_for('main.index'))



