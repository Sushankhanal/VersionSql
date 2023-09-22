/****** Object:  Table [dbo].[session]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[session](
	[session_id] [bigint] IDENTITY(1,1) NOT NULL,
	[session_key] [nvarchar](1024) NULL,
	[session_user_id] [bigint] NULL,
	[session_createdon] [datetime] NULL,
	[session_expired] [int] NOT NULL,
	[session_card_serial_no] [nvarchar](50) NULL,
	[session_expire_datetime] [datetime] NULL,
	[session_imei] [nvarchar](50) NULL,
	[session_ip] [nvarchar](50) NULL,
	[session_app_version] [nvarchar](50) NULL,
	[session_setting_version] [nvarchar](50) NULL,
 CONSTRAINT [PK_session] PRIMARY KEY CLUSTERED 
(
	[session_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[session] ADD  CONSTRAINT [DF_session_session_expired]  DEFAULT ((0)) FOR [session_expired]
