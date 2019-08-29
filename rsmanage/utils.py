from random import choice
import click


def create_class(eng, class_name, start_date, end_date):
    try:
        sql_create_class = '''
        INSERT INTO auth_group (role) VALUES ('{role}') RETURNING id
        '''.format(
            role=class_name
        )

        role_id = eng.execute(sql_create_class).first()[0]
        print("created new role (class) with id", role_id)

        if role_id:
            sql_create_auth_group_validity = '''
            INSERT INTO auth_group_validity (start_date, end_date, auth_group_id) VALUES (
                '{}', '{}', {}
            )
            '''.format(
                start_date,
                end_date or '2099-12-31',
                role_id
            )
            res = eng.execute(sql_create_auth_group_validity)
        else:
            raise Exception("Unable to create class with name '{}'".format(class_name))
            
        return role_id

    except Exception as e:
        click.echo(str(e), err=True)


def generate_random_password(length=8, chars='0123456789'):
    return ''.join([choice(chars) for _ in range(length)])