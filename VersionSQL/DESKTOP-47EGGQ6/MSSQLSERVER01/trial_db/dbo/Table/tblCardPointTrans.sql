/****** Object:  Table [dbo].[tblCardPointTrans]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblCardPointTrans](
	[CardPointTrans_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CardPointTrans_Code] [nvarchar](100) NULL,
	[CardPointTrans_SerialNo] [nvarchar](50) NULL,
	[CardPointTrans_Type] [int] NULL,
	[CardPointTrans_Value] [decimal](38, 10) NULL,
	[CardPointTrans_PointValue] [decimal](38, 10) NULL,
	[CardPointTrans_RefCode] [nvarchar](50) NULL,
	[CardPointTrans_Remarks] [nvarchar](max) NULL,
	[CardPointTrans_CreatedBy] [nvarchar](50) NULL,
	[CardPointTrans_CreatedDate] [datetime] NULL,
	[CardPointTrans_CampaignCode] [nvarchar](50) NULL,
	[CardPointTrans_QRCodeText] [nvarchar](max) NULL,
	[CardPointTrans_WalletAmt] [money] NULL,
	[CardPointTrans_Ratio] [money] NULL,
	[CardPointTrans_LocalTransID] [nvarchar](100) NOT NULL,
	[CardPointTrans_BranchID] [int] NOT NULL,
	[CardPointTrans_MachineID] [int] NOT NULL,
	[CardPointTrans_RemarksInfo] [nvarchar](max) NOT NULL,
	[CardPointTrans_MoneyIn] [money] NOT NULL,
	[CardPointTrans_MoneyOut] [money] NOT NULL,
	[CardPointTrans_Turnover] [money] NOT NULL,
	[CardPointTrans_Won] [money] NOT NULL,
	[CardPointTrans_GamePlayed] [money] NOT NULL,
	[CardPointTrans_PointEarned] [money] NOT NULL,
	[CardPointTrans_HappyHourRate] [money] NOT NULL,
	[CardPointTrans_MemberCardTypeRate] [money] NOT NULL,
	[CardPointTrans_MachineRate] [money] NOT NULL,
	[CardPointTrans_PlayerMultiplier] [money] NOT NULL,
	[CardPointTrans_BaseRate] [money] NOT NULL,
	[CardPointTrans_ApprovedBy] [nvarchar](50) NOT NULL,
	[CardPointTrans_ApprovedDate] [datetime] NULL,
	[CardPointTrans_Campaign_ID] [bigint] NOT NULL,
	[CardPointTrans_Timespan] [nvarchar](50) NULL,
	[CardPointTrans_PointType] [smallint] NOT NULL,
	[CardPointTrans_OldCardNumber] [nvarchar](50) NOT NULL,
	[CardPointTrans_SessionId] [bigint] NULL,
	[CardPointTrans_ptmSessionId] [bigint] NULL,
 CONSTRAINT [PK_tblCardPointTrans] PRIMARY KEY CLUSTERED 
(
	[CardPointTrans_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [IX_tblCardPointTrans_Code] UNIQUE NONCLUSTERED 
(
	[CardPointTrans_Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[tblCardPointTrans] ADD  CONSTRAINT [DF_tblCardPointTrans_CardPointTrans_LocalTransID]  DEFAULT ('RESERVED2'+ltrim(rtrim(str(ident_current('POSv3..tblCardPointtrans'))))) FOR [CardPointTrans_LocalTransID]
ALTER TABLE [dbo].[tblCardPointTrans] ADD  CONSTRAINT [DF_tblCardPointTrans_CardPointTrans_BranchID]  DEFAULT ((0)) FOR [CardPointTrans_BranchID]
ALTER TABLE [dbo].[tblCardPointTrans] ADD  CONSTRAINT [DF_tblCardPointTrans_CardPointTrans_MachineID]  DEFAULT ((0)) FOR [CardPointTrans_MachineID]
ALTER TABLE [dbo].[tblCardPointTrans] ADD  CONSTRAINT [DF_tblCardPointTrans_CardTrans_Remarks]  DEFAULT ('') FOR [CardPointTrans_RemarksInfo]
ALTER TABLE [dbo].[tblCardPointTrans] ADD  CONSTRAINT [DF_tblCardPointTrans_CardTrans_MoneyIn]  DEFAULT ((0)) FOR [CardPointTrans_MoneyIn]
ALTER TABLE [dbo].[tblCardPointTrans] ADD  CONSTRAINT [DF_tblCardPointTrans_CardTrans_MoneyOut]  DEFAULT ((0)) FOR [CardPointTrans_MoneyOut]
ALTER TABLE [dbo].[tblCardPointTrans] ADD  CONSTRAINT [DF_tblCardPointTrans_CardTrans_Turnover]  DEFAULT ((0)) FOR [CardPointTrans_Turnover]
ALTER TABLE [dbo].[tblCardPointTrans] ADD  CONSTRAINT [DF_tblCardPointTrans_CardTrans_Won]  DEFAULT ((0)) FOR [CardPointTrans_Won]
ALTER TABLE [dbo].[tblCardPointTrans] ADD  CONSTRAINT [DF_tblCardPointTrans_CardTrans_GamePlayed]  DEFAULT ((0)) FOR [CardPointTrans_GamePlayed]
ALTER TABLE [dbo].[tblCardPointTrans] ADD  CONSTRAINT [DF_tblCardPointTrans_CardTrans_PointEarned]  DEFAULT ((0)) FOR [CardPointTrans_PointEarned]
ALTER TABLE [dbo].[tblCardPointTrans] ADD  CONSTRAINT [DF_tblCardPointTrans_CardTrans_HappyHourRate]  DEFAULT ((0)) FOR [CardPointTrans_HappyHourRate]
ALTER TABLE [dbo].[tblCardPointTrans] ADD  CONSTRAINT [DF_tblCardPointTrans_CardTrans_MemberCardTypeRate]  DEFAULT ((0)) FOR [CardPointTrans_MemberCardTypeRate]
ALTER TABLE [dbo].[tblCardPointTrans] ADD  CONSTRAINT [DF_tblCardPointTrans_CardTrans_MachineRate]  DEFAULT ((0)) FOR [CardPointTrans_MachineRate]
ALTER TABLE [dbo].[tblCardPointTrans] ADD  CONSTRAINT [DF_tblCardPointTrans_CardTrans_PlayerMultiplier]  DEFAULT ((0)) FOR [CardPointTrans_PlayerMultiplier]
ALTER TABLE [dbo].[tblCardPointTrans] ADD  CONSTRAINT [DF_tblCardPointTrans_CardTrans_BaseRate]  DEFAULT ((0)) FOR [CardPointTrans_BaseRate]
ALTER TABLE [dbo].[tblCardPointTrans] ADD  CONSTRAINT [DF_tblCardPointTrans_CardPointTrans_ApprovedBy]  DEFAULT ('') FOR [CardPointTrans_ApprovedBy]
ALTER TABLE [dbo].[tblCardPointTrans] ADD  CONSTRAINT [DF_tblCardPointTrans_CardPointTrans_Campaign_ID]  DEFAULT ((0)) FOR [CardPointTrans_Campaign_ID]
ALTER TABLE [dbo].[tblCardPointTrans] ADD  CONSTRAINT [DF_tblCardPointTrans_CardPointTrans_PointType]  DEFAULT ((0)) FOR [CardPointTrans_PointType]
ALTER TABLE [dbo].[tblCardPointTrans] ADD  CONSTRAINT [DF_tblCardPointTrans_CardPointTrans_OldCardNumber]  DEFAULT ('') FOR [CardPointTrans_OldCardNumber]
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0: Normal, 1: Tier, 2: Hidden' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblCardPointTrans', @level2type=N'COLUMN',@level2name=N'CardPointTrans_PointType'
