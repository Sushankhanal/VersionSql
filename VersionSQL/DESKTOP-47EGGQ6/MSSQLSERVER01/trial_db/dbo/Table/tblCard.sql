/****** Object:  Table [dbo].[tblCard]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblCard](
	[Card_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Card_SerialNo] [nvarchar](50) NULL,
	[Card_Status] [smallint] NOT NULL,
	[Card_MobileUser] [nvarchar](50) NOT NULL,
	[Card_Balance] [money] NOT NULL,
	[Card_CreatedBy] [nvarchar](50) NULL,
	[Card_CreatedDate] [datetime] NULL,
	[Card_Point] [decimal](38, 10) NOT NULL,
	[Card_CompanyCode] [nvarchar](50) NULL,
	[Card_CardOwner_ID] [bigint] NULL,
	[Card_Sync] [smallint] NOT NULL,
	[Card_SyncDate] [datetime] NULL,
	[Card_Type] [smallint] NOT NULL,
	[tblCard_pin] [nvarchar](32) NOT NULL,
	[Card_Balance_Cashable_No] [money] NOT NULL,
	[Card_Balance_Cashable] [money] NOT NULL,
	[Card_PointAccumulate] [decimal](38, 10) NOT NULL,
	[Card_isPinReset] [smallint] NOT NULL,
	[Card_Point_Tier] [decimal](38, 10) NOT NULL,
	[Card_Point_Hidden] [decimal](38, 10) NOT NULL,
	[Card_isAbleToUpgrade] [smallint] NOT NULL,
	[Card_Level] [bigint] NOT NULL,
	[Card_last_up_gradetime] [datetime] NULL,
	[Card_tier_last_reset_time] [datetime] NULL,
	[Card_level_expired_time] [datetime] NULL,
	[Card_last_down_gradetime] [datetime] NULL,
	[Card_img] [nvarchar](max) NOT NULL,
	[Card_PrintDate] [datetime] NULL,
	[Card_Expiry_Cashable_No] [datetime] NULL,
	[Card_Expiry_Cashable] [datetime] NULL,
	[Card_balance_Edit_DateTime] [datetime] NULL,
	[Card_without_sync] [int] NOT NULL,
 CONSTRAINT [PK_tblCard] PRIMARY KEY CLUSTERED 
(
	[Card_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [IX_tblCard] UNIQUE NONCLUSTERED 
(
	[Card_SerialNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[tblCard] ADD  CONSTRAINT [DF_tblCard_Card_Status]  DEFAULT ((0)) FOR [Card_Status]
ALTER TABLE [dbo].[tblCard] ADD  CONSTRAINT [DF_tblCard_Card_MobileUser]  DEFAULT ('') FOR [Card_MobileUser]
ALTER TABLE [dbo].[tblCard] ADD  CONSTRAINT [DF_tblCard_Card_Balance]  DEFAULT ((0)) FOR [Card_Balance]
ALTER TABLE [dbo].[tblCard] ADD  CONSTRAINT [DF_tblCard_Card_Point]  DEFAULT ((0)) FOR [Card_Point]
ALTER TABLE [dbo].[tblCard] ADD  CONSTRAINT [DF_tblCard_Card_Sync]  DEFAULT ((0)) FOR [Card_Sync]
ALTER TABLE [dbo].[tblCard] ADD  CONSTRAINT [DF_tblCard_Card_Type]  DEFAULT ((0)) FOR [Card_Type]
ALTER TABLE [dbo].[tblCard] ADD  CONSTRAINT [DF_tblCard_tblCard_pin]  DEFAULT ('123456') FOR [tblCard_pin]
ALTER TABLE [dbo].[tblCard] ADD  CONSTRAINT [DF_tblCard_Card_Balance_Cashable_No]  DEFAULT ((0)) FOR [Card_Balance_Cashable_No]
ALTER TABLE [dbo].[tblCard] ADD  CONSTRAINT [DF_tblCard_Card_Balance_Cashable]  DEFAULT ((0)) FOR [Card_Balance_Cashable]
ALTER TABLE [dbo].[tblCard] ADD  CONSTRAINT [DF_tblCard_Card_PointAccumulate]  DEFAULT ((0)) FOR [Card_PointAccumulate]
ALTER TABLE [dbo].[tblCard] ADD  CONSTRAINT [DF_tblCard_Card_isPinReset]  DEFAULT ((0)) FOR [Card_isPinReset]
ALTER TABLE [dbo].[tblCard] ADD  CONSTRAINT [DF_tblCard_Card_Point_Tier]  DEFAULT ((0)) FOR [Card_Point_Tier]
ALTER TABLE [dbo].[tblCard] ADD  CONSTRAINT [DF_tblCard_Card_Point_Hidden]  DEFAULT ((0)) FOR [Card_Point_Hidden]
ALTER TABLE [dbo].[tblCard] ADD  CONSTRAINT [DF__tmp_ms_xx__Card___1B53EBE8]  DEFAULT ((0)) FOR [Card_isAbleToUpgrade]
ALTER TABLE [dbo].[tblCard] ADD  CONSTRAINT [DF__tmp_ms_xx__Card___1C481021]  DEFAULT ((1)) FOR [Card_Level]
ALTER TABLE [dbo].[tblCard] ADD  CONSTRAINT [DF_tblCard_Card_last_up_gradetime]  DEFAULT ('1900-01-01 00:00:00') FOR [Card_last_up_gradetime]
ALTER TABLE [dbo].[tblCard] ADD  CONSTRAINT [DF_tblCard_Card_tier_last_reset_time]  DEFAULT ('1900-01-01 00:00:00') FOR [Card_tier_last_reset_time]
ALTER TABLE [dbo].[tblCard] ADD  CONSTRAINT [DF_tblCard_Card_level_expired_time]  DEFAULT ('1900-01-01 00:00:00') FOR [Card_level_expired_time]
ALTER TABLE [dbo].[tblCard] ADD  CONSTRAINT [DF_tblCard_Card_last_down_gradetime]  DEFAULT ('1900-01-01 00:00:00') FOR [Card_last_down_gradetime]
ALTER TABLE [dbo].[tblCard] ADD  CONSTRAINT [DF_tblCard_Card_img]  DEFAULT ('') FOR [Card_img]
ALTER TABLE [dbo].[tblCard] ADD  CONSTRAINT [DF_tblCard_Card_PrintDate]  DEFAULT ('1900-01-01 00:00:00') FOR [Card_PrintDate]
ALTER TABLE [dbo].[tblCard] ADD  CONSTRAINT [DF_tblCard_Card_Expiry_Cashable_No]  DEFAULT ('1900-01-01 00:00:00') FOR [Card_Expiry_Cashable_No]
ALTER TABLE [dbo].[tblCard] ADD  CONSTRAINT [DF_tblCard_Card_Expiry_Cashable]  DEFAULT ('1900-01-01 00:00:00') FOR [Card_Expiry_Cashable]
ALTER TABLE [dbo].[tblCard] ADD  CONSTRAINT [DF_tblCard_Card_without_sync]  DEFAULT ((0)) FOR [Card_without_sync]
