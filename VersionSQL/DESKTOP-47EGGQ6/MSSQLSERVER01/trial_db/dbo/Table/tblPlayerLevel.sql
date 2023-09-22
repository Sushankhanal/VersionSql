/****** Object:  Table [dbo].[tblPlayerLevel]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblPlayerLevel](
	[PlayerLevel_ID] [int] IDENTITY(1,1) NOT NULL,
	[PlayerLevel_Name] [nvarchar](50) NULL,
	[PlayerLevel_Sort] [int] NOT NULL,
	[PlayerLevel_Rate] [decimal](38, 10) NOT NULL,
	[PlayerLevel_Status] [smallint] NOT NULL,
	[PlayerLevel_CreatedBy] [nvarchar](50) NULL,
	[PlayerLevel_CreatedDate] [datetime] NULL,
	[PlayerLevel_UpdatedBy] [nvarchar](50) NULL,
	[PlayerLevel_UpdatedDate] [datetime] NULL,
	[PlayerLevel_TierCleanPeriodMth] [int] NOT NULL,
	[PlayerLevel_TierCleanFromDate] [datetime] NULL,
	[PlayerLevel_TierMinMaintainLevel] [int] NOT NULL,
	[PlayerLevel_MaintainLevelPeriodMth] [int] NOT NULL,
 CONSTRAINT [PK_tblPlayerLevel] PRIMARY KEY CLUSTERED 
(
	[PlayerLevel_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[tblPlayerLevel] ADD  CONSTRAINT [DF_tblPlayerLevel_PlayerLevel_Sort]  DEFAULT ((0)) FOR [PlayerLevel_Sort]
ALTER TABLE [dbo].[tblPlayerLevel] ADD  CONSTRAINT [DF_tblPlayerLevel_PlayerLevel_Rate]  DEFAULT ((0)) FOR [PlayerLevel_Rate]
ALTER TABLE [dbo].[tblPlayerLevel] ADD  CONSTRAINT [DF_tblPlayerLevel_PlayerLevel_Status]  DEFAULT ((0)) FOR [PlayerLevel_Status]
ALTER TABLE [dbo].[tblPlayerLevel] ADD  CONSTRAINT [DF_tblPlayerLevel_PlayerLevel_TierCleanPeriodMth]  DEFAULT ((0)) FOR [PlayerLevel_TierCleanPeriodMth]
ALTER TABLE [dbo].[tblPlayerLevel] ADD  CONSTRAINT [DF_tblPlayerLevel_PlayerLevel_TierMinMaintainLevel]  DEFAULT ((0)) FOR [PlayerLevel_TierMinMaintainLevel]
ALTER TABLE [dbo].[tblPlayerLevel] ADD  CONSTRAINT [DF_tblPlayerLevel_PlayerLevel_MaintainLevelPeriodMth]  DEFAULT ((0)) FOR [PlayerLevel_MaintainLevelPeriodMth]
