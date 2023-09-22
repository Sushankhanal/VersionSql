/****** Object:  Table [dbo].[tblCampaign_Machine]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblCampaign_Machine](
	[CampaignM_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CampaignM_Campaign_ID] [bigint] NULL,
	[CampaignM_Machine_ID] [bigint] NULL,
	[CampaignM_MachineName] [nvarchar](50) NULL,
 CONSTRAINT [PK_tblCampaign_Machine] PRIMARY KEY CLUSTERED 
(
	[CampaignM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
