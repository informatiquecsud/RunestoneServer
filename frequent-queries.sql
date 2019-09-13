-- déterminer tous les étudiants d'une classe 
SELECT auth_user.*, auth_group.role
FROM auth_user
LEFT JOIN auth_membership ON auth_membership.user_id = auth_user.id
LEFT JOIN auth_group ON auth_group.id = auth_membership.group_id
WHERE role = '1GY5'and auth_user.id NOT IN (
        SELECT auth_user.id
        FROM auth_user
        LEFT JOIN auth_membership ON auth_membership.user_id = auth_user.id
        LEFT JOIN auth_group ON auth_group.id = auth_membership.group_id
        WHERE role = 'instructor'
)
ORDER BY username;

-- enregistrer tous les étudiants d'une classe à un cours
UPDATE user_courses 
SET course_id = (
        SELECT courses.id 
        FROM courses
        WHERE course_name = 'oxocard101'
) 
WHERE user_id IN (
        SELECT auth_user.id
        FROM auth_user
        LEFT JOIN auth_membership ON auth_membership.user_id = auth_user.id
        LEFT JOIN auth_group ON auth_group.id = auth_membership.group_id
        WHERE role = '1GY7'and auth_user.id NOT IN (
                SELECT auth_user.id
                FROM auth_user
                LEFT JOIN auth_membership ON auth_membership.user_id = auth_user.id
                LEFT JOIN auth_group ON auth_group.id = auth_membership.group_id
                WHERE role = 'instructor'
        )
)

-- passe tous les étudiants d'une classe dans un autre cours
UPDATE auth_user 
SET course_id = (
        SELECT courses.id 
        FROM courses
        WHERE course_name = 'oxocard101'
), course_name = 'oxocard101'
WHERE id IN (
        SELECT auth_user.id
        FROM auth_user
        LEFT JOIN auth_membership ON auth_membership.user_id = auth_user.id
        LEFT JOIN auth_group ON auth_group.id = auth_membership.group_id
        WHERE role = '1GY7' and auth_user.id NOT IN (
                SELECT auth_user.id
                FROM auth_user
                LEFT JOIN auth_membership ON auth_membership.user_id = auth_user.id
                LEFT JOIN auth_group ON auth_group.id = auth_membership.group_id
                WHERE role = 'instructor'
        )
        ORDER BY username
)