/****** Object:  Table [dbo].[tblSetting]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblSetting](
	[tblSetting_last_running_date] [date] NULL,
	[tblSetting_clsc_sync_user_detail] [int] NOT NULL
) ON [PRIMARY]

ALTER TABLE [dbo].[tblSetting] ADD  CONSTRAINT [DF_tblSetting_tblSetting_clsc_sync_user_detail]  DEFAULT ((1)) FOR [tblSetting_clsc_sync_user_detail]
