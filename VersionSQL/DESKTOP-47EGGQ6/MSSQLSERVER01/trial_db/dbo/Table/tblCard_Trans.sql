/****** Object:  Table [dbo].[tblCard_Trans]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblCard_Trans](
	[CardTrans_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CardTrans_Code] [nvarchar](100) NULL,
	[CardTrans_SerialNo] [nvarchar](50) NULL,
	[CardTrans_Date] [datetime] NULL,
	[CardTrans_Type] [int] NOT NULL,
	[CardTrans_Value] [money] NOT NULL,
	[CardTrans_MoneyValue] [money] NOT NULL,
	[CardTrans_RefCode] [nvarchar](50) NULL,
	[CardTrans_CreatedBy] [nvarchar](50) NULL,
	[CardTrans_CreatedDate] [datetime] NULL,
	[CardTrans_CampaignCode] [nvarchar](50) NULL,
	[CardTrans_PaymentMode] [int] NOT NULL,
	[CardTrans_Remarks] [nvarchar](max) NOT NULL,
	[CardTrans_MoneyIn] [money] NOT NULL,
	[CardTrans_MoneyOut] [money] NOT NULL,
	[CardTrans_Turnover] [money] NOT NULL,
	[CardTrans_Won] [money] NOT NULL,
	[CardTrans_GamePlayed] [money] NOT NULL,
	[CardTrans_PointEarned] [money] NOT NULL,
	[CardTrans_HappyHourRate] [money] NOT NULL,
	[CardTrans_MemberCardTypeRate] [money] NOT NULL,
	[CardTrans_MachineRate] [money] NOT NULL,
	[CardTrans_PlayerMultiplier] [money] NOT NULL,
	[CardTrans_BaseRate] [money] NOT NULL,
	[CardTrans_Timespan] [nvarchar](50) NULL,
	[CardTrans_OldCardNumber] [nvarchar](50) NOT NULL,
	[CardTrans_game_session_id] [bigint] NULL,
	[CardTrans_LocalID] [nvarchar](100) NULL,
	[CardTrans_APIKey] [nvarchar](50) NOT NULL,
	[CardTrans_InitialAmount] [money] NULL,
	[CardTrans_FinalAmount] [money] NULL,
	[tblCard_Trans_is_sync] [int] NOT NULL,
	[tblCard_Trans_sync_datetime] [datetime] NULL,
	[tblCard_Trans_csum] [bigint] NOT NULL,
 CONSTRAINT [PK_tblCard_Trans] PRIMARY KEY CLUSTERED 
(
	[CardTrans_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [IX_tblCard_Trans_APIKey] UNIQUE NONCLUSTERED 
(
	[CardTrans_APIKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [IX_tblCard_Trans_Code] UNIQUE NONCLUSTERED 
(
	[CardTrans_Code] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [IX_tblCard_Trans_localID] UNIQUE NONCLUSTERED 
(
	[CardTrans_LocalID] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[tblCard_Trans] ADD  CONSTRAINT [DF_tblCard_Trans_CardTrans_Type]  DEFAULT ((0)) FOR [CardTrans_Type]
ALTER TABLE [dbo].[tblCard_Trans] ADD  CONSTRAINT [DF_tblCard_Trans_CardTrans_Value]  DEFAULT ((0)) FOR [CardTrans_Value]
ALTER TABLE [dbo].[tblCard_Trans] ADD  CONSTRAINT [DF_tblCard_Trans_CardTrans_MoneyValue]  DEFAULT ((0)) FOR [CardTrans_MoneyValue]
ALTER TABLE [dbo].[tblCard_Trans] ADD  CONSTRAINT [DF_tblCard_Trans_CardTrans_PaymentMode]  DEFAULT ((0)) FOR [CardTrans_PaymentMode]
ALTER TABLE [dbo].[tblCard_Trans] ADD  CONSTRAINT [DF_tblCard_Trans_CardTrans_Remarks]  DEFAULT ('') FOR [CardTrans_Remarks]
ALTER TABLE [dbo].[tblCard_Trans] ADD  CONSTRAINT [DF_tblCard_Trans_CardTrans_MoneyIn]  DEFAULT ((0)) FOR [CardTrans_MoneyIn]
ALTER TABLE [dbo].[tblCard_Trans] ADD  CONSTRAINT [DF_tblCard_Trans_CardTrans_MoneyOut]  DEFAULT ((0)) FOR [CardTrans_MoneyOut]
ALTER TABLE [dbo].[tblCard_Trans] ADD  CONSTRAINT [DF_tblCard_Trans_CardTrans_Turnover]  DEFAULT ((0)) FOR [CardTrans_Turnover]
ALTER TABLE [dbo].[tblCard_Trans] ADD  CONSTRAINT [DF_tblCard_Trans_CadrTrans_Won]  DEFAULT ((0)) FOR [CardTrans_Won]
ALTER TABLE [dbo].[tblCard_Trans] ADD  CONSTRAINT [DF_tblCard_Trans_CardTrans_GamePlayed]  DEFAULT ((0)) FOR [CardTrans_GamePlayed]
ALTER TABLE [dbo].[tblCard_Trans] ADD  CONSTRAINT [DF_tblCard_Trans_CardTrans_PointEarned]  DEFAULT ((0)) FOR [CardTrans_PointEarned]
ALTER TABLE [dbo].[tblCard_Trans] ADD  CONSTRAINT [DF_tblCard_Trans_CardTrans_HappyHourRate]  DEFAULT ((0)) FOR [CardTrans_HappyHourRate]
ALTER TABLE [dbo].[tblCard_Trans] ADD  CONSTRAINT [DF_tblCard_Trans_CardTrans_MemberCardTyperate]  DEFAULT ((0)) FOR [CardTrans_MemberCardTypeRate]
ALTER TABLE [dbo].[tblCard_Trans] ADD  CONSTRAINT [DF_tblCard_Trans_CardTrans_MachineRate]  DEFAULT ((0)) FOR [CardTrans_MachineRate]
ALTER TABLE [dbo].[tblCard_Trans] ADD  CONSTRAINT [DF_tblCard_Trans_CardTrans_PlayerMultiplier]  DEFAULT ((0)) FOR [CardTrans_PlayerMultiplier]
ALTER TABLE [dbo].[tblCard_Trans] ADD  CONSTRAINT [DF_tblCard_Trans_CardTrans_Baserate]  DEFAULT ((0)) FOR [CardTrans_BaseRate]
ALTER TABLE [dbo].[tblCard_Trans] ADD  CONSTRAINT [DF_tblCard_Trans_CardTrans_OldCardNumber]  DEFAULT ('') FOR [CardTrans_OldCardNumber]
ALTER TABLE [dbo].[tblCard_Trans] ADD  CONSTRAINT [DF_tblCard_Trans_CardTrans_LocalID]  DEFAULT ('RESERVED1'+ltrim(rtrim(str(ident_current('POSv3..tblCard_trans'))))) FOR [CardTrans_LocalID]
ALTER TABLE [dbo].[tblCard_Trans] ADD  CONSTRAINT [DF_tblCard_Trans_CardTrans_APIKey]  DEFAULT ('RESERVED0'+ltrim(rtrim(str(ident_current('POSv3..tblCard_trans'))))) FOR [CardTrans_APIKey]
ALTER TABLE [dbo].[tblCard_Trans] ADD  CONSTRAINT [DF_tblCard_Trans_tbCard_Trans_is_sync]  DEFAULT ((0)) FOR [tblCard_Trans_is_sync]
ALTER TABLE [dbo].[tblCard_Trans] ADD  CONSTRAINT [DF_tblCard_Trans_tblCard_Trans_csum]  DEFAULT ((0)) FOR [tblCard_Trans_csum]
