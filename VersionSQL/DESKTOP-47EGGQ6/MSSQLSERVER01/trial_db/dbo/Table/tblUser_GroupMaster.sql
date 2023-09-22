/****** Object:  Table [dbo].[tblUser_GroupMaster]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblUser_GroupMaster](
	[UGroup_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[UGroup_Name] [nvarchar](50) NULL,
	[UGroup_Status] [bit] NOT NULL,
	[UGroup_CreatedBy] [nvarchar](50) NOT NULL,
	[UGroup_CreatedDate] [datetime] NOT NULL,
	[UGroup_ModifiedBy] [nvarchar](50) NULL,
	[UGroup_ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_tblUser_GroupMaster] PRIMARY KEY CLUSTERED 
(
	[UGroup_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[tblUser_GroupMaster] ADD  CONSTRAINT [DF_tblUser_GroupMaster_UGroup_Status]  DEFAULT ((1)) FOR [UGroup_Status]
