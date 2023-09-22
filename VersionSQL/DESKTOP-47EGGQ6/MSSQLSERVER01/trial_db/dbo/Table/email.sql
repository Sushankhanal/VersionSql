/****** Object:  Table [dbo].[email]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[email](
	[email_id] [bigint] IDENTITY(1,1) NOT NULL,
	[email_user_id] [bigint] NULL,
	[email_email] [nvarchar](50) NULL,
	[email_createdon] [datetime] NULL,
	[email_deleted] [int] NOT NULL,
	[email_status] [int] NOT NULL,
	[email_verification_code] [nvarchar](50) NULL,
 CONSTRAINT [PK_email] PRIMARY KEY CLUSTERED 
(
	[email_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[email] ADD  CONSTRAINT [DF_email_email_status]  DEFAULT ((0)) FOR [email_deleted]
ALTER TABLE [dbo].[email] ADD  CONSTRAINT [DF_email_email_status_1]  DEFAULT ((0)) FOR [email_status]
