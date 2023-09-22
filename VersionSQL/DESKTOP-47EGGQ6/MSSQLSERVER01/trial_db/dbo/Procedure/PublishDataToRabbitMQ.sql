/****** Object:  Procedure [dbo].[PublishDataToRabbitMQ]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[PublishDataToRabbitMQ]
AS
BEGIN
  SET NOCOUNT ON;

  -- Declare variables for RabbitMQ connection details
  DECLARE @mq_server NVARCHAR(100) = 'localhost',
          @mq_port INT = 5672, -- Default RabbitMQ port
          @mq_username NVARCHAR(100) = 'guest',
          @mq_password NVARCHAR(100) = 'guest',
          @mq_exchange NVARCHAR(100) = 'SusanExchange',
          @mq_queue NVARCHAR(100) = 'Susan_queue', -- Specify the name of your queue
          @mq_binding_key NVARCHAR(100) = 'abcd'; -- Specify the binding key

  -- Connect to RabbitMQ server
  DECLARE @mq_connection NVARCHAR(100),
          @mq_channel NVARCHAR(100);

  EXEC sys.sp_OACreate 'RabbitMQ.Client.ConnectionFactory', @mq_connection OUT;
  EXEC sys.sp_OASetProperty @mq_connection, 'HostName', @mq_server;
  EXEC sys.sp_OASetProperty @mq_connection, 'Port', @mq_port;
  EXEC sys.sp_OASetProperty @mq_connection, 'UserName', @mq_username;
  EXEC sys.sp_OASetProperty @mq_connection, 'Password', @mq_password;
  EXEC sys.sp_OAMethod @mq_connection, 'CreateConnection', NULL, @mq_channel OUT;

  -- Open a channel to RabbitMQ exchange
  EXEC sys.sp_OAMethod @mq_channel, 'ExchangeDeclare', NULL, @mq_exchange, 'direct', 1, 0;

  -- Declare the queue
  EXEC sys.sp_OAMethod @mq_channel, 'QueueDeclare', NULL, @mq_queue, 1, 0, 0, 0, NULL;

  -- Bind the queue to the exchange with the specified binding key
  EXEC sys.sp_OAMethod @mq_channel, 'QueueBind', NULL, @mq_queue, @mq_exchange, @mq_binding_key;

  -- Retrieve data from the table
  DECLARE @sync_id INT,
          @entity_name VARCHAR(50),
          @entity_id INT,
          @operation VARCHAR(10),
          @sync_status BIT;

  DECLARE data_cursor CURSOR FOR
    SELECT SyncId, EntityName, EntityId, Operation, SyncStatus
    FROM [dbo].[CloudSync];

  OPEN data_cursor;

  FETCH NEXT FROM data_cursor INTO @sync_id, @entity_name, @entity_id, @operation, @sync_status;

  WHILE @@FETCH_STATUS = 0
  BEGIN
    -- Format the data as needed (e.g., JSON, XML)
    DECLARE @formatted_data NVARCHAR(MAX) = N'{
      "SyncId": ' + CONVERT(NVARCHAR(MAX), @sync_id) + N',
      "EntityName": "' + @entity_name + N'",
      "EntityId": ' + CONVERT(NVARCHAR(MAX), @entity_id) + N',
      "Operation": "' + @operation + N'",
      "SyncStatus": ' + CONVERT(NVARCHAR(MAX), @sync_status) + N'
    }';

    -- Publish the data to RabbitMQ
    EXEC sys.sp_OAMethod @mq_channel, 'BasicPublish', NULL, @mq_exchange, @mq_binding_key, 0, 0, @formatted_data;

    FETCH NEXT FROM data_cursor INTO @sync_id, @entity_name, @entity_id, @operation, @sync_status;
  END

  CLOSE data_cursor;
  DEALLOCATE data_cursor;

  -- Clean up RabbitMQ resources
  EXEC sys.sp_OADestroy @mq_channel;
  EXEC sys.sp_OADestroy @mq_connection;
END
