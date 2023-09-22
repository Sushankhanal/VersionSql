/****** Object:  Table [dbo].[tblCampaign_Point]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblCampaign_Point](
	[Campaign_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Campaign_Type] [nvarchar](50) NULL,
	[Campaign_Type_ID] [int] NOT NULL,
	[Campaign_Name] [nvarchar](50) NULL,
	[Campaign_StartDate] [datetime] NULL,
	[Campaign_EndDate] [datetime] NULL,
	[Campaign_Rate] [money] NOT NULL,
	[Campaign_Remarks] [nvarchar](500) NULL,
	[Campaign_Status] [smallint] NOT NULL,
	[Campaign_CreatedBy] [nvarchar](50) NULL,
	[Campaign_CreatedDate] [datetime] NULL,
	[Campaign_UpdatedBy] [nvarchar](50) NULL,
	[Campaign_UpdatedDate] [datetime] NULL,
	[Campaign_MachineID] [bigint] NOT NULL,
	[Campaign_MachineName] [nvarchar](50) NULL,
	[Campaign_MinBet] [money] NOT NULL,
	[Campaign_MaxBet] [money] NOT NULL,
	[Campaign_MinWin] [money] NOT NULL,
	[Campaign_MaxWin] [money] NOT NULL,
	[Campaign_Day] [nvarchar](50) NOT NULL,
	[Campaign_CardType] [nvarchar](500) NOT NULL,
	[Campaign_PlayerLevel] [nvarchar](500) NOT NULL,
	[Campaign_StartTime] [time](7) NULL,
	[Campaign_EndTime] [time](7) NULL,
 CONSTRAINT [PK_tblCampaign_Point] PRIMARY KEY CLUSTERED 
(
	[Campaign_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[tblCampaign_Point] ADD  CONSTRAINT [DF_tblCampaign_Point_Campaign_Type_ID]  DEFAULT ((0)) FOR [Campaign_Type_ID]
ALTER TABLE [dbo].[tblCampaign_Point] ADD  CONSTRAINT [DF_tblCampaign_Point_Campaign_Rate]  DEFAULT ((0)) FOR [Campaign_Rate]
ALTER TABLE [dbo].[tblCampaign_Point] ADD  CONSTRAINT [DF_tblCampaign_Point_Campaign_Status]  DEFAULT ((0)) FOR [Campaign_Status]
ALTER TABLE [dbo].[tblCampaign_Point] ADD  CONSTRAINT [DF_tblCampaign_Point_Campaign_MachineID]  DEFAULT ((0)) FOR [Campaign_MachineID]
ALTER TABLE [dbo].[tblCampaign_Point] ADD  CONSTRAINT [DF_tblCampaign_Point_Campaign_MinBet]  DEFAULT ((0)) FOR [Campaign_MinBet]
ALTER TABLE [dbo].[tblCampaign_Point] ADD  CONSTRAINT [DF_tblCampaign_Point_Campaign_MaxBet]  DEFAULT ((0)) FOR [Campaign_MaxBet]
ALTER TABLE [dbo].[tblCampaign_Point] ADD  CONSTRAINT [DF_tblCampaign_Point_Campaign_MinWin]  DEFAULT ((0)) FOR [Campaign_MinWin]
ALTER TABLE [dbo].[tblCampaign_Point] ADD  CONSTRAINT [DF_tblCampaign_Point_Campaign_MaxWin]  DEFAULT ((0)) FOR [Campaign_MaxWin]
ALTER TABLE [dbo].[tblCampaign_Point] ADD  CONSTRAINT [DF_tblCampaign_Point_Campaign_Day]  DEFAULT ('') FOR [Campaign_Day]
ALTER TABLE [dbo].[tblCampaign_Point] ADD  CONSTRAINT [DF_tblCampaign_Point_Campaign_CardType]  DEFAULT ('') FOR [Campaign_CardType]
ALTER TABLE [dbo].[tblCampaign_Point] ADD  CONSTRAINT [DF_tblCampaign_Point_Campaign_PlayerLevel]  DEFAULT ('') FOR [Campaign_PlayerLevel]
