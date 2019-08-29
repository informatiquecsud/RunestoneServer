from random import choice

def create_class(eng, class_name, start_date, end_date):
    try:
        sql_create_class = '''
        INSERT INTO auth_group (role) VALUES ({role}) RETURNING id
        '''.format(
            role=class_name
        )

        role_id = eng.execute(sql_create_class)

        if role_id:
            sql_create_ = '''
            INSERT INTO auth_group_validity (start_date, end_date, auth_group_id) VALUES (
                {}, {}, {}
            )
            '''.format(
                start_date,
                end_date,
                role_id
            )
        else:
            raise Exception("Unable to create class with name '{}'".format(class_name))
            
        return role_id

    except Exception as e:
        click.echo(str(e), err=True)


def generate_random_password(length=8, chars='0123456789'):
    return ''.join([choice(chars) for _ in range(length)])