-- SQL import file generated by CFEngine using mustache template

-- START: add user with system administer permissions within guacamole_db using CFE vars from manage/guacamole/database.cf
INSERT INTO guacamole_system_permission
SELECT user_id, permission
FROM (
         SELECT '{{{vars.guac_add_user_as_admin.username}}}' AS username, 'ADMINISTER' AS permission
) permissions
JOIN guacamole_user ON permissions.username = guacamole_user.username;
-- END
