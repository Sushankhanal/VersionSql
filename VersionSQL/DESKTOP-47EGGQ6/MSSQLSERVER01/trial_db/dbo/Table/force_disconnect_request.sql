/****** Object:  Table [dbo].[force_disconnect_request]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[force_disconnect_request](
	[force_disconnect_request_id] [bigint] IDENTITY(1,1) NOT NULL,
	[force_disconnect_request_datetime] [datetime] NULL,
	[force_disconnect_request_by] [bigint] NULL,
	[force_disconnect_request_machine_id] [bigint] NULL,
	[force_disconnect_request_player_serial_no] [nvarchar](50) NULL,
	[force_disconnect_request_timing] [int] NULL,
	[force_disconnect_request_game_session_id] [bigint] NULL,
 CONSTRAINT [PK_force_disconnect_request] PRIMARY KEY CLUSTERED 
(
	[force_disconnect_request_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
