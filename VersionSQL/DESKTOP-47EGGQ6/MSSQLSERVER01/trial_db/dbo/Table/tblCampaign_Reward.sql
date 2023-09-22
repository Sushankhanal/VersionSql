/****** Object:  Table [dbo].[tblCampaign_Reward]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblCampaign_Reward](
	[Reward_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Reward_Type_ID] [bigint] NULL,
	[Reward_Name] [nvarchar](50) NULL,
	[Reward_StartDate] [datetime] NULL,
	[Reward_EndDate] [datetime] NULL,
	[Reward_Points] [money] NOT NULL,
	[Reward_Credit] [money] NOT NULL,
	[Reward_CreditCashable] [money] NOT NULL,
	[Reward_CreditNonCashable] [money] NOT NULL,
	[Reward_MaxQty] [int] NOT NULL,
	[Reward_ExpiryDay] [int] NOT NULL,
	[Reward_Status] [smallint] NOT NULL,
	[Reward_Remarks] [nvarchar](50) NULL,
	[Reward_CardType] [bigint] NOT NULL,
	[Reward_CreatedBy] [nvarchar](50) NULL,
	[Reward_CreatedDate] [datetime] NULL,
	[Reward_UpdatedBy] [nvarchar](50) NULL,
	[Reward_UpdatedDate] [datetime] NULL,
 CONSTRAINT [PK_tblRewardCampaign] PRIMARY KEY CLUSTERED 
(
	[Reward_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[tblCampaign_Reward] ADD  CONSTRAINT [DF_tblRewardCampaign_Reward_Points]  DEFAULT ((0)) FOR [Reward_Points]
ALTER TABLE [dbo].[tblCampaign_Reward] ADD  CONSTRAINT [DF_tblRewardCampaign_Reward_Credit]  DEFAULT ((0)) FOR [Reward_Credit]
ALTER TABLE [dbo].[tblCampaign_Reward] ADD  CONSTRAINT [DF_tblRewardCampaign_Reward_CreditCashable]  DEFAULT ((0)) FOR [Reward_CreditCashable]
ALTER TABLE [dbo].[tblCampaign_Reward] ADD  CONSTRAINT [DF_tblRewardCampaign_Reward_CreditNonCashable]  DEFAULT ((0)) FOR [Reward_CreditNonCashable]
ALTER TABLE [dbo].[tblCampaign_Reward] ADD  CONSTRAINT [DF_tblRewardCampaign_Reward_MaxQty]  DEFAULT ((0)) FOR [Reward_MaxQty]
ALTER TABLE [dbo].[tblCampaign_Reward] ADD  CONSTRAINT [DF_tblRewardCampaign_Reward_ExpiryDay]  DEFAULT ((0)) FOR [Reward_ExpiryDay]
ALTER TABLE [dbo].[tblCampaign_Reward] ADD  CONSTRAINT [DF_tblRewardCampaign_Reward_Status]  DEFAULT ((0)) FOR [Reward_Status]
ALTER TABLE [dbo].[tblCampaign_Reward] ADD  CONSTRAINT [DF_tblRewardCampaign_Reward_CardType]  DEFAULT ((0)) FOR [Reward_CardType]
