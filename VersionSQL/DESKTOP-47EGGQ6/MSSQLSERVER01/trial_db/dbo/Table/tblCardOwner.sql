/****** Object:  Table [dbo].[tblCardOwner]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblCardOwner](
	[CardOwner_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CardOwner_CardSerialNo] [nvarchar](50) NULL,
	[CardOwner_Name] [nvarchar](50) NULL,
	[CardOwner_MobileNumber] [nvarchar](50) NULL,
	[CardOwner_Gender] [smallint] NOT NULL,
	[CardOwner_Membership] [nvarchar](max) NOT NULL,
	[CardOwner_IC] [nvarchar](50) NOT NULL,
	[CardOwner_Address] [nvarchar](max) NOT NULL,
	[CardOwner_CreatedBy] [int] NOT NULL,
	[CardOwner_CreatedDate] [datetime] NULL,
	[CardOwner_UpdatedBy] [int] NOT NULL,
	[CardOwner_UpdateDate] [datetime] NULL,
	[CardOwner_FamilyName] [nvarchar](50) NOT NULL,
	[CardOwner_Country_ID] [bigint] NOT NULL,
	[CardOwner_Status] [smallint] NOT NULL,
	[CardOwner_Level] [int] NOT NULL,
	[CardOwner_DOB] [datetime] NULL,
	[CardOwner_Email] [nvarchar](50) NOT NULL,
	[CardOwner_IDType] [smallint] NOT NULL,
	[CardOwner_Remarks] [nvarchar](max) NOT NULL,
	[CardOwner_Barred] [smallint] NOT NULL,
	[CardOwner_BarredReason] [nvarchar](255) NOT NULL,
	[CardOwner_Pic] [nvarchar](max) NOT NULL,
	[CardOwner_clsc_new_notification] [int] NOT NULL,
	[CardOwner_clsc_new_message] [int] NOT NULL,
	[CardOwner_clsc_allow_play] [int] NOT NULL,
	[CardOwner_clsc_allow_play_message] [nvarchar](max) NULL,
	[CardOwner_clsc_sync] [int] NOT NULL,
	[CardOwner_clsc_checksum] [bigint] NOT NULL,
	[CardOwner_clsc_suffix] [nvarchar](50) NULL,
 CONSTRAINT [PK_tblCardOwner] PRIMARY KEY CLUSTERED 
(
	[CardOwner_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[tblCardOwner] ADD  CONSTRAINT [DF_tblCardOwner_CardOwner_Gender]  DEFAULT ((0)) FOR [CardOwner_Gender]
ALTER TABLE [dbo].[tblCardOwner] ADD  CONSTRAINT [DF_tblCardOwner_CardOwner_Membership]  DEFAULT ('') FOR [CardOwner_Membership]
ALTER TABLE [dbo].[tblCardOwner] ADD  CONSTRAINT [DF_tblCardOwner_CardOwner_IC]  DEFAULT ('') FOR [CardOwner_IC]
ALTER TABLE [dbo].[tblCardOwner] ADD  CONSTRAINT [DF_tblCardOwner_CardOwner_Address]  DEFAULT ('') FOR [CardOwner_Address]
ALTER TABLE [dbo].[tblCardOwner] ADD  CONSTRAINT [DF_tblCardOwner_CardOwner_CreatedBy]  DEFAULT ((0)) FOR [CardOwner_CreatedBy]
ALTER TABLE [dbo].[tblCardOwner] ADD  CONSTRAINT [DF_tblCardOwner_CardOwner_UpdatedBy]  DEFAULT ((0)) FOR [CardOwner_UpdatedBy]
ALTER TABLE [dbo].[tblCardOwner] ADD  CONSTRAINT [DF_tblCardOwner_CardOwner_FamilyName]  DEFAULT ('') FOR [CardOwner_FamilyName]
ALTER TABLE [dbo].[tblCardOwner] ADD  CONSTRAINT [DF_tblCardOwner_CardOwner_Country_ID]  DEFAULT ((1)) FOR [CardOwner_Country_ID]
ALTER TABLE [dbo].[tblCardOwner] ADD  CONSTRAINT [DF_tblCardOwner_CardOwner_Status]  DEFAULT ((0)) FOR [CardOwner_Status]
ALTER TABLE [dbo].[tblCardOwner] ADD  CONSTRAINT [DF_tblCardOwner_CardOwner_Level]  DEFAULT ((1)) FOR [CardOwner_Level]
ALTER TABLE [dbo].[tblCardOwner] ADD  CONSTRAINT [DF_tblCardOwner_CardOwner_Email]  DEFAULT ('') FOR [CardOwner_Email]
ALTER TABLE [dbo].[tblCardOwner] ADD  CONSTRAINT [DF_tblCardOwner_CardOwner_IDType]  DEFAULT ((1)) FOR [CardOwner_IDType]
ALTER TABLE [dbo].[tblCardOwner] ADD  CONSTRAINT [DF_tblCardOwner_CardOwner_Remarks]  DEFAULT ('') FOR [CardOwner_Remarks]
ALTER TABLE [dbo].[tblCardOwner] ADD  CONSTRAINT [DF_tblCardOwner_CardOwner_Barred]  DEFAULT ((0)) FOR [CardOwner_Barred]
ALTER TABLE [dbo].[tblCardOwner] ADD  CONSTRAINT [DF_tblCardOwner_CardOwner_BarredReason]  DEFAULT ('') FOR [CardOwner_BarredReason]
ALTER TABLE [dbo].[tblCardOwner] ADD  CONSTRAINT [DF_tblCardOwner_CardOwner_Pic]  DEFAULT ('') FOR [CardOwner_Pic]
ALTER TABLE [dbo].[tblCardOwner] ADD  CONSTRAINT [DF_tblCardOwner_CardOwner_clsc_new_notification]  DEFAULT ((0)) FOR [CardOwner_clsc_new_notification]
ALTER TABLE [dbo].[tblCardOwner] ADD  CONSTRAINT [DF_tblCardOwner_CardOwner_clsc_new_message]  DEFAULT ((0)) FOR [CardOwner_clsc_new_message]
ALTER TABLE [dbo].[tblCardOwner] ADD  CONSTRAINT [DF_tblCardOwner_player_allow_play]  DEFAULT ((0)) FOR [CardOwner_clsc_allow_play]
ALTER TABLE [dbo].[tblCardOwner] ADD  CONSTRAINT [DF_tblCardOwner_CardOwner_clsc_sync]  DEFAULT ((0)) FOR [CardOwner_clsc_sync]
ALTER TABLE [dbo].[tblCardOwner] ADD  CONSTRAINT [DF_tblCardOwner_CardOwner_clsc_sync1]  DEFAULT ((0)) FOR [CardOwner_clsc_checksum]
