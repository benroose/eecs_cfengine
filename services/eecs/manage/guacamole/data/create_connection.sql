-- SQL import file generated by CFEngine using mustache template
-- generate connection entry within guacamole_db using CFE vars from manage/guacamole/database.cf

{{#classes.parent_group_not_defined}}
-- START GLOBAL PARAMETERS FOR CONNECTION WITH NO PARENT GROUP DEFINED
INSERT INTO guacamole_connection (connection_name, protocol, max_connections, max_connections_per_user)
VALUES ('{{{vars.guac_create_connection.conname}}}',
        '{{{vars.guac_create_connection.protocol}}}', -- must be ssh or rdp
  {{#classes.ssh_connection}}
        '{{{vars.guac_database_vars.max_ssh_connections_per_connection}}}',
        '{{{vars.guac_database_vars.max_ssh_connections_per_user_per_connection}}}'
  {{/classes.ssh_connection}}
  {{#classes.rdp_connection}}
        '{{{vars.guac_database_vars.max_rdp_connections_per_connection}}}',
        '{{{vars.guac_database_vars.max_rdp_connections_per_user_per_connection}}}'
  {{/classes.rdp_connection}}
       );
{{/classes.parent_group_not_defined}}

{{#classes.parent_group_defined}}
-- START GLOBAL PARAMETERS FOR CONNECTION WITH PARENT GROUP DEFINED
-- connection_weight and failover_only are not implemented, but could be used in future for specific load balanced connections
INSERT INTO guacamole_connection (connection_name, protocol, parent_id, max_connections, max_connections_per_user)
-- INSERT INTO guacamole_connection (connection_name, protocol, parent_id, max_connections, max_connections_per_user, connection_weight, failover_only)
VALUES ('{{{vars.guac_create_connection.conname}}}',
        '{{{vars.guac_create_connection.protocol}}}', -- must be ssh or rdp
        '{{{vars.guac_create_connection.mysql_parent_id_result}}}', -- id gained from mysql query on parent_group
  {{#classes.ssh_connection}}
        '{{{vars.guac_database_vars.max_ssh_connections_per_connection}}}',
        '{{{vars.guac_database_vars.max_ssh_connections_per_user_per_connection}}}'
        -- '{{{vars.guac_database_vars.ssh_connection_weight}}}',
        -- '{{{vars.guac_database_vars.ssh_failover_only}}}',
  {{/classes.ssh_connection}}
  {{#classes.rdp_connection}}
        '{{{vars.guac_database_vars.max_rdp_connections_per_connection}}}',
        '{{{vars.guac_database_vars.max_rdp_connections_per_user_per_connection}}}'
        -- '{{{vars.guac_database_vars.rdp_connection_weight}}}',
        -- '{{{vars.guac_database_vars.rdp_failover_only}}}',
  {{/classes.rdp_connection}}
       );
{{/classes.parent_group_defined}}

{{#classes.ssh_connection}}
-- START SSH PARAMETERS - generate parameters for ssh connection as defined above
INSERT INTO guacamole_connection_parameter
SELECT connection_id, parameter_name, parameter_value
FROM (
          SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'hostname' AS parameter_name, '{{{vars.guac_create_connection.hostname}}}' AS parameter_value
    UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'username' AS parameter_name, '{{{vars.guac_database_vars.username}}}' AS parameter_value
    UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'password' AS parameter_name, '{{{vars.guac_database_vars.password}}}' AS parameter_value
    UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'enable-sftp' AS parameter_name, '{{{vars.guac_database_vars.enable_sftp}}}' AS parameter_value
    UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'sftp-root-directory' AS parameter_name, '{{{vars.guac_database_vars.sftp_root_directory}}}' AS parameter_value
    UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'server-alive-interval' AS parameter_name, '{{{vars.guac_database_vars.ssh_server_alive_interval}}}' AS parameter_value
    UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'port' AS parameter_name, '{{{vars.guac_database_vars.ssh_port}}}' AS parameter_value
    UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'color-scheme' AS parameter_name, '{{{vars.guac_database_vars.ssh_color_scheme}}}' AS parameter_value
    UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'font-name' AS parameter_name, '{{{vars.guac_database_vars.ssh_font_name}}}' AS parameter_value
    UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'font-size' AS parameter_name, '{{{vars.guac_database_vars.ssh_font_size}}}' AS parameter_value
    -- UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'private-key' AS parameter_name, '{{{vars.guac_database_vars.ssh_private_key}}}' AS parameter_value
    -- UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'passphrase' AS parameter_name, '{{{vars.guac_database_vars.ssh_passphrase}}}' AS parameter_value
    -- UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'command' AS parameter_name, '{{{vars.guac_database_vars.ssh_command}}}' AS parameter_value
) parameters
JOIN guacamole_connection ON parameters.connection_name = guacamole_connection.connection_name;
-- END SSH PARAMETERS
{{/classes.ssh_connection}}

{{#classes.rdp_connection}}
-- START RDP PARAMETERS - generate parameters for rdp connection as defined above
INSERT INTO guacamole_connection_parameter
SELECT connection_id, parameter_name, parameter_value
FROM (
          SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'hostname' AS parameter_name, '{{{vars.guac_create_connection.hostname}}}' AS parameter_value
    UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'username' AS parameter_name, '{{{vars.guac_database_vars.username}}}' AS parameter_value
    UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'password' AS parameter_name, '{{{vars.guac_database_vars.password}}}' AS parameter_value
    UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'enable-sftp' AS parameter_name, '{{{vars.guac_database_vars.enable_sftp}}}' AS parameter_value
    UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'sftp-server-alive-interval' AS parameter_name, '{{{vars.guac_database_vars.sftp_server_alive_interval}}}' AS parameter_value
    UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'sftp-root-directory' AS parameter_name, '{{{vars.guac_database_vars.sftp_root_directory}}}' AS parameter_value
    UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'port' AS parameter_name, '{{{vars.guac_database_vars.rdp_port}}}' AS parameter_value
    UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'security' AS parameter_name, '{{{vars.guac_database_vars.rdp_security}}}' AS parameter_value
    -- UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'color-depth' AS parameter_name, '{{{vars.guac_database_vars.rdp_color_depth}}}' AS parameter_value
    -- UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'width' AS parameter_name, '{{{vars.guac_database_vars.rdp_width}}}' AS parameter_value
    -- UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'height' AS parameter_name, '{{{vars.guac_database_vars.rdp_height}}}' AS parameter_value
    -- UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'dpi' AS parameter_name, '{{{vars.guac_database_vars.rdp_dpi}}}' AS parameter_value
    UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'resize-method' AS parameter_name, '{{{vars.guac_database_vars.rdp_resize_method}}}' AS parameter_value
    UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'enable-printing' AS parameter_name, '{{{vars.guac_database_vars.rdp_enable_printing}}}' AS parameter_value
    UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'sftp-hostname' AS parameter_name, '{{{vars.guac_create_connection.hostname}}}' AS parameter_value
    UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'sftp-port' AS parameter_name, '{{{vars.guac_database_vars.ssh_port}}}' AS parameter_value
    UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'sftp-username' AS parameter_name, '{{{vars.guac_database_vars.username}}}' AS parameter_value
    UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'sftp-password' AS parameter_name, '{{{vars.guac_database_vars.password}}}' AS parameter_value
    -- UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'sftp-directory' AS parameter_name, '{{{vars.guac_database_vars.rdp_sftp_directory}}}' AS parameter_value
    -- UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'domain' AS parameter_name, '{{{vars.guac_database_vars.rdp_domain}}}' AS parameter_value
    -- UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'sftp-private-key' AS parameter_name, '{{{vars.guac_database_vars.ssh_private_key}}}' AS parameter_value
    -- UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'sftp-passphrase' AS parameter_name, '{{{vars.guac_database_vars.ssh_passphrase}}}' AS parameter_value
    -- UNION SELECT '{{{vars.guac_create_connection.conname}}}' AS connection_name, 'initial-program' AS parameter_name, '{{{vars.guac_database_vars.rdp_command}}}' AS parameter_value
) parameters
JOIN guacamole_connection ON parameters.connection_name = guacamole_connection.connection_name;
-- END RDP PARAMETERS
{{/classes.rdp_connection}}