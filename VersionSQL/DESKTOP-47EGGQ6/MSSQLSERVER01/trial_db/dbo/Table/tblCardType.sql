/****** Object:  Table [dbo].[tblCardType]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblCardType](
	[CardType_ID] [int] IDENTITY(1,1) NOT NULL,
	[CardType_Name] [nvarchar](50) NULL,
	[CardType_Rate] [decimal](38, 10) NOT NULL,
	[CardType_Status] [smallint] NOT NULL,
	[CardType_CreatedBy] [nvarchar](50) NULL,
	[CardType_CreatedDate] [datetime] NULL,
	[CardType_UpdatedBy] [nvarchar](50) NULL,
	[CardType_UpdatedDate] [datetime] NULL,
	[CardType_Sort] [int] NOT NULL,
	[CardType_TierCleanPeriodMth] [int] NOT NULL,
	[CardType_TierCleanFromDate] [datetime] NULL,
	[CardType_TierMinMaintainLevel] [int] NOT NULL,
	[CardType_MaintainLevelPeriodMth] [int] NOT NULL,
 CONSTRAINT [PK_tblCardType] PRIMARY KEY CLUSTERED 
(
	[CardType_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[tblCardType] ADD  CONSTRAINT [DF_tblCardType_CardType_Rate]  DEFAULT ((0)) FOR [CardType_Rate]
ALTER TABLE [dbo].[tblCardType] ADD  CONSTRAINT [DF_tblCardType_CardType_Status]  DEFAULT ((0)) FOR [CardType_Status]
ALTER TABLE [dbo].[tblCardType] ADD  CONSTRAINT [DF_tblCardType_PlayerLevel_Sort]  DEFAULT ((0)) FOR [CardType_Sort]
ALTER TABLE [dbo].[tblCardType] ADD  CONSTRAINT [DF_tblCardType_PlayerLevel_TierCleanPeriodMth]  DEFAULT ((0)) FOR [CardType_TierCleanPeriodMth]
ALTER TABLE [dbo].[tblCardType] ADD  CONSTRAINT [DF_tblCardType_PlayerLevel_TierMinMaintainLevel]  DEFAULT ((0)) FOR [CardType_TierMinMaintainLevel]
ALTER TABLE [dbo].[tblCardType] ADD  CONSTRAINT [DF_tblCardType_PlayerLevel_MaintainLevelPeriodMth]  DEFAULT ((0)) FOR [CardType_MaintainLevelPeriodMth]
