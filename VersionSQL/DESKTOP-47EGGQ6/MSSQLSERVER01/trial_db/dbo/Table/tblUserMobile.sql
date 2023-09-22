/****** Object:  Table [dbo].[tblUserMobile]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblUserMobile](
	[mUser_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[mUser_Code] [nvarchar](50) NULL,
	[mUser_LoginID] [nvarchar](50) NULL,
	[mUser_Password] [nvarchar](50) NULL,
	[mUser_FullName] [nvarchar](50) NULL,
	[mUser_MobileNo] [nvarchar](50) NULL,
	[mUser_DOB] [date] NULL,
	[mUser_Gender] [smallint] NOT NULL,
	[mUser_Address1] [nvarchar](50) NULL,
	[mUser_Address2] [nvarchar](50) NULL,
	[mUser_City] [nvarchar](50) NULL,
	[mUser_Postcode] [nvarchar](50) NULL,
	[mUser_State] [int] NULL,
	[mUser_TotalBalance] [money] NULL,
	[mUser_RegisterDate] [datetime] NULL,
	[mUser_Status] [smallint] NOT NULL,
	[mUser_CompanyCode] [nvarchar](50) NULL,
	[mUser_Remarks] [nvarchar](50) NOT NULL,
	[mUser_TotalPoint] [money] NOT NULL,
	[mUser_randomCode] [nvarchar](1024) NULL,
	[mUser_Sync] [smallint] NOT NULL,
	[mUser_SyncDate] [datetime] NULL,
 CONSTRAINT [PK_tblUser_Mobile] PRIMARY KEY CLUSTERED 
(
	[mUser_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[tblUserMobile] ADD  CONSTRAINT [DF_tblUser_Mobile_mUser_Gender]  DEFAULT ((0)) FOR [mUser_Gender]
ALTER TABLE [dbo].[tblUserMobile] ADD  CONSTRAINT [DF_tblUser_Mobile_mUser_Status]  DEFAULT ((0)) FOR [mUser_Status]
ALTER TABLE [dbo].[tblUserMobile] ADD  CONSTRAINT [DF_tblUserMobile_mUser_Remarks]  DEFAULT ('') FOR [mUser_Remarks]
ALTER TABLE [dbo].[tblUserMobile] ADD  CONSTRAINT [DF_tblUserMobile_mUser_TotalPoint]  DEFAULT ((0)) FOR [mUser_TotalPoint]
ALTER TABLE [dbo].[tblUserMobile] ADD  CONSTRAINT [DF_tblUserMobile_mUser_Sync]  DEFAULT ((0)) FOR [mUser_Sync]
