/****** Object:  Table [dbo].[tblTicket_Bonus]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblTicket_Bonus](
	[Ticket_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Ticket_Code] [nvarchar](50) NULL,
	[Ticket_UserCode] [nvarchar](50) NULL,
	[Ticket_SerialNumber] [nvarchar](50) NULL,
	[Ticket_CampaignID] [bigint] NOT NULL,
	[Ticket_TransDate] [datetime] NULL,
	[Ticket_MachineID] [bigint] NOT NULL,
	[Ticket_MachineName] [nvarchar](500) NOT NULL,
	[Ticket_Status] [smallint] NOT NULL,
	[Ticket_RedeemDate] [datetime] NULL,
	[Ticket_RedeemBy] [nvarchar](50) NULL,
	[Ticket_CreatedBy] [nvarchar](50) NULL,
	[Ticket_CreatedDate] [datetime] NULL,
	[Ticket_UpdatedBy] [nvarchar](50) NULL,
	[Ticket_UpdatedDate] [datetime] NULL,
	[Ticket_LocalID] [bigint] NOT NULL,
	[Ticket_Timespan] [nvarchar](50) NULL,
 CONSTRAINT [PK_tblTicket_Bonus] PRIMARY KEY CLUSTERED 
(
	[Ticket_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[tblTicket_Bonus] ADD  CONSTRAINT [DF_Table_1_Ticket_Campaign_ID]  DEFAULT ((0)) FOR [Ticket_CampaignID]
ALTER TABLE [dbo].[tblTicket_Bonus] ADD  CONSTRAINT [DF_tblTicket_Bonus_Ticket_MachineID]  DEFAULT ((0)) FOR [Ticket_MachineID]
ALTER TABLE [dbo].[tblTicket_Bonus] ADD  CONSTRAINT [DF_tblTicket_Bonus_Ticket_MachineName]  DEFAULT ('') FOR [Ticket_MachineName]
ALTER TABLE [dbo].[tblTicket_Bonus] ADD  CONSTRAINT [DF_tblTicket_Bonus_Ticket_Status]  DEFAULT ((0)) FOR [Ticket_Status]
ALTER TABLE [dbo].[tblTicket_Bonus] ADD  CONSTRAINT [DF_tblTicket_Bonus_Ticket_LocalID]  DEFAULT ((0)) FOR [Ticket_LocalID]
