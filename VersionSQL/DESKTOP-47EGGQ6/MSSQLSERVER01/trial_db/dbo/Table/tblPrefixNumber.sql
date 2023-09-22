/****** Object:  Table [dbo].[tblPrefixNumber]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblPrefixNumber](
	[AutoNumber_ID] [int] IDENTITY(1,1) NOT NULL,
	[AutoNumber_BranchID] [int] NOT NULL,
	[AutoNumber_TrxType] [varchar](100) NOT NULL,
	[AutoNumber_PrefixType] [varchar](100) NOT NULL,
	[AutoNumber_Prefix] [varchar](100) NOT NULL,
	[AutoNumber_RunningNo] [bigint] NOT NULL,
	[AutoNumber_RunningNoLength] [int] NOT NULL,
	[AutoNumber_RunningNoStatus] [bit] NOT NULL,
	[AutoNumber_Remarks] [nvarchar](2000) NOT NULL,
	[AutoNumber_ModifiedUserCode] [nvarchar](50) NOT NULL,
	[AutoNumber_ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_tblPrefixNumber] PRIMARY KEY CLUSTERED 
(
	[AutoNumber_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[tblPrefixNumber] ADD  CONSTRAINT [DF_Table_1_BranchId]  DEFAULT ((0)) FOR [AutoNumber_BranchID]
ALTER TABLE [dbo].[tblPrefixNumber] ADD  CONSTRAINT [DF_Table_1_TrxType]  DEFAULT ('') FOR [AutoNumber_TrxType]
ALTER TABLE [dbo].[tblPrefixNumber] ADD  CONSTRAINT [DF_Table_1_PrefixType]  DEFAULT ('') FOR [AutoNumber_PrefixType]
ALTER TABLE [dbo].[tblPrefixNumber] ADD  CONSTRAINT [DF_Table_1_Prefix]  DEFAULT ('') FOR [AutoNumber_Prefix]
ALTER TABLE [dbo].[tblPrefixNumber] ADD  CONSTRAINT [DF_Table_1_RunningNo]  DEFAULT ((0)) FOR [AutoNumber_RunningNo]
ALTER TABLE [dbo].[tblPrefixNumber] ADD  CONSTRAINT [DF_Table_1_RunningNoLength]  DEFAULT ((0)) FOR [AutoNumber_RunningNoLength]
ALTER TABLE [dbo].[tblPrefixNumber] ADD  CONSTRAINT [DF_Table_1_RunningNoStatus]  DEFAULT ((0)) FOR [AutoNumber_RunningNoStatus]
ALTER TABLE [dbo].[tblPrefixNumber] ADD  CONSTRAINT [DF_Table_1_Remarks]  DEFAULT ('') FOR [AutoNumber_Remarks]
ALTER TABLE [dbo].[tblPrefixNumber] ADD  CONSTRAINT [DF_Table_1_LastModifiedUserId]  DEFAULT ('') FOR [AutoNumber_ModifiedUserCode]
ALTER TABLE [dbo].[tblPrefixNumber] ADD  CONSTRAINT [DF_Table_1_LastModifiedDate]  DEFAULT (((1900)/(1))/(1)) FOR [AutoNumber_ModifiedDate]
