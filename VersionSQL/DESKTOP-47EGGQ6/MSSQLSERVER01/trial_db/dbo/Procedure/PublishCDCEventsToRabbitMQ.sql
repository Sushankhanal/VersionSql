/****** Object:  Procedure [dbo].[PublishCDCEventsToRabbitMQ]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[PublishCDCEventsToRabbitMQ]
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

  -- Retrieve CDC events from the table
  DECLARE @transaction_id BINARY(10),
          @operation_type INT,
          @sync_id INT,
          @entity_name VARCHAR(50),
          @entity_id INT,
          @operation VARCHAR(10),
          @sync_status BIT;

  DECLARE cdc_cursor CURSOR FOR
    SELECT [__$start_lsn], [__$operation], SyncId, EntityName, EntityId, Operation, SyncStatus
    FROM [cdc].[dbo_CloudSync_CT];

  OPEN cdc_cursor;

  FETCH NEXT FROM cdc_cursor INTO @transaction_id, @operation_type, @sync_id, @entity_name, @entity_id, @operation, @sync_status;

  WHILE @@FETCH_STATUS = 0
  BEGIN
    -- Format the CDC event data as needed (e.g., JSON, XML)
    DECLARE @formatted_data NVARCHAR(MAX) = N'{
      "TransactionId": "' + CONVERT(NVARCHAR(MAX), @transaction_id, 2) + N'",
      "OperationType": ' + CONVERT(NVARCHAR(MAX), @operation_type) + N',
      "SyncId": ' + CONVERT(NVARCHAR(MAX), @sync_id) + N',
      "EntityName": "' + @entity_name + N'",
      "EntityId": ' + CONVERT(NVARCHAR(MAX), @entity_id) + N',
      "Operation": "' + @operation + N'",
      "SyncStatus": ' + CONVERT(NVARCHAR(MAX), @sync_status) + N'
    }';

    -- Publish the CDC event to RabbitMQ
    EXEC sys.sp_OAMethod @mq_channel, 'BasicPublish', NULL, @mq_exchange, @mq_binding_key, 0, 0, @formatted_data;

    FETCH NEXT FROM cdc_cursor INTO @transaction_id, @operation_type, @sync_id, @entity_name, @entity_id, @operation, @sync_status;
  END

  CLOSE cdc_cursor;
  DEALLOCATE cdc_cursor;

  -- Clean up RabbitMQ resources
  EXEC sys.sp_OADestroy @mq_channel;
  EXEC sys.sp_OADestroy @mq_connection;
END
