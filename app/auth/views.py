from . import auth
from .forms import LoginForm
from ..models import User
from flask_login import loger_user
from flask import render_template, redirect, url_for, flash


@auth.route('/login', methods=['POST', 'GET'])
def login():
    form = LoginForm()
    if form.validate_on_submit():
        user = User.query.filter_by(mobile=form.mobile.data).first()
        if user is not None and user.verif_password(form.password.data):
            loger_user(user, form.remember_me.data)
            return redirect(request.args.get('next') or url_for('main.index'))
        flash('invalid username or password!')
    return render_template('auth/login.html', form=form)

